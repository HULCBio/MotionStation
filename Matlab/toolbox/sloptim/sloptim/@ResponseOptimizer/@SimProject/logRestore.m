function logRestore(this)
% Restores data logging info

%   $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:46:14 $
%   Copyright 1986-2004 The MathWorks, Inc.
if ~isempty(this.DataLoggingSettings) && ...
      ~strcmp(get_param(this.Model,'SimulationStatus'),'running')
   % RE: Second cause protects against errors when mutiple stop requests issued
   set(this.DataLoggingSettings.LogPorts,'DataLogging','on')
   set_param(this.Model,...
      'SignalLoggingName',this.DataLoggingSettings.LogVar,...
      'Dirty',this.DataLoggingSettings.Dirty)
end
