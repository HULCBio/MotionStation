function this = MPCSim(Name)
%  Constructor for the MPCSim node

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2004/04/10 23:36:48 $

% Create class instance
this = mpcnodes.MPCSim;
if nargin == 0
    % Recreating during a load.  Just return
    return
end
this.icon = fullfile('toolbox','mpc','mpcutils','mpc_scenario_icon.gif');

this.Handles = struct('PopupMenuItems', []);

this.rLookAhead = false;
this.vLookAhead = false;
this.ClosedLoop = true;
this.ConstraintsEnforced = true;
this.Tend = '10';
this.setInitial;

this.SaveFields = {'Handles.Setpoints', ...
    'Handles.MeasDist', ...
    'Handles.UnMeasDist'};

this.label = Name;
