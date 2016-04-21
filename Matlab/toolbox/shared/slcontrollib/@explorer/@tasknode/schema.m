function schema
% SCHEMA Defines project node class

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:58 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('explorer');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'node');
hCreateInPackage   = findpackage('explorer');

% Construct class
c = schema.class(hCreateInPackage, 'tasknode', hDeriveFromClass);

% --------------------------------------------------------------------------
p = schema.prop( c, 'Resources', 'string' );
p.FactoryValue = '';
p.AccessFlags.PublicSet = 'off';
p.Description = 'Name of the *.properties file containing the resource strings.';

p = schema.prop( c, 'MenuBar', 'javax.swing.JMenuBar');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Handle of the menu bar associated with a project';

p = schema.prop( c, 'ToolBar', 'javax.swing.JToolBar' );
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Handle of the tool bar associated with a project';
