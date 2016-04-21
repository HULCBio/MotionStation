function returnValue = clearcase(fileNames, arguments)
%CLEARCASE Version control actions using Clearcase.
%   CLEARCASE(FILENAMES, ARGUMENTS) Performs the requested action
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
%       force - Forces the action to take place.
%         on
%         off
%
%      revision - Performs the action on the specified revision.
%
%   See also CHECKIN, CHECKOUT, UNDOCHECKOUT, CMOPTS, CUSTOMVERCTRL,
%   RCS, PVCS, and SOURCESAFE.
%

%   Copyright 1998-2002 The MathWorks, Inc.
%   $Revision: 1.13 $ $Date: 2002/03/23 02:53:00 $

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Possible options
LOCKOPT					= '-reserved';
UNLOCKOPT				= '-unreserved';
FORCEOPT				= '-identical';
COMMENTSOPT				= '-c';
REVISIONOPT				= '-version';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Possible Commands
CHECKINCOMMAND 			= 'cleartool ci ';
CHECKINNEWCOMMAND		= 'cleartool mkelem -eltype file -ci ';
COMMAND				   	= '';

% Executing the command
returnValue             = ' ';
action                  = arguments{find(strcmp(arguments, 'action')), 2};

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% CHECKIN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if (strcmp(action, 'checkin'))
  % The dialog passes the comments as a cell array while the command
  % line would pass in as a char array, so converting everything to char.
  % Here I need two strings one with quotes around them, and the other with
  % no quotes.

  % Also if the comments has new line char, then some shell don't take that
  % so stripping those new line chars.
  comments              = arguments(find(strcmp(arguments, 'comments')), 2);
  if (isempty(comments))
	error('Comments not specified');
  else 
	comments            = comments{1};
  end
  comments              = ['"' cleanupcomment(comments) '"'];
  
  for (i = 1 : length(fileNames))
    [value, output]     = dos(['cleartool ls -short -vob_only ' fileNames{i}]);
    if isempty(findstr(output, fileNames{i}))
      CHECKINNEWCOMMAND = [CHECKINNEWCOMMAND COMMENTSOPT ' ' comments];
      [a, rV]           = dos([CHECKINNEWCOMMAND COMMAND ' ' fileNames{i}]);
      disp(rV);
      % Printing the output to the command line, as Clearcase does have
      % a silent option. Sorry.
    else
      CHECKINCOMMAND	= [CHECKINCOMMAND COMMENTSOPT ' ' comments];
      [a, rV]           = dos([CHECKINCOMMAND COMMAND ' ' fileNames{i}]);
      disp(rV );
      % Printing the output to the command line, as Clearcase does have
      % a silent option. Sorry.
    end
  end

  % Check for keep checkout option
  lock                  = '';
  try
    lock                = arguments{find(strcmp(arguments, 'lock')), 2};
  catch
    lock                = 'off';
  end
  if (strcmp(lock, 'on'))
    checkout(fileNames);
  end


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % CHECK-OUT
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elseif (strcmp(action, 'checkout'))
  outputfile            = arguments(find(strcmp(arguments, 'outputfile')), 2);
  
  if (~isempty(outputfile)) 
	if (length(fileNames) > 1)
	  error('Several files cannot be checked out to a single file');
	else
	  outputfile        = outputfile{1};
	  COMMAND           = [COMMAND ' -out "' outputfile '"'];
	end
  end
  
  lock                  = arguments{find(strcmp(arguments, 'lock')), 2};
  switch lock
  case 'on'
    COMMAND             = [COMMAND ' ' LOCKOPT];
  otherwise
    COMMAND             = [COMMAND ' ' UNLOCKOPT];
  end

  try
    revision            = arguments{find(strcmp(arguments, 'revision')), 2};
  catch
    revision            = '';
  end

  files                 = ' ';
  if (isempty(revision))
    % Looping through all the files
    for (i = 1 : length(fileNames))
      files             = [files ' ' fileNames{i}];
    end
    [a, rV]             = dos(['cleartool checkout -nc ' COMMAND ' ' files]);
    disp(rV);
    % Printing the output to the command line, as Clearcase does have
    % a silent option. Sorry.
  else
    % Looping through all the files
    for i = 1 : length(fileNames)
      files = [files ' ' fileNames{i}];
      COMMAND = [COMMAND ' ' REVISIONOPT  ' ' files revision];
      [a, rV] = dos(['cleartool checkout -nc ' COMMAND]);
      disp(rV);
      % Printing the output to the command line, as Clearcase does have
      % a silent option. Sorry.
      return;
    end
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % UNCHECK-OUT
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
  files = ' ';
  for i = 1 : length(fileNames)
    files = [files ' ' fileNames{i}];
  end
  [a, rV] = dos(['cleartool uncheckout -rm ' files]);
  disp(rV);
  % Printing the output to the command line, as Clearcase does have
  % a silent option. Sorry.
end


return;
