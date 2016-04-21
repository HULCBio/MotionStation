function this = Project(parent, model, varargin)
% Project  Constructor for @Project object

% Author(s): John Glass, B. Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:30:15 $

% Create class instance
this = explorer.Project;

if nargin == 0
  % Call when reloading object
  return
end

% Check input arguments
if nargin > 2
  this.Label = varargin{1};
else
  this.Label = this.createDefaultName('New Project', parent);
end

% Set the initial date
this.DateModified = date;
this.Model = model;

% Set the node properties
this.AllowsChildren = true;
this.Icon = fullfile( 'toolbox', 'shared', 'slcontrollib', ...
                      'resources', 'SimulinkModelIcon.gif' );
this.Resources = 'com.mathworks.toolbox.control.resources.Explorer_Menus_Toolbars';
this.Status    = 'Project node.';
