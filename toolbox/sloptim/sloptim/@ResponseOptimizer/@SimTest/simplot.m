function simplot(this,Project)
% Collects data and issues request for plotting current response.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:46:35 $

% Initialize data logging settings
logSave(Project)

% Get data
try
   getCurrentResponse(this)
catch
   errordlg(utGetLastError,'Simulation Error','modal')
   return
end

% Restore data logging settings
logRestore(Project)

% Notify related constraint editors to update their plots
E = ctrluis.dataevent(this,'ShowCurrent',this.DataLog);
this.send('ShowCurrent',E)
