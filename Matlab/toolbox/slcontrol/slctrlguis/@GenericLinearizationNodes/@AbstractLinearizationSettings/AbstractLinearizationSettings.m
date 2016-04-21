function this = AbstractLinearizationSettings(model,varargin)
%%  MODELLINEARIZATIONSETTINGS Constructor for @ModelLinearizationSettings class
%%
%%  Author(s): John Glass
%%  Revised:
%%  Copyright 1986-2004 The MathWorks, Inc.
%%	$Revision: 1.1.6.4 $  $Date: 2004/04/11 00:35:25 $

%% Create class instance
this = GenericLinearizationNodes.AbstractLinearizationSettings;
%% Create the node label
this.Label = 'Generic Linearization Node';
%% Node name is not editable
this.Editable = 0;
this.Icon     = fullfile(matlabroot, 'toolbox', 'shared', ...
                         'slcontrollib','resources', 'm.gif');

this.Handles = struct('Panels', [], 'Buttons', [], 'PopupMenuItems', []);
