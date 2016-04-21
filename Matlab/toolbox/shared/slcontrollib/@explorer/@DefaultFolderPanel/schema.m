function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:02 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('explorer');

% Construct class
c = schema.class( hCreateInPackage, 'DefaultFolderPanel' );

% Handle of the Java panel associated with this node
p = schema.prop( c, 'Panel', 'com.mathworks.toolbox.control.util.DefaultFolderPanel' );
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Handle of the UDD tree node
p = schema.prop( c, 'Node', 'handle' );
p.AccessFlags.PublicSet = 'off';

% Excluded object types from the node table
p = schema.prop( c, 'ExcludeList', 'string vector' );
p.AccessFlags.PublicSet = 'off';

% Structure for storing Java handles.
p = schema.prop( c, 'Handles', 'MATLAB array' );
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.Serialize = 'off';

% Handles of permanent listeners.
p = schema.prop( c, 'Listeners', 'handle vector' );
p.AccessFlags.PublicSet = 'off';
