function schema
%SCHEMA  Defines properties for @fminsearch class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2003/09/01 09:20:09 $

%% Find the package
pkg = findpackage('OptimizationObjects');

%% Find parent class (superclass)
supclass = findclass(pkg, 'lsqnonlin');

%% Register class
c = schema.class(pkg, 'fminsearch', supclass);