function schema
% SCHEMA Defines class attributes for Workspace class

% Author(s): John Glass
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:31 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('explorer');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'tasknode');
hCreateInPackage   = findpackage('explorer');

% Construct class
c = schema.class(hCreateInPackage, 'Workspace', hDeriveFromClass);
