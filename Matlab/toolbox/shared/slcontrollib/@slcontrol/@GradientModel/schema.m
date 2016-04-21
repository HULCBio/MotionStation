function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:42 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('slcontrol');

% Construct class
c = schema.class( hCreateInPackage, 'GradientModel' );

% Class properties
% Name of model from which the gradient model will be created.
p = schema.prop(c, 'OrigModel', 'string');
set( p, 'AccessFlags.PublicSet', 'off' );

% Gradient model name.
p = schema.prop(c, 'GradModel', 'string');
set( p, 'AccessFlags.PublicSet', 'off' );

% Name of workspace variable to hold masked parameter values.
p = schema.prop(c, 'WSVariable', 'string');
set( p, 'AccessFlags.PublicSet', 'off' );

% Content of the workspace variable whose name is in WSVariable.
p = schema.prop(c, 'Variables', 'MATLAB array');
set( p, 'SetFunction', @SetVariables, ...
        'GetFunction', @GetVariables );

% Listeners
p = schema.prop(c, 'Listeners', 'handle vector');
set( p, 'AccessFlags.PublicSet', 'off' );

% --------------------------------------------------------------------------- %
% Any time the Variables property changes, the workspace Variable is updated.
function value = SetVariables(this, value)
if ~isempty( this.WSVariable )
  assignin( 'base', this.WSVariable, value ); % Store it in the workspace.
  value = [];                                 % Don't store it here.
end

% --------------------------------------------------------------------------- %
% Make sure somebody did not change the workspace variable directly.
function value = GetVariables(this, value)
if ~isempty( this.WSVariable )
  value = evalin( 'base', this.WSVariable, '[]' ); % Get it from the workspace.
end
