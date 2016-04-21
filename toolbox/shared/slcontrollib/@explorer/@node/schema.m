function schema
% SCHEMA Defines properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:52 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('explorer');

% Construct class
c = schema.class( hCreateInPackage, 'node' );

% ---------------------------------------------------------------------------- %
p = schema.prop( c, 'Label', 'string' );
p.AccessFlags.PublicSet = 'on';
p.Description = 'Name of the node to be shown in the tree.';

p = schema.prop( c, 'AllowsChildren', 'bool' );
p.FactoryValue = false;
p.AccessFlags.PublicSet = 'off';
p.Description =  'Specifies whether the node is a leaf or folder.';

p = schema.prop( c, 'Editable', 'bool' );
p.FactoryValue = true;
p.AccessFlags.PublicSet = 'off';
p.Description = 'Specifies whether the node name is editable in the tree.';

p = schema.prop( c, 'Description', 'string' );
p.FactoryValue = '';
p.AccessFlags.PublicSet = 'on';
p.Description = 'Description of the node.';

p = schema.prop( c, 'Fields', 'MATLAB array' );
p.FactoryValue = [];
p.AccessFlags.PublicSet = 'on';
p.Description = 'User structure for storing node specific data.';

p = schema.prop( c, 'Icon', 'string' );
p.AccessFlags.PublicSet = 'off';
p.Description = 'Name of the image file containing the node icon.';

p = schema.prop( c, 'Status', 'string' );
p.FactoryValue =  '';
p.AccessFlags.PublicSet = 'on';
p.Description = 'Status string shown when this node is selected in the tree.';

% ---------------------------------------------------------------------------- %
p = schema.prop( c, 'Handles', 'MATLAB array' );
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Structure for storing node specific Java handles.';

p = schema.prop( c, 'Listeners', 'handle vector' );
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Handles of general purpose listeners.';

p = schema.prop( c, 'TreeListeners', 'handle vector' );
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Handles of tree node related listeners.';

% ---------------------------------------------------------------------------- %
p = schema.prop( c, 'Dialog', 'javax.swing.JComponent' );
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Handle of the Java dialog associated with this node';

p = schema.prop( c, 'PopupMenu', 'javax.swing.JPopupMenu' );
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Handle of the popup menu associated with this node.';

p = schema.prop( c, 'TreeNode', 'javax.swing.tree.DefaultMutableTreeNode' );
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';
p.Description = 'Handle of the Java tree node';

% ---------------------------------------------------------------------------- %
% Define events
% ---------------------------------------------------------------------------- %
% Generic event to notify listeners of node related changes.
% Use it with the firePropertyChange() method to attach data to it.
p = schema.event( c, 'PropertyChange' );
