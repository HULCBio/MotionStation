function schema

% Copyright 2002 The MathWorks, Inc.

pk = findpackage('uiundo');
c  = schema.class(pk,'FunctionCommand',pk.findclass('AbstractCommand'));

% Properties
p(1) = schema.prop(c,'Function','MATLAB array');
p(2) = schema.prop(c,'Varargin','MATLAB array');
p(3) = schema.prop(c,'InverseFunction','MATLAB array');
p(4) = schema.prop(c,'InverseVarargin','MATLAB array');
