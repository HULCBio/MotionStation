function this = MPCModels(varargin)

% Constructor for MPCModels class

%  Author(s):  Larry Ricker
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.7 $ $Date: 2004/04/10 23:36:36 $

% Create class instance
this = mpcnodes.MPCModels;
if nargin == 0
    % Reloading.  Just return
    return
end
this.Label = varargin{1};
this.Editable = false;
this.Icon = fullfile('toolbox','mpc','mpcutils','mpc_models_icon.gif');
this.AllowsChildren = true; %jgo
this.Handles = struct('PopupMenuItems', [], 'UDDtable', []);
this.setInitial;
