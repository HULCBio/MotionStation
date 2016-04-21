function cmdispatch(command, file, dirty)
%CMDISPATCH Simulink/Stateflow version control access.
%   CMDISPATCH(COMMAND, FILE) performs a valid COMMAND
%   on FILE. If FILE is numeric, it must be a Stateflow 
%   machine id and is converted.  Otherwise it must be 
%   a valid file specification.
%   CMDISPATCH(COMMAND, FILE, DIRTY) performs a valid COMMAND
%   on FILE using the DIRTY flag.
%
%   CMDISPATCH works only for Simulink and Stateflow.
%
%   Most errors are handled here.  All others are thrown. 
%
%   See also CHECKIN, CHECKOUT, and UNDOCHECKOUT.
%

% Copyright 1998-2003 The MathWorks, Inc.
% $Revision: 1.9.4.2 $  $Date: 2004/04/10 23:34:50 $

% Is source control configured?
try
    issourcecontrolconfigured;
catch
	errordlg(lasterr, 'Error', 'modal'); 
  	return;
end

% Check to see if it is Stateflow or Simulink.
isSF = 0;
if (isnumeric(file)) % It is stateflow.
    % Find the file name from the machine id.
    isSF = 1;
    modelH = sf('get', file,'machine.simulinkModel');
    pathName = get_param(modelH, 'FileName');
    dirty = get_param(modelH, 'dirty');
else
    modelH = find_system(0, 'blockdiagramtype', 'model');
    pathName = file;
end

% OPERATE ON THE APPROPRIATE COMMAND.
% CHECKIN
if (strcmp(command, 'CHECKIN'))
    if (isSF)
        modelH = sf('get', file, 'machine.simulinkModel');
		lasterr(''); % Detect failure of sfsave.
        sfsave(modelH);
        if (~isempty(lasterr))
            return; % Stateflow handles this error.
        end
        pathName = get_param(modelH, 'FileName');
        if(isempty(pathName))
            return; % Cancel a save must have occurred.  Just return (successfully).
        end
    end
    checkinwin(pathName, 1);
    return;
end

% If dirty, see if the user wants to proceed.
if (exist('dirty') && strcmp(dirty, 'on'))
    userSelection = questdlg(['This model has changed.' char(10) ...  
            'If you proceed, you will lose your changes.' char(10) ...
            'Continue?'], ...
        'Source Control', 'Yes', 'No', 'No');
    if (strcmp(userSelection, 'No'))
        return;
    end
end

% CHECKOUT and UNDOCHECKOUT
switch (command)
case 'CHECKOUT'
    checkoutwin(pathName, 1);
case 'UNDOCHECKOUT'
    try
        undocheckout(pathName);
        sysName = get_param(modelH, 'Name');
        reloadsys(sysName);
    catch
		errordlg(lasterr, 'Error', 'modal'); 
      	return;
    end
otherwise
    error('Unknown command: %s.', command);
end

% end function cmdispatch(command, file, dirty) 

