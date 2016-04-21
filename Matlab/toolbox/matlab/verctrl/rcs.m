function rcs(fileNames, arguments)
%RCS    Version control actions using RCS.
%   RCS(FILENAMES, ARGUMENTS) Performs the requested action 
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
%    SOURCESAFE, CLEARCASE, and PVCS.
%

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/03/23 02:52:30 $

action           = arguments(find(strcmp(arguments, 'action')), 2);      % Mandatory argument
lock             = arguments(find(strcmp(arguments, 'lock')), 2);        % Assumed as OFF for checkin and ON for checkout
comments         = arguments(find(strcmp(arguments, 'comments')), 2);    % Mandatory if checkin is the action 
revision         = arguments(find(strcmp(arguments, 'revision')), 2);
outputfile       = arguments(find(strcmp(arguments, 'outputfile')), 2);
force            = arguments(find(strcmp(arguments, 'force')), 2);

if (isempty(action))                                                     % Checking for mandatory arguements
	error('No action specified.');
else
	action           = action{1};                                        % De-referencing
end

files            = '';                                                   % Create space delimitted string of file names
for i = 1 : length(fileNames)
    files        = [files ' ' fileNames{i}];
end

command          = '';
switch action
case 'checkin'
	if (isempty(comments))                                               % Checking for mandatory arguments
		error('Comments not specified');
	else
		comments = comments{1};                                          % De-referencing
	end
	commentsFile = tempname;
    cf           = fopen(commentsFile, 'w');                             % Write the comments to a temp file
    fprintf(cf, '%s', comments);
    fclose(cf);
	comments     = cleanupcomment(comments);                             % Remove all new line char
	comments     = ['"' comments '"'];                                   % Quote the comments
	command      = ['ci -q -t"' commentsFile '" -m' comments];             % Building the command string.
	
	if (isempty(lock))
		lock     = 'off';
	else
		lock     = lock{1};                                              % De-referencing
	end
	if (strcmp(lock, 'on'))
		command  = [command ' -l'];
	else
		command  = [command ' -u'];
	end
	
case 'checkout'
	if (~isempty(outputfile) & length(fileNames) > 1)
		error('Several files cannot be checkout to a one file');
	end

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
	if (isempty(force))
		force   = '';
	else
		force   = force{1};                                              % De-referencing
	end

	
	command      = 'co -q';                                              % Building the command string.
	if (strcmp(lock, 'on'))
		command  = [command ' -l'];
	else
		command  = [command ' -u'];
	end
	if (isempty(revision))
		command  = command;
	else
		command  = [command ' -r' revision];
	end
	if (isempty(force))
		command  = command;
	else
		command  = [command ' -f'];
	end
	if (isempty(outputfile))
		command  = command;
	else
		command  = [command ' -p > ' outputfile{1}];                    % SHOULD BE THE LAST OPTION AS REDIRECTING STD OUTPUT
	end
	
case 'undocheckout'
	command      = 'rcs -q -u';
end

[status, returnMessage] = dos([command ' ' files]);                     % Executing the command

if (strcmp(action, 'checkin'))                                          % Deleting the temp file
	delete(commentsFile);
end

if (~isempty(returnMessage))                                            % With quiet option RCS does not provide any output.
    error(returnMessage);                                               % Any output would mean error message.
end

if (strcmp(action, 'undocheckout'))
	checkout(fileNames, 'lock', 'off', 'force', 'on');
end
