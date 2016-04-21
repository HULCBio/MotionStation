function schema
% SCHEMA Defines properties for @ExplorerPanelTreeManager class

% Author(s): John Glass
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:06 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('explorer');

% Construct class
c = schema.class( hCreateInPackage, 'ExplorerPanelTreeManager' );

% Properties
% Root node of the tree managed by this class
p = schema.prop(c, 'Root', 'handle');
set(p, 'AccessFlags.PublicSet', 'on');

% Handle of Java Tree Explorer panel
p = schema.prop(c, 'ExplorerPanel', ...
                'com.mathworks.toolbox.control.explorer.ExplorerPanel');
set(p, 'AccessFlags.PublicSet', 'on', ...
       'AccessFlags.Serialize', 'off');

% Structure for storing node specific Java handles.
p = schema.prop(c, 'Handles', 'MATLAB array');
set(p, 'AccessFlags.PublicSet', 'off', ...
       'AccessFlags.Serialize', 'off');

% Handles of permanent listeners.
p = schema.prop(c, 'Listeners', 'handle vector');
set(p, 'AccessFlags.PublicSet', 'on', ...
       'AccessFlags.Serialize', 'off');
