function schema
%  SCHEMA  Defines properties for MPCSims class

%  Author(s): 
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.5 $ $Date: 2004/04/10 23:37:03 $

% Find parent package
pkg = findpackage('mpcnodes');

% Find parent classes
supclass = findclass(pkg, 'MPCnode');

% Register class (subclass) in package
c = schema.class(pkg, 'MPCSims', supclass);

pkg.JavaPackage  =  'com.mathworks.toolbox.mpc';

% Properties
schema.prop(c,'isEnabled', 'int32');
schema.prop(c,'CurrentScenario', 'string');

