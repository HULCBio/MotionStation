function this = Workspace(varargin)
% WORKSPACE Constructor for @Workspace object

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:30:25 $

% Create class instance
this = explorer.Workspace;
this.generic_listeners;

% Check input arguments
if nargin > 1
  this.Label = varargin{1};
else
  this.Label = 'Workspace';
end

this.AllowsChildren = true;
this.Editable  = false;
this.Icon      = fullfile( 'toolbox', 'shared', ...
                           'slcontrollib', 'resources', 'MatlabWorkspace.gif' );
this.Resources = 'com.mathworks.toolbox.control.resources.Explorer_Menus_Toolbars';
this.Status    = 'Workspace node.';
