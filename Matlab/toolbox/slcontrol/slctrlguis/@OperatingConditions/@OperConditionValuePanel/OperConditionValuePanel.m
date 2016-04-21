function this = OperConditionValuePanel(OpPoint,Label)
%%  OperConditionValuePanel Constructor for @OperConditionValuePanel class

%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.7 $  $Date: 2004/04/11 00:36:33 $

%% Create class instance
this = OperatingConditions.OperConditionValuePanel;

if nargin == 0
  % Call when reloading object
  return
end

this.Label = Label;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 0;
this.Status = 'Operating point for a model.';
this.Description = 'Model operating point';
%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_op_conditions.gif');

%% Store the linearization operating condition results and settings
this.Model = OpPoint.model;
this.OpPoint = OpPoint;
