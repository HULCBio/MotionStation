function cvs(fileNames, arguments)
%CVS    Version control actions using RCS.
%   CVS(FILENAMES, ARGUMENTS) Performs the requested action 
%   with ARGUMENTS options (name/value pairs) as specified below.
%   FILENAMES must be the full path of the file or a cell array
%   of files. 
%
%   OPTIONS:
%      action - The version control action to be performed.
%         checkin
%         checkout
%         undocheckout
%   
%      lock - Locks the file.
%         on
%         off
%
%      revision - Performs the action on the specified revision. 
%
%      outputfile - Writes file to outputfile.
%
%    See also CHECKIN, CHECKOUT, UNDOCHECKOUT, CMOPTS, CUSTOMVERCTRL,
%    SOURCESAFE, CLEARCASE, CVS, and PVCS.
%

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/19 23:30:17 $

action     = arguments(find(strcmp(arguments, 'action')), 2);      % Mandatory argument
lock       = arguments(find(strcmp(arguments, 'lock')), 2);        % Assumed as OFF for checkin and ON for checkout
comments   = arguments(find(strcmp(arguments, 'comments')), 2);    % Mandatory if checkin is the action 
revision   = arguments(find(strcmp(arguments, 'revision')), 2);
outputfile = arguments(find(strcmp(arguments, 'outputfile')), 2);
force      = arguments(find(strcmp(arguments, 'force')), 2);

if (isempty(action))                                                     % Checking for mandatory arguements
    error('No action specified.');
else
    action    = action{1};                                          % De-referencing
end

files      = '';                                                   % Create space delimitted string of file names
for i = 1 : length(fileNames)
    files        = [files ' ' fileNames{i}];
end

command    = '';
switch action
case 'checkin'
    if (isempty(comments))                                                 % Checking for mandatory arguments
        error('Comments not specified');
    else
        comments = comments{1};                                              % De-referencing
        comments = cleanupcomment(comments);
    end
    % Check to see if this is a new file or an existing file.
    [s, r] = system(['cvs -Q log ' files]);
    if (s == 1) % New file
        [s, r] = system(['cvs -Q add -m "' comments '" ' files]);    
    else
        [s, r] = system(['cvs -Q commit -m "' comments '" ' files]);
    end
    if (s == 1)
        error(r);
    end
    
    if (isempty(lock))
        lock = 'off';
    else 
        lock = lock{1};
    end
    if (strcmpi(lock, 'on'))
        [s, r] = system(['cvs -Q edit ' files]);
        if (s == 1)
            error(r);
        end
    end
    
case 'checkout'
    if (isempty(lock))
        lock     = 'off';
    else
        lock     = lock{1};                                              % De-referencing
    end
    if (isempty(revision))
        revision = '';
    else
        revision = revision{1};                                          % De-referencing
    end
    
    command      = 'cvs -Q ';                                              % Building the command string.
    if (strcmp(lock, 'on'))
        command  = [command 'edit '];
        if (~isempty(revision))
            error('Locking a particular version not supported in CVS.');
        end
    else
        command  = [command 'checkout '];
    end
    if (isempty(revision))
        command  = command;
    else
        command  = [command ' -r' revision];
    end
    
    if (isempty(outputfile))
        command  = command;
    else
        command  = [command ' -p > ' outputfile{1}];                    % SHOULD BE THE LAST OPTION AS REDIRECTING STD OUTPUT
    end
    
    [s, r] = system([command ' ' files]);
    if (s == 1)
        error(r);
    end
    
case 'undocheckout'
    [s, r] = system(['cvs -Q unedit ' files]);
    if (s == 1)
        error(r);
    end
end
