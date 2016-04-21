function this = MPCControllers(varargin)
%  MPCCONTROLLERS Constructor for @MPCControllers class

%  Author(s): 
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.6 $ $Date: 2004/04/10 23:35:54 $

% Create class instance
this = mpcnodes.MPCControllers;
this.Label = 'Controllers';
this.Editable = false;
this.AllowsChildren = true;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.CurrentController = '';

this.icon = fullfile('toolbox','mpc','mpcutils','mpc_controller_folder.gif');
this.setInitial;
