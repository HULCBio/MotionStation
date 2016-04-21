function schema
%  SCHEMA  Defines properties for MPCmodel class

%  Author(s):  Larry Ricker
%  Revised:
%  Copyright 1986-2004 The MathWorks, Inc.
%  $Revision: 1.1.8.4 $ $Date: 2004/04/10 23:36:35 $

% Register class in package
pkg = findpackage('mpcnodes');
supclass = findclass(pkg, 'MPCnode');

c = schema.class(pkg, 'MPCModel', supclass);

% Properties
schema.prop(c,'Imported','string');
% LTI model
schema.prop(c, 'Model','MATLAB array');
% Model name
schema.prop(c, 'Name','string');
schema.prop(c, 'Notes', 'string');
