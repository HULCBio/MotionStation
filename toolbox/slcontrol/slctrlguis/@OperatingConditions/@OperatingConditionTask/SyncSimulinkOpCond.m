function SyncSimulinkOpCond(setting);
%Syncs the IOs of the Simulink model.

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2003/12/04 02:37:44 $

%% Update the operating condition object
update(setting.OpSpecData);