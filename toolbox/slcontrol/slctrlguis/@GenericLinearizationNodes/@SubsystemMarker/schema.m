function schema
%SCHEMA  Defines properties for @SubsystemMarker class

%  Author(s): John Glass
%  Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:35:58 $

% Find parent package
pkg = findpackage('explorer');

% Find parent class (superclass)
supclass = findclass(pkg, 'tasknode');

% Register class (subclass) in package
inpkg = findpackage('GenericLinearizationNodes');
c = schema.class(inpkg, 'SubsystemMarker', supclass);

%%% User storable description of the state object
schema.prop(c, 'Name', 'string');             % User description
schema.prop(c, 'Blocks', 'MATLAB array');
p = schema.prop(c, 'BlockList', 'MATLAB array');
p.Visible = 'off';
