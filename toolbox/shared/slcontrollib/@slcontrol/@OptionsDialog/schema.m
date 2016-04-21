function schema
% SCHEMA Defines class properties

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:31:47 $

% Get handles of associated packages and classes
hCreateInPackage = findpackage('slcontrol');

% Construct class
c = schema.class( hCreateInPackage, 'OptionsDialog' );

% Properties
p = schema.prop( c, 'SimOptionForm', 'handle' );
p.AccessFlags.PublicSet = 'on';
p.Description = 'SimOptionForm object handle';

p = schema.prop( c, 'OptimOptionForm', 'handle' );
p.AccessFlags.PublicSet = 'on';
p.Description = 'OptimOptionForm object handle';

cls = 'com.mathworks.toolbox.control.settings.OptionsDialog';
p = schema.prop( c, 'Dialog', cls );
p.AccessFlags.PublicSet = 'off';
p.Description = 'Handle of the Java dialog associated with this object';

p = schema.prop( c, 'SimOptionHandles', 'MATLAB array' );
p.AccessFlags.PublicSet = 'off';

p = schema.prop( c, 'OptimOptionHandles', 'MATLAB array' );
p.AccessFlags.PublicSet = 'off';

p = schema.prop( c, 'Listeners', 'handle vector' );
p.AccessFlags.PublicSet = 'off';

p = schema.prop( c, 'VariableStepSolvers', 'string vector' );
p.FactoryValue =  { 'VariableStepDiscrete', 'ode45', 'ode23', ...
                    'ode113', 'ode15s', 'ode23s', 'ode23t', 'ode23tb' };
p.AccessFlags.PublicSet = 'off';
p.Description = 'Names of variable-step solvers from simset structure';

p = schema.prop( c, 'FixedStepSolvers', 'string vector' );
p.FactoryValue = { 'FixedStepDiscrete', 'ode5', 'ode4', ...
                   'ode3', 'ode2', 'ode1' };
p.AccessFlags.PublicSet = 'off';
p.Description = 'Names of fixed-step solvers from simset structure';
