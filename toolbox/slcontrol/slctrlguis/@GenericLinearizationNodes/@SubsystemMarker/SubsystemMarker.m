function this = SubsystemMarker(varargin)
%  SubsystemMarker Constructor for @SubsystemMarker class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.5 $  $Date: 2004/04/11 00:35:51 $

% Create class instance
this = GenericLinearizationNodes.SubsystemMarker;

if nargin == 0
  % Call when reloading object
  return
end

this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 1;

%% Node name is not editable
this.Editable = 0;
this.Resources = 'com.mathworks.toolbox.slcontrol.resources.SimulinkControlDesignerExplorer';

if nargin > 0
    this.Icon = fullfile('toolbox', 'slcontrol', ...
        'slctrlutil','resources', 'SimulinkWorkspace.gif');
else
    this.Icon = fullfile('toolbox', 'slcontrol', ...
        'slctrlutil','resources', 'SubSystemIcon.gif');
end
