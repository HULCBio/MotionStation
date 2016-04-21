function strc = getcallinfo(filename,option)
%GETCALLINFO  Returns called functions and their initial calling lines
%   STRUCT = GETCALLINFO(FILENAME,OPTION)
%   The output structure STRUCT takes the form
%      type:       [ script | function | subfunction ]
%      name:       name of the script, function, or subfunction
%      firstline:  first line of the script, function, or subfunction
%      calls:      calls made by the script, function, or subfunction
%      calllines:  lines from which the above calls were made
%
%   OPTION = [ 'file' | 'subfuns' | 'funlist' ]
%   By default OPTION is set to 'subfuns'
%   
%   OPTION = 'file' returns one structure for the entire file, regardless
%   of whether it is a script, a function with no subfunctions, or a
%   function with subfunctions. For a file with subfunctions, the calls
%   for the file includes all external calls made by subfunctions. 
%
%   OPTION = 'subfuns' returns an array of structures. The first is for the
%   for the main function followed by all of the subfunctions. This option
%   returns the same result as 'file' for scripts and one-function files.
%
%   OPTION = 'funlist' returns an array of structures similar to the
%   'subfuns' option, but calls and calllines information is not
%   returned, only the list of subfunctions and their first lines.

%   Copyright 1984-2003 The MathWorks, Inc.
%   Ned Gulley

if nargin < 2
    option = 'subfuns';
end

% Form the OS command for mlint
if ispc
    mlintPath = [matlabroot '\bin\win32\mlint.exe'];
else
    mlintPath = [matlabroot '/bin/' lower(computer) '/mlint'];
end

% Call the M-Lint executable
mlintCmd = [mlintPath ' -calls "' filename '"'];
[stat,mlintMsg] = system(mlintCmd);

% Return M-Lint's error message if it fails
if stat
    if isempty(mlintMsg)
        mlintMsg = sprintf('Internal error when calling:\n''%s''',mlintCmd);
    end
end

mainFcnHit =  regexp(mlintMsg,'M0 (\d+) \d+ (\w+)','tokens','once');
subFcnHits = regexp(mlintMsg,'S0 (\d+) \d+ (\w+)','tokens');
filenameHit = regexp(filename,'(\w+)\.m?$','tokens','once');
shortfilename = filenameHit{1};

strc = [];
% TODO: watch out for nested functions 
if isempty(mainFcnHit)
    % File is a script
    strc.type = 'script';
    strc.name = shortfilename;
    hits = regexp(mlintMsg,'U0 (\d+) \d+ (\w+)','tokens');
    strc.firstline = 1;
    strc.calls = cell(length(hits),1);
    strc.calllines = zeros(length(hits),1);
    for n = 1:length(hits)
        strc.calllines(n) = eval(hits{n}{1});
        strc.calls{n} = hits{n}{2};
    end

else
    % File is a function
    strc(1).type = 'function';
    strc(1).name = shortfilename;
    strc(1).firstline = 1;
    callHits = regexp(mlintMsg,'U1 (\d+) \d+ (\w+)','tokens');

    if strcmp(option,'funlist')

        for n = 1:length(subFcnHits)
            strc(n+1).type = 'subfunction';
            strc(n+1).name = subFcnHits{n}{2};
            strc(n+1).firstline = eval(subFcnHits{n}{1});
        end
        
    elseif strcmp(option,'file')

        strc(1).calls = {};
        strc(1).calllines = [];
        localFuns = {};
        % Get list of all local functions for de-duping
        for n = 1:length(subFcnHits)
            localFuns{end+1} = subFcnHits{n}{2};
        end
        localFunStr = sprintf('%s ',localFuns{:});

        for n = 1:length(callHits)
            callLine = eval(callHits{n}{1});
            call = callHits{n}{2};
            % Only put the call on the list if it's not a local function
            if isempty(strfind(localFunStr,call))
                strc.calllines(end+1) = callLine;
                strc.calls{end+1} = call;
            end
        end

    else

        strc(1).calls = {};
        strc(1).calllines = [];
        for n = 1:length(subFcnHits)
            strc(n+1).type = 'subfunction';
            strc(n+1).name = subFcnHits{n}{2};
            strc(n+1).firstline = eval(subFcnHits{n}{1});
        end

        % Get list of all first lines for figuring which function to associate
        % the call with
        firstLines = [strc.firstline];

        for n = 1:length(callHits)
            callLine = eval(callHits{n}{1});
            call = callHits{n}{2};
            lineCompare = find(callLine > firstLines);
            strc(lineCompare(end)).calllines(end+1) = callLine;
            strc(lineCompare(end)).calls{end+1} = call;
        end
    
    end
end
