function schema
% SCHEMA  Defines properties for @TableObject class

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2004/04/10 23:37:29 $

% Find parent package
pkg = findpackage('mpcobjects');

% Register class (subclass)
c = schema.class(pkg, 'TableObject');

pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';
c.JavaInterfaces = {'com.mathworks.toolbox.mpc.MPCTableObject'};

% Properties

schema.prop(c, 'Header','MATLAB array'); 
schema.prop(c, 'CellData','MATLAB array'); 
p = schema.prop(c, 'DataListener','handle');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'EditListener','handle'); 
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'SelectionListener','handle');
p.AccessFlags.Serialize = 'off';
schema.prop(c, 'ListenerEnabled', 'MATLAB array');
schema.prop(c, 'DataCheckFcn','MATLAB callback');
schema.prop(c, 'DataCheckArgs','MATLAB array');
p = schema.prop(c, 'Table','com.mathworks.toolbox.mpc.MPCTable'); % TableObject handle
p.AccessFlags.Serialize = 'off';
schema.prop(c, 'isEditable', 'MATLAB array');  % Vector:  true/false for each column
schema.prop(c, 'isString', 'MATLAB array');
schema.prop(c, 'selectedRow','int32');
p = schema.prop(c, 'CellEditor', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

% Private attributes
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicGet', 'on', 'AccessFlags.PublicSet', 'on', ...
    'AccessFlags.Serialize', 'off');

% method signatures

  m4 = schema.method(c, 'setCellDataAt');
  s4 = m4.Signature;
  s4.varargin    = 'off';
  s4.InputTypes  = {'handle','java.lang.Object','java.lang.Object','java.lang.Object'};
  s4.OutputTypes = {};

  m8 = schema.method(c, 'setSelectedRow');
  s8 = m8.Signature;
  s8.varargin    = 'off';
  s8.InputTypes  = {'handle','java.lang.Object'};
  s8.OutputTypes = {}; 
 
