function returnValue = sourcesafe(fileNames, arguments)
%SOURCESAFE Version control actions using Visual SourceSafe.
%   SOURCESAFE(FILENAMES, ARGUMENTS) Performs the requested action
%   with ARGUMENTS options (name/value pairs) as specified below.
%   FILENAMES must be the full path of the file or a cell array
%   of files. 
%
%   OPTIONS:
%      action - The version control action to be performed. 
%         checkin
%         checkout
%         unlock
%
%      force - Forces the action to take place. 
%         on
%         off
%
%      revision - Performs the action on the specified revision. 
%
%      outputfile - Writes file to outputfile.
%
%   See also CHECKIN, CHECKOUT, UNDOCHECKOUT, CMOPTS, CUSTOMVERCTRL,
%   CLEARCASE, PVCS, and RCS.
%

%   Copyright 1998-2003 The MathWorks, Inc.
%   $Revision: 1.12.4.2 $  $Date: 2004/04/10 23:34:52 $

action           = arguments(find(strcmp(arguments, 'action')), 2);      % Mandatory argument
lock             = arguments(find(strcmp(arguments, 'lock')), 2);        % Assumed as OFF for checkin and ON for checkout
comments         = arguments(find(strcmp(arguments, 'comments')), 2);    % Mandatory if checkin is the action 
revision         = arguments(find(strcmp(arguments, 'revision')), 2);
outputfile       = arguments(find(strcmp(arguments, 'outputfile')), 2);
if (isempty(action))                                                     % Checking for mandatory arguements
  error('No action specified.');
else
  action         = action{1};
end

import com.mathworks.services.*;
username         = ...
	char(Prefs.getStringPref(Prefs.EDITOR.concat(Prefs.SOURCE_CONTROL_SYSTEM).concat('SourceSafe.UserName'), ''));
password         = ...
	char(Prefs.getStringPref(Prefs.EDITOR.concat(Prefs.SOURCE_CONTROL_SYSTEM).concat('SourceSafe.Password'), ''));
databaseName     = ...
	char(Prefs.getStringPref(Prefs.EDITOR.concat(Prefs.SOURCE_CONTROL_SYSTEM).concat('SourceSafe.Database'), ''));
database         = actxserver('SourceSafe');                             % Create an activeX SourceSafe object.
try
  invoke(database, 'Open', databaseName, username, password);            % Open the default SourceSafe database
catch
  error('Sorry failed to open the default SourceSafe database');
end
rootProject      = get(database, 'VSSItem', '$/');

switch action
case 'checkin'
  if (isempty(comments))                                                 % Checking for mandatory arguments
    error('Comments not specified');
  else
    comments = comments{1};                                              % De-referencing
  end
  if (isempty(lock))
    lock     = 'off';
  else
    lock     = lock{1};                                                  % De-referencing
  end
  for i = 1 : size(fileNames) 
    file     = fileNames{i};
    vssitem  = locateFile(file, rootProject);                            % Locate the SourceSafe file object
    if (isempty(vssitem))
      vssitem = locateFile(fileparts(file), rootProject);                % Doing an Add
      if (isempty(vssitem))
        error('SourceSafe project %s not found',file);                % Project not found
      else
        invoke(vssitem, 'Add', file, comments);
      end
    else
      invoke(vssitem, 'Checkin', comments, file);
    end
    if (strcmp(lock, 'on'))
      invoke(vssitem, 'Checkout', file);                                 % To keep it locked
    end
    release(vssitem);                                                    % Clean up activeX object
  end
  
case 'checkout'
  if (~isempty(outputfile) && length(fileNames) > 1)
    error('Several files cannot be checkout to a one file');
  end
  if (isempty(lock))
    lock     = 'off';
  else
    lock     = lock{1};                                                  % De-referencing
  end
  for i = 1 : size(fileNames)
    file     = fileNames{i};
    vssitem  = locateFile(file, rootProject);                            % Locate the SourceSafe file object
    if (isempty(vssitem))                                                % If no SourceSafe object found it is assumed as a new item
      error('Not able to find SourceSafe object for %s', file);
    end
    if (isempty(revision))
      item = vssitem;
      if (strcmp(lock, 'on'))
        cmd = 'Checkout';
      else
        cmd = 'Get';
      end	
    else
      revision = revision{1};
      item     = get(vssitem, 'Version', revision);
      cmd      = 'Get';
      if (strcmp(lock, 'on'))
        warning('Previous revisions cannot be checked out. Performing a get instead');
      end	
      release(vssitem);
    end
    if (isempty(outputfile))
      outfile = file;
    else
      outfile = outputfile{1};
    end
    invoke(item, cmd, outfile);
    release(item);
  end
  
case 'undocheckout'
  for i = 1 : size(fileNames)
    file     = fileNames{i};
    vssitem  = locateFile(file, rootProject);
    if (isempty(vssitem))
      error('Not able to find SourceSafe object for %s', file);
    end
    invoke(vssitem, 'UndoCheckout', file);
    release(vssitem);
  end
end

release(database);
release(rootProject);



function ssitem = locateFile(localFile, ssproject)
% Locates the SourceSafe object for the given file in the given project heirarchy.

ssitem     = '';
localSpec  = get(ssproject, 'LocalSpec');
if (strcmpi(localSpec, localFile))
  ssitem = ssproject;
  return;
else
  ssType         = get(ssproject', 'Type');
  if (ssType == 0)                                                      % 1 for files and 0 for projects
    items      = get(ssproject, 'Items');
    for i = 1:double(get(items, 'Count'))
      item   = get(items, 'Item', i);
      lSpec  = get(item, 'LocalSpec');
      if (strcmpi(lSpec, localFile))
        ssitem = item;
        break;
      else
        ssitem = locateFile(localFile, item);
        if (isempty(ssitem))          
          continue;
        else
          break;
        end
      end
    end
  end
end