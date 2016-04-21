function pvcs(fileNames, arguments)
%PVCS   Version control actions using PVCS.
%   PVCS(FILENAMES, ARGUMENTS) Performs the requested action
%   with ARGUMENTS options (name/value pairs) as specified below.
%   FILENAMES must be the full path of the file or a cell array
%   of files. 
%
%   OPTIONS:
%      action - The version control action to be performed.
%         checkin
%         checkout
%	
%      lock - Locks the file.
%         on
%         off
%
%      view - Displays the file in the MATLAB command window, but
%      does not check it out.
%         on
%         off
%
%      configfile - Configuration file to the appropirate PVCS project.
%
%      revision - Performs the action on the specified revision. 
%
%      outputfile - Writes file to outputfile.
%
%    See also CHECKIN, CHECKOUT, UNDOCHECKOUT, CMOPTS, CUSTOMVERCTRL,
%    CLEARCASE, RCS, and SOURCESAFE.
%

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.12 $ $Date: 2002/03/23 02:52:33 $

action           = arguments(find(strcmp(arguments, 'action')), 2);       % Mandatory argument
lock             = arguments(find(strcmp(arguments, 'lock')), 2);         % Assumed as OFF for checkin and ON for checkout
comments         = arguments(find(strcmp(arguments, 'comments')), 2);     % Mandatory if checkin is the action 
revision         = arguments(find(strcmp(arguments, 'revision')), 2);
outputfile       = arguments(find(strcmp(arguments, 'outputfile')), 2);
force            = arguments(find(strcmp(arguments, 'force')), 2);

if (isempty(action))                                                      % Checking for mandatory arguements
	error('No action specified.');
else
	action       = action{1};                                             % De-referencing
end

files            = '';                                                    % Create space delimitted string of file names
for i = 1 : length(fileNames)
    files        = [files ' ' fileNames{i}];
end

command          = '';
switch action
case 'checkin'
	if (isempty(comments))                                                % Checking for mandatory arguments
		error('Comments not specified');
	else
		comments = comments{1};                                           % De-referencing
	end
	comments     = cleanupcomment(comments);                              % Remove all new line char
	comments     = ['"' comments '"'];                                    % Quote the comments
	command      = ['put -Q -T' comments ' -M' comments];                 % Building the command string.
	
	if (isempty(lock))
		lock     = 'off';
	else
		lock     = lock{1};                                               % De-referencing
	end
	if (strcmp(lock, 'on'))
		command  = [command ' -L'];
	else
		command  = [command ' -U'];
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
	
	command      = ['get -Q'];                                           % Building the command string.
	if (strcmp(lock, 'on'))
		command  = [command ' -L'];
	else
		command  = [command ' -U'];
	end
	if (isempty(revision))
		command  = command;
	else
		command  = [command ' -R' revision]; 
	end

	if (isempty(outputfile))
		command  = command;
	else
		command  = [command ' -P > ' outputfile{1}];                     % SHOULD BE THE LAST OPTION AS REDIRECTING STD OUTPUT
	end

case 'undocheckout'
	command      = ['vcs -Q -U'];
end

[status, returnMessage] = dos([command ' ' files]);                     % Executing the command

if (~isempty(returnMessage))                                            % With quit option PVCS does not provide any output.
    error(returnMessage);                                               % Any output would mean error message.
end

if (strcmp(action, 'undocheckout'))
    for i = 1 : length(fileNames)                                       % Delete the read-write version of the file.
        delete(fileNames{i});
    end
	checkout(fileNames, 'lock', 'off');
end