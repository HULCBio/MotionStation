function schema
%  SCHEMA  Defines properties for MPCControllers class

%  Author:  Larry Ricker
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.6 $ $Date: 2004/04/10 23:36:05 $

% Find parent package
pkg = findpackage('mpcnodes');

% Find parent class
supclass = findclass(pkg, 'MPCnode');

% Register class (subclass) in package
c = schema.class(pkg, 'MPCControllers', supclass);
pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% Properties
schema.prop(c, 'CurrentController', 'string');
schema.prop(c, 'Controllers', 'MATLAB array');
