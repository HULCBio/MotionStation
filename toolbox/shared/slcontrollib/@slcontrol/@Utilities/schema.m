function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:32:17 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('slcontrol');

% Construct class
c = schema.class( hCreateInPackage, 'Utilities' );

% Class properties
