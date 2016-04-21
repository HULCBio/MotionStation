function this = MPCSims(varargin)
%  MPCSIMS Constructor for @MPCSims class

%  Author(s): Larry Ricker
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.6 $ $Date: 2004/04/10 23:36:56 $

% Create class instance
this = mpcnodes.MPCSims;
if nargin == 0
    return      % Recreating during a load
end
this.AllowsChildren = true;
this.Editable = false;
this.label = varargin{1};
this.icon = fullfile('toolbox','mpc','mpcutils','mpc_scenario_folder.gif');
this.Handles = struct('PopupMenuItems', []);
this.setInitial;
