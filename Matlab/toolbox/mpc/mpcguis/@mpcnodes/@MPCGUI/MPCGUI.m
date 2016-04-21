function this = MPCGUI(varargin)
%  MPCGUI Constructor for @MPCGUI class

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.8 $ $Date: 2004/04/10 23:36:06 $

% Create class instance
this = mpcnodes.MPCGUI;
if nargin == 0
    % Reconstruction during a project load.  Just return
    return
end
this.icon = fullfile('toolbox','mpc','mpcutils','mpc_project_folder.gif');
this.Resources = 'com.mathworks.toolbox.mpc.resources.mpcgui';
this.AllowsChildren = true;
this.setInitial;
this.Reset = false;
this.SpecsChanged = false;
this.SimulinkProject = 0;
this.Dirty = 0;
this.label = varargin{1};
this.InData = cell(0,5);
this.OutData = cell(0,5);

if nargin >1
    this.MPCObject = varargin{2};
else
    this.MPCObject = [];
end

this.Handles = struct('PopupMenuItems', [], 'ImportLTI', []);
this.Sizes = zeros(1,7);

this.getMPCModels;
this.getMPCControllers;
this.getMPCSims;
