function schema

% SCHEMA  Defines properties for @SliderObject class

%  Author:  Larry Ricker
%  Copyright 1986-2003 The MathWorks, Inc.
%  $Revision: 1.1.8.3 $ $Date: 2004/04/10 23:37:24 $

% Register class 
pkg = findpackage('mpcobjects');
c = schema.class(pkg, 'SliderObject');

pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';
c.JavaInterfaces = {'com.mathworks.toolbox.mpc.MPCSliderObject'};

% Properties
   
% Container panel's Java handle
schema.prop(c, 'Panel','com.mathworks.toolbox.mpc.MPCSlider');
% Slider's java handle
schema.prop(c, 'Slider', 'com.mathworks.mwswing.MJSlider');
% Edit box's java handle
schema.prop(c, 'TextField', 'com.mathworks.mwswing.MJTextField');
% Current value.  
schema.prop(c, 'Value', 'double');
% Min and Max values.
schema.prop(c, 'Minimum', 'double');
schema.prop(c, 'Maximum', 'double');
% Log/Linear scale
schema.prop(c, 'isLog', 'int32');
% Enabled/disabled state
schema.prop(c, 'isEnabled', 'int32');
% Listener waits for value to change
schema.prop(c, 'Listener', 'handle');
% Flag to enable listener action
schema.prop(c, 'enableListener', 'MATLAB array');

% Methods
if isempty(javachk('jvm'))
    
  m2 = schema.method(c, 'setStringValue');
  s2 = m2.Signature;
  s2.varargin    = 'off';
  s2.InputTypes  = {'handle','java.lang.String'};
  s2.OutputTypes = {}; 

  m3 = schema.method(c, 'setIntegerValue');
  s3 = m3.Signature;
  s3.varargin    = 'off';
  s3.InputTypes  = {'handle','java.lang.Integer'};
  s3.OutputTypes = {}; 
  
end