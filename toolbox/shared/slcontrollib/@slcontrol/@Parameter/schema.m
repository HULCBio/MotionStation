function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:55 $

% Construct class
c = schema.class(findpackage('slcontrol'), 'Parameter');

% Class properties
% Parameter name
p = schema.prop(c, 'Name', 'string');
p.AccessFlags.PublicSet = 'off';

% Parameter dimensions
p = schema.prop(c, 'Dimensions', 'MATLAB array');
p.AccessFlags.PublicSet = 'off';
p.SetFunction = @LocalSetDimensions;
p.Visible = 'off';

% Parameter values
p = schema.prop(c, 'Value', 'MATLAB array');
p.SetFunction = @LocalSetValue;

% Initial guess
p = schema.prop(c, 'InitialGuess', 'MATLAB array');
p.SetFunction = @LocalSetValue;

% Minimum values
p = schema.prop(c, 'Minimum', 'MATLAB array');
p.SetFunction = @LocalSetValue;

% Maximum value
p = schema.prop(c, 'Maximum', 'MATLAB array');
p.SetFunction = @LocalSetValue;

% Typical value of the parameter
p = schema.prop(c, 'TypicalValue', 'MATLAB array');
p.SetFunction = @LocalSetValue;

% Referencing blocks
p = schema.prop(c, 'ReferencedBy', 'string vector');

% User defined description
p = schema.prop(c, 'Description', 'string');

% Object version number
p = schema.prop(c, 'Version', 'double');
p.AccessFlags.PublicSet = 'off';
p.FactoryValue = 1.0;
p.Visible = 'off';

% ----------------------------------------------------------------------------- %
function value = LocalSetDimensions(this, value)
if isnumeric(value) && isreal(value) && isvector(value)
   value = reshape(value,[1 numel(value)]);  % Make it a row vector.
else
   error('Dimensions must be set to a row vector of real numbers.');
end

% --------------------------------------------------------------------------- %
function value = LocalSetValue(this, value)
value = utCheckSize(this,value);
