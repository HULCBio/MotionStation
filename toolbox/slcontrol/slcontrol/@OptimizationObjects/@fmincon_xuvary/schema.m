function schema
%SCHEMA  Defines properties for @fmincon class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:35:08 $

%% Find the package
pkg = findpackage('OptimizationObjects');

%% Find parent class (superclass)
supclass = findclass(pkg, 'AbstractTrimOptimizer');

%% Register class
c = schema.class(pkg, 'fmincon_xuvary',supclass);