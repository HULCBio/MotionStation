function schema
%  SCHEMA  Defines properties for MPCmodels class

%  Author(s):  Larry Ricker
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.6 $ $Date: 2004/04/10 23:36:46 $

% Find parent package
pkg = findpackage('mpcnodes');

% Find parent classes
supclass = findclass(pkg, 'MPCnode');

% Register class (subclass) in package
c = schema.class(pkg, 'MPCModels', supclass);
pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% Properties
schema.prop(c,'Models','handle vector');  
schema.prop(c,'Labels','MATLAB array');
