function schema

% SCHEMA  Defines properties for @mpcbrowser class

% Author(s): Larry Ricker
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2004/04/10 23:37:48 $

% Register class 
c = schema.class(findpackage('mpcobjects'), 'mpcbrowser');

pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';
c.JavaInterfaces = {'com.mathworks.toolbox.mpc.MPCbrowserObject'};

% Properties
   
% Path and file name. Empty will be inerpreted as workspace
schema.prop(c, 'filename','string');
% Structure array containing displayed information on variables
schema.prop(c, 'variables','MATLAB array');
% Cell array to filter the data types to be displayed (empty => no filter)
schema.prop(c, 'typesallowed','MATLAB array');
% MPCimportView Java handle
schema.prop(c, 'javahandle','com.mathworks.toolbox.mpc.MPCimportView');
% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'on', 'AccessFlags.PublicSet', 'on');
% events
schema.event(c,'rightmenuselect'); 

if isempty(javachk('jvm'))
  m = schema.method(c, 'javasend');
  s = m.Signature;
  s.varargin    = 'off';
  s.InputTypes  = {'handle','string','string'};
  s.OutputTypes = {}; 
  
end