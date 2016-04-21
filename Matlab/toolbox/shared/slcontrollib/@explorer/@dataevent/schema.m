function schema
% SCHEMA  Class definition for subclass of EVENTDATA to handle property names
%         and old/new event data.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:33 $

% Get handles of associated packages and classes
hDeriveFromPackage = findpackage('handle');
hDeriveFromClass   = findclass(hDeriveFromPackage, 'EventData');
hCreateInPackage   = findpackage('explorer');

% Construct class
c = schema.class(hCreateInPackage, 'dataevent', hDeriveFromClass);

% Define properties
p = schema.prop(c, 'propertyName', 'string');   % Name of property that changed
p = schema.prop(c, 'oldValue', 'MATLAB array'); % Old value of the property
p = schema.prop(c, 'newValue', 'MATLAB array'); % New  value of the property
