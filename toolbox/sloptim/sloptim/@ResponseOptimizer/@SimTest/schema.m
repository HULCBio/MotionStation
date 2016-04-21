function schema
% Class definition for runtime, data-oriented Simulink Test.
%
%   A Simulink Test runs the model in a particular configuration
%   and evaluates the various design objectives for this run.

%   Author(s): Pascal Gahinet
%   $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:46:34 $
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('ResponseOptimizer'),'SimTest');
c.Description = 'Simulink test';

%%%%%%%%%%%%%%%%%%%%%%
%-- Public Properties
%%%%%%%%%%%%%%%%%%%%%%
p = schema.prop(c,'DataLog','MATLAB array');
p.Description = 'Simulation data log';
p.FactoryValue = struct('X',[],'Data',[],'Cost',[],'Constraint',[]);
p.AccessFlags.Serialize = 'off';

p = schema.prop(c,'GradLog','MATLAB array');  
% length(X)-by-1 struct array w/ fields X and Data
p.Description = 'Data log for gradient model';
p.AccessFlags.Serialize = 'off';

p = schema.prop(c,'Enable','on/off');  
p.Description = 'Enable/disable test';
p.FactoryValue = 'on';

p = schema.prop(c,'Optimized','on/off');  
p.Description = 'Include test in optimization';
p.FactoryValue = 'on';

p = schema.prop(c,'Specs','handle vector');  
p.Description = 'Design objectives';

p = schema.prop(c,'Runs','handle');  % @hds data set
p.Description = 'Parameter set used for batch optim/runs.';

% Simulink model
p = schema.prop(c,'Model','string');  
p.Description = 'Simulink model name';

% Simulink settings
p = schema.prop(c,'SimOptions','MATLAB array');
p.Description = 'Simulation settings';

% Start time for simulation
p = schema.prop(c,'StartTime','double');
p.Description = 'Simulation start time';
p.AccessFlags.Serialize = 'off';

% Stop time for simulation
p = schema.prop(c,'StopTime','double');
p.Description = 'Simulation stop time';
p.AccessFlags.Serialize = 'off';

% Version
p = schema.prop(c, 'Version', 'double');
p.FactoryValue = 1.0;
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.PublicSet = 'off';

% Events
schema.event(c,'ShowCurrent');
schema.event(c,'OptimStart');
schema.event(c,'OptimUpdate');
schema.event(c,'OptimStop');
