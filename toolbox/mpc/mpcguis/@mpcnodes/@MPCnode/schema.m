function schema
%  SCHEMA  Abstract class defining methods and properties for MPC nodes

%  Author:  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.6.3 $ $Date: 2004/04/10 23:37:11 $

% Register class (subclass) in package
pkg = findpackage('mpcnodes');
c = schema.class(pkg, 'MPCnode', ...
    findclass(findpackage('explorer'), 'node'));
pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% Properties
schema.prop(c, 'Created', 'string');
schema.prop(c, 'Updated', 'string');
schema.prop(c, 'Version', 'string');
schema.prop(c, 'SaveFields', 'MATLAB array');
schema.prop(c, 'SaveData', 'MATLAB array');
