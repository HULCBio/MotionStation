function schema
% Literal specifications for tuned parameter.
%
% Used in dialog for defining parameter bounds, initial guess, and scaling.
% Because all specified data is literal (strings), there are no truncation 
% issues when using this object in dialogs.

% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:44:14 $
c = schema.class(findpackage('srogui'),'ParameterForm');

% Class properties
% Parameter name
schema.prop(c, 'Name', 'string');

% User defined description
schema.prop(c, 'Description', 'string');

% Parameter values
schema.prop(c, 'Value', 'string');

% Typical value of the parameter
schema.prop(c, 'TypicalValue', 'string');

% Initial guess
schema.prop(c, 'InitialGuess', 'string');

% Minimum values
schema.prop(c, 'Minimum', 'string');

% Maximum value
schema.prop(c, 'Maximum', 'string');

% Referencing blocks
schema.prop(c, 'ReferencedBy', 'string vector');

% Tuned flag
p = schema.prop(c, 'Tuned', 'string');
p.FactoryValue = 'true';

% Object version number
p = schema.prop(c, 'Version', 'double');
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 1.0;
