function schema
% Literal specification of Simulink Test.
%
%   A Simulink Test runs the model in a particular configuration
%   and evaluates the various design objectives for this run.

%   Author(s): Pascal Gahinet
%   $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:45:15 $
%   Copyright 1986-2003 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('srogui'),'SimTestForm');
c.Description = 'Literal specification of Simulink Test';

%%%%%%%%%%%%%%%%%%%%%%
%-- Public Properties
%%%%%%%%%%%%%%%%%%%%%%
p = schema.prop(c,'Enable','on/off');  
p.Description = 'Enable/disable test';
p.FactoryValue = 'on';

p = schema.prop(c,'Optimized','on/off');  
p.Description = 'Include test in optimization';
p.FactoryValue = 'on';

p = schema.prop(c,'Specs','handle vector');  
p.Description = 'Design objectives';

p = schema.prop(c,'Runs','handle');  % @UncertaintyForm subclass
p.Description = 'Specification of parameter variability for batch optimization.';

% Simulink model
p = schema.prop(c,'Model','string');  
p.Description = 'Simulink model name';

% Simulink settings
p = schema.prop(c,'SimOptions','handle');  % @SimOptionForm
p.Description = 'Simulation settings (literal specs)';

% Version
p = schema.prop(c, 'Version', 'double');
p.FactoryValue = 1.0;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

