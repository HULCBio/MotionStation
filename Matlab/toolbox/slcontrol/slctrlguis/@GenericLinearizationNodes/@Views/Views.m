function this = Views(varargin)
%  Views Constructor for @Views class

%  Author(s): John Glass
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.6 $  $Date: 2004/04/11 00:36:10 $

%% Create class instance
this = GenericLinearizationNodes.Views;

if nargin == 0
    % Call when reloading object
    return
end

% Set the properties
this.Label = 'Custom Views';
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 1;
this.Status = 'All analysis views.';
%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_views_folder.gif');

%% Node name is not editable
this.Editable = 0;

% Add required components
nodes = this.getDefaultNodes;
for i = 1:size(nodes,1)
  this.addNode(nodes(i));
end
