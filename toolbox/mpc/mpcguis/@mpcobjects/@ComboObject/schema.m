function schema

% SCHEMA  Defines properties for @ComboObject class

% Author(s): Larry Ricker
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.

% Register class 
pkg = findpackage('mpcobjects');
c = schema.class(pkg, 'ComboObject');

pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';
c.JavaInterfaces = {'com.mathworks.toolbox.mpc.MPCComboObject'};

% Properties
   
% List window Java handle
schema.prop(c, 'Combo','com.mathworks.toolbox.mpc.MPCCombo');
% Current selection.  
schema.prop(c, 'SelectedItemObject', 'handle');
schema.prop(c, 'SelectedItemField','String');
% List data -- cell array of strings.
schema.prop(c, 'ListData', 'MATLAB array');

% Methods
if isempty(javachk('jvm'))
  m = schema.method(c, 'getItemAt');
  s = m.Signature;
  s.varargin    = 'off';
  s.InputTypes  = {'handle','java.lang.Integer'};
  s.OutputTypes = {'java.lang.String'}; 

  m1 = schema.method(c, 'getSelectedItem');
  s1 = m1.Signature;
  s1.varargin    = 'off';
  s1.InputTypes  = {'handle'};
  s1.OutputTypes = {'java.lang.String'}; 

  m2 = schema.method(c, 'setSelectedItem');
  s2 = m2.Signature;
  s2.varargin    = 'off';
  s2.InputTypes  = {'handle','java.lang.String'};
  s2.OutputTypes = {}; 

  m3 = schema.method(c, 'getCount');
  s3 = m3.Signature;
  s3.varargin    = 'off';
  s3.InputTypes  = {'handle'};
  s3.OutputTypes = {'java.lang.Integer'}; 
end