function schema
% SCHEMA Defines project node class

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:54 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('explorer');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'tasknode');
hCreateInPackage   = findpackage('explorer');

% Construct class
c = schema.class(hCreateInPackage, 'projectnode', hDeriveFromClass);

% --------------------------------------------------------------------------
p = schema.prop( c, 'Dirty', 'bool' );
p.FactoryValue = false;
p.AccessFlags.PublicSet = 'on';
p.Description = 'Tracks whether project has changed and needs to be resaved.';

p = schema.prop( c, 'SaveAs', 'string' );
p.FactoryValue = '';
p.AccessFlags.PublicSet = 'on';
p.Description = 'Project file name.';
