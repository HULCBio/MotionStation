function schema
% SCHEMA Defines properties for @TreeManager class

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:23 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('explorer');

% Construct class
c = schema.class( hCreateInPackage, 'TreeManager' );

% Properties
% Root node of the tree managed by this class
p = schema.prop(c, 'Root', 'handle');
p.AccessFlags.PublicSet = 'off';

% Handle of Java Tree Explorer frame
p = schema.prop(c, 'Explorer', ...
                'com.mathworks.toolbox.control.explorer.Explorer');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Handle of Java Tree Explorer panel
p = schema.prop(c, 'ExplorerPanel', ...
                'com.mathworks.toolbox.control.explorer.ExplorerPanel');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Dialogs
p = schema.prop(c, 'Dialogs', 'MATLAB array');  
p.FactoryValue = struct('Load',[],'Save',[]);
p.AccessFlags.Serialize = 'off';

% Structure for storing node specific Java handles.
p = schema.prop(c, 'Handles', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Handles of permanent listeners.
p = schema.prop(c, 'Listeners', 'handle vector');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
