function schema
%SCHEMA  Defines properties for @OperatingSpec class

%%  Author(s): John Glass
%%  Revised:
%% Copyright 1986-2004 The MathWorks, Inc.
%% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:19 $

%% Find the package
pkg = findpackage('opcond');

%% Find parent class (superclass)
supclass = findclass(pkg, 'OperatingPoint');

%% Register class
c = schema.class(pkg, 'OperatingSpec',supclass);

%% Public attributes
schema.prop(c, 'Outputs', 'MATLAB array');        % Model Outputs