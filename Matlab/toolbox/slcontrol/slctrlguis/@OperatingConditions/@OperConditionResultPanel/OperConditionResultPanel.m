function this = OperConditionResultPanel(Label)
%%  OPERCONDITIONRESULT Constructor for @OperConditionResultPanel class

%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2004 The MathWorks, Inc.
%	$Revision: 1.1.6.6 $  $Date: 2004/04/11 00:36:25 $

%% Create class instance
this = OperatingConditions.OperConditionResultPanel;

if nargin == 0
  % Call when reloading object
  return
end

this.Label = Label;
this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
this.AllowsChildren = 0;
this.Status = 'Operating points for a model.';
%% Set the icon
this.Icon = fullfile('toolbox', 'shared', ...
                            'slcontrollib','resources', 'plot_op_conditions.gif');
