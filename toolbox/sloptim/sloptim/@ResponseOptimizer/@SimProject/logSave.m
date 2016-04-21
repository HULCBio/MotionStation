function logSave(this)
% Saves initial data logging settings for Simulink model, and turn off all
% data logging ports.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:46:15 $
%   Copyright 1986-2003 The MathWorks, Inc.
Model = this.Model;

% Save model's data logging settings
LogPorts = find_system(Model,'FindAll','on','FollowLinks','on',...
   'LookUnderMasks','all','Type','port','PortType','outport',...
   'DataLogging','on');
LogVar = get_param(Model,'SignalLoggingName');
this.DataLoggingSettings = struct(...
   'LogPorts',LogPorts,...
   'LogVar',LogVar,...
   'Dirty',get_param(Model,'Dirty'));

set(this.DataLoggingSettings.LogPorts,'DataLogging','off')
set_param(Model,'SignalLoggingName','DataLog')
