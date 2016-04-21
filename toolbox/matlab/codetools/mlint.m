function [s,filePaths] = mlint(varargin)
%MLINT   Display inconsistencies and suspicious constructs in M-files.
%   MLINT(FILENAME) displays M-Lint information about FILENAME. If FILENAME
%   is a cell array, information is displayed for each file.
%   MLINT(F1,F2,F3,...) where each input is a character array, displays
%   information about each input filename. You cannot combine cell arrays
%   and character arrays of filenames.
%
%   INFO = MLINT(...,'-struct') returns the M-Lint information in a
%   structure array whose length is the number of suspicious constructs
%   found. The structure has the following fields:
%       line    : vector of line numbers to which the message refers
%       column  : two-column array of column extents for each line
%       message : message describing the suspect that M-Lint caught
%   If multiple filenames are input, or if a cell array is input, INFO will
%   contain a cell array of structures. 
%
%   MSG = MLINT(...,'-string') returns the M-Lint information as a string
%   to the variable MSG. If multiple filenames are input, or if a cell
%   array is input, MSG fill contain a string where each file's information
%   is separated by ten "=" characters, a space, the filename, a space, and
%   ten "=" characters.
%
%   If the -struct or -string argument is omitted and an output argument is
%   specified, the default behavior is '-struct'. If the argument is
%   omitted and there are no output arguments, the default behavior is to
%   display the information to the command line.
%
%   [INFO,FILEPATHS] = MLINT(...) will additionally return FILEPATHS, the
%   absolute paths to the filenames in the same order as they were input.
%
%   [...] = MLINT(...,'-id') requests the message ID from M-Lint as well.
%   When returned to a structure, the output will have the following
%   additional field:
%       id       : ID associated with the message
%
%   [...] = MLINT(...,'-fullpath') assumes that the input filenames are
%   absolute paths, rather than requiring MLINT to locate them.
%
%   To force M-Lint to ignore a line of code, use %#ok at the end of the
%   line. This tag can be followed by comments.  For example:
%       unsuppressed1 = 10   % This line will get caught
%       suppressed2 = 20     %#ok  These next two lines will not get caught
%       suppressed3 = 30     %#ok
%
%   Examples:
%       % "lengthofline.m" is an example M-file with suspicious M-Lint
%       % constructs. It is found in the MATLAB demos as a read-only file.
%       mlint lengthofline                    % Display to command line
%       info=mlint('lengthofline','-struct')  % Store to struct with ID
%
%   See also MLINTRPT.

%   MLINT will also take additional input arguments that are not
%   documented. These arguments are passed directly into the M-Lint
%   executable such that the behavior is consistent with the executable.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.14 $ $Date: 2004/04/10 23:24:14 $

nargs = varargin;

% Extract a cell array of filenames if one was specified,
cellArgInd = cellfun('isclass',nargs,'cell');
multFileInput = false;
if any(cellArgInd)
    if sum(cellArgInd)>1
        error('MATLAB:mlint:TooManyCellArgs', ...
            'Only one cell array input of filenames is permitted.');
    else
        cellOfFilenames = nargs{cellArgInd};
        multFileInput = true;
        nargs(cellArgInd) = [];
    end
end

% Extract the options
% This will also error if there were any non-cell array or non-char inputs
optionsInd = strncmp('-',nargs,1);
options = nargs(optionsInd);
nargs(optionsInd) = [];

% Create a cell array of specified filenames if a cell array wasn't input
if all(~cellArgInd)
    cellOfFilenames = nargs;
    nFiles = length(cellOfFilenames);
    if nFiles>1
        multFileInput = true;
    elseif nFiles<1
        error('MATLAB:mlint:NoFile','No file name provided.');
    end
else
    nFiles = length(cellOfFilenames);
    if ~isempty(nargs)
        ignored = sprintf(' %s',nargs{:});
        warning('MATLAB:mlint:UnusedArgs', ...
            'The following arguments were ignored:%s.',ignored);
    end
end

% Apply options
outputType = '';
idFlag = false;
resolvePath = true;
removeInd = [];
for opt = 1:length(options)
    option = lower(options{opt});
    switch option
        case {'-struct','-string','-disp'}
            outputType = option;
            removeInd = [removeInd opt];
        case '-fullpath'
            resolvePath = false;
            removeInd = [removeInd opt];            
        case '-id'
            idFlag = true;
    end
end
options(removeInd) = [];

if isempty(outputType) && nargout>0
    outputType = '-struct';
elseif isempty(outputType)
    outputType = '-disp';
end

% Locate the specified files
if resolvePath
    for nfile = 1:nFiles
        cellOfFilenames{nfile} = local_resolvePath(cellOfFilenames{nfile});
    end
end

% If second output was specified, output a column cell array of filenames
if nargout>1
    filePaths = {cellOfFilenames{:}}';
end

if nFiles>0
    filenames = sprintf(' "%s"',cellOfFilenames{:});
    cmdArgs = sprintf(' %s',options{:});

    % Form the OS command
    if ispc;
        mlintPath = sprintf('"%s%s"',matlabroot,'\bin\win32\mlint.exe');
    else
        mlintPath = sprintf('"%s/bin/%s/mlint"',matlabroot,lower(computer));
    end

    cmdArgs = [' -all' cmdArgs ' '];

    % Call the M-Lint executable
    [stat,mlintMsg] = local_callMlint(mlintPath, cmdArgs, filenames);

    % Return M-Lint's error message if it fails
    if stat
        if isempty(mlintMsg)
            mlintCmd = sprintf('%s -all%s', mlintPath, cmdArgs);
            mlintMsg = sprintf('Internal error when calling:\n''%s''.',mlintCmd);
        end
        error('MATLAB:mlint:InternalErr','%s',mlintMsg)
    end
else
    s = {};
    return
end

% Return the results, or go on to build the structure
switch outputType
    case {'-disp','-string'}
        if nFiles>1
            split = reshape(regexp(mlintMsg, '={10}.*?(?=={10}|$)','match'), [2 nFiles]); 
            split(1,:) = strcat({'========== '}, cellOfFilenames, {' '}); 
            mlintMsg = [split{:}];
        end
end
switch outputType
    case '-disp'
        disp(mlintMsg)
        return
    case '-string'
        s = mlintMsg;
        return
end

if multFileInput
    messages = local_extractMlintMsgs(mlintMsg);
    s = local_MlintMsgToStruct(messages,idFlag,multFileInput);
else
    sc = local_MlintMsgToStruct(mlintMsg,idFlag,multFileInput);
    s = sc{1};
end


% ------------------------------------------------
function messages = local_extractMlintMsgs(mlintMsg)
% When multiple files are input to the M-Lint executable, this function
% extracts all of the file messages into a cell array of messages.
pat = '(?<msg>.*?)((={10}.*?={10})|$)';
tokens = regexp(mlintMsg,pat,'names');
if length(tokens)>1
    startInd = 2;
else
    startInd = 1;
    if isempty(tokens)
        tokens(1).msg = '';
    end
end
messages = {tokens(startInd:end).msg};


% ------------------------------------------------
function s = local_MlintMsgToStruct(mlintMsg,idFlag,multFileInput)
% mlintMsg contains lines like these, ending with a newline character:
% L 181 (C 12): [x] is much slower than x (use parens to group if needed)
% L 301 (C 10-26) InefficientUsage:AssignmentNotUsed : "x" assignment value is never used
% The regular expression below pulls out the 6 parts that have to do with
% (respectively) the row, the first affected column on the row, the last
% affected column on the row, any other sets of lines and columns, the id,
% and the message itself. "Any other sets of lines and columns" are parsed
% in a subsequent call to REGEXP.
exp = 'L\s*(?<line>\d+)\s*\(C\s*(?<colbegin>\d+)-?(?<colend>\d*)\)\s*(?<multiline>.*?)\s*(?<id>\S+:\S+)?\s*:\s*(?<message>[^\n]*)\n';
matches = regexp(mlintMsg, exp, 'names')';

if ~multFileInput
    matches = {matches};
end

s = cell(size(matches));
for m=1:length(matches)
    % If no matches, return an empty struct
    match = matches{m};
    if isempty(match)
        strFlds = {'message',{},'line',{},'column',{}};
        if idFlag
            strFlds = [strFlds {'id',{}}];
        end
        s{m} = struct(strFlds{:});
        continue
    end

    nmatch = length(match);

    for n=1:nmatch
        s{m}(n).message = match(n).message;
        s{m}(n).line = eval(match(n).line);
        colExt(1,1) = eval(match(n).colbegin);
        % If the message did not indicate an ending column, make it the same as
        % the starting column
        if isempty(match(n).colend)
            colExt(1,2) = colExt(1);
        else
            colExt(1,2) = eval(match(n).colend);
        end
        s{m}(n).column = colExt;
        multiLine = match(n).multiline;
        % If the message indicates multiple lines, concatenate the suspect line
        % and column numbers into multiple rows of match output.
        if ~isempty(multiLine)
            multiMatch = regexp(multiLine,'L\s*(?<line>\d+)\s*\(C\s*(?<colbegin>\d+)-?(?<colend>\d*)\)','names');
            for mm=length(multiMatch):-1:1
                s{m}(n).line(mm+1,1) = eval(multiMatch(mm).line);
                colExti(1,1) = eval(multiMatch(mm).colbegin);
                if isempty(multiMatch(mm).colend)
                    colExti(1,2) = colExti(1);
                else
                    colExti(1,2) = eval(multiMatch(mm).colend);
                end
                s{m}(n).column(mm+1,1:2) = colExti;
            end
        end
        if idFlag
            s{m}(n).id = match(n).id;
        end
    end
end


% ------------------------------------------------
function fullFilename = local_resolvePath(filename)
% Locate the specified file using EXIST, WHICH, PWD, and DIR.
% The strategy is as follows:
% 1. First assume filename is relative to the CWD.  Prepend PWD.
% 2. Append .m and try again.
% 3. Try to locate filename by appending .m and using WHICH.
% 4. Try again without appending .m (this may lead to a later warning).
% 5. Now assume filename was a full path to a file.
% 6. Append .m and try again.

% First check if filename is a partial path relative to CWD
fullFilename = fullfile(cd,filename);

% If file doesn't exist, try again with a .m extension
if ~local_fullNameIsFile(fullFilename)
    mFullFilename = [fullFilename '.m'];
    % If found with a .m extension, use it!
    if local_fullNameIsFile(mFullFilename)
        fullFilename = mFullFilename;
    else
        % Check if filename is on path as an M-file
        mFilename = filename;
        if isempty(regexp(mFilename,'\.[mM]$','once'))
            mFilename = [filename '.m'];
        end
        fullFilename = which(mFilename);
        % If WHICH doesn't find the M-file, try without the .m
        if isempty(fullFilename)
            fullFilename = which(filename);
            % If WHICH still doesn't find filename, then it is attempting
            % to be a full path to a file not on the MATLAB search path
            if isempty(fullFilename)
                fullFilename = filename;
                % If file doesn't exist, try again with a .m extension
                if ~local_fullNameIsFile(fullFilename)
                    mFullFilename = [fullFilename '.m'];
                    % If found with a .m extension, use it!
                    if local_fullNameIsFile(mFullFilename)
                        fullFilename = mFullFilename;
                    else
                        % We have no where else to look.
                        error('MATLAB:mlint:FileNotFound','File "%s" not found with or without a ".m" extension.',filename);
                    end
                end  
            end  
        end 
    end  
end  

% If input filename isn't a ".m" (lowercase) extension, warn and suggest.
% Even for ".M", this will warn for PC and UNIX; however, on UNIX, ".M" 
% files cannot be run. Either way, the M-Lint executable checks
% case-insensitively.
if isempty(regexp(fullFilename,'\.m$','once'))
    warning('MATLAB:mlint:ExtensionNotM', ...
        ['The input file that takes precedence, "%s",\n         ' ...
         'is not an M-file. Use a ".m" extension instead.'],fullFilename);
end


% ------------------------------------------------
function flag = local_fullNameIsFile(filename)
flag = ~(isempty(dir(filename)) || isdir(filename));


% ------------------------------------------------
function [stat,mlintMsg] = local_callMlint(mlintPath,cmdArgs,filenames)
% This local function is needed so that we can work around the DOS command
% line maximum input command length of 1024. If we are on DOS, split the
% call into several calls and concatenate the results.
if ispc
    % Split filenames up to use max allowed DOS command input (1024 characters)
    mlintMsg = '';
    stat = 0;
    sections = regexp(filenames,sprintf('".{0,%u}"(?=\\s"|$)',1021-length(cmdArgs)),'match');
    for nsec = 1:length(sections)
        [stat,mlintSubMsg] = system(sprintf('%s%s%s',mlintPath,cmdArgs,sections{nsec}));
        if stat
            mlintMsg = mlintSubMsg;
            break
        end
        mlintMsg = sprintf('%s%s',mlintMsg,mlintSubMsg);
    end
else
    mlintCmd = sprintf('%s -all%s', mlintPath, cmdArgs);
    [stat,mlintMsg] = system(sprintf('%s %s',mlintCmd,filenames));
end
