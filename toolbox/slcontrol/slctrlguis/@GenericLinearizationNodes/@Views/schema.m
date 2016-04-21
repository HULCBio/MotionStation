function schema
%  SCHEMA  Defines properties for Views class

%  Author(s): John Glass
%  Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:36:14 $

%% Find parent package
pkg = findpackage('explorer');

%% Find parent class (superclass)
supclass = findclass(pkg, 'node');

%% Register class (subclass) in package
inpkg = findpackage('GenericLinearizationNodes');
c = schema.class(inpkg, 'Views', supclass);

%% Listener storage
p = schema.prop(c, 'ChildListListeners', 'MATLAB array');
p.AccessFlags.Serialize = 'off';

%% Properties
schema.prop(c, 'ViewTableData', 'MATLAB array');

%% Java element storage
p = schema.prop(c, 'ViewTableUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'ViewTableModelUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'NewViewButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
p = schema.prop(c, 'DeleteViewButtonUDD', 'MATLAB array');
p.AccessFlags.Serialize = 'off';
