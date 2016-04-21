function schema

% SCHEMA  Defines properties for @importlti class

% Author(s): Larry Ricker
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.8.3 $ $Date: 2004/04/10 23:37:36 $

% Register class 
pkg = findpackage('mpcobjects');
c = schema.class(pkg, 'importlti');

pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';
c.JavaInterfaces = {'com.mathworks.toolbox.mpc.MPCimportObject'};

% Properties
   
% Source of model -- if empty, workspace.
schema.prop(c, 'modelsource','string');
% Path -- nonempty if source is a mat file
schema.prop(c, 'path','string');
% Model -- if empty, none was imported.
schema.prop(c, 'model','MATLAB array');
% Name of model
schema.prop(c, 'name','string');
% Handle of mpcbrowser object
schema.prop(c, 'browser','handle');
% Handle of LTIsummary object
schema.prop(c, 'summary','handle');
% MPCimportModel window Java handle
schema.prop(c, 'javahandle','com.mathworks.toolbox.mpc.MPCimportModel');
schema.prop(c, 'TypesAllowed', 'MATLAB array');
schema.prop(c, 'Tasks', 'MATLAB array');
schema.prop(c, 'SelectedRoot','handle');

% Methods
if isempty(javachk('jvm'))
  m = schema.method(c, 'javasend');
  s = m.Signature;
  s.varargin    = 'off';
  s.InputTypes  = {'handle','string','string','handle'};
  s.OutputTypes = {}; 
end
