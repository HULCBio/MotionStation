function cs = rtwinconfigset(mdl)
%RTWINCONFIGSET Use default Real-Time Windows Target configuration set.
%
%   RTWINCONFIGSET(MDL) attaches the default Real-Time Windows Target 
%       configuration set to Simulink model MDL and sets it as the
%       active configuration set for the model.
%   CFGSET = RTWINCONFIGSET returns the default Real-Time Windows Target 
%       configuration set object that can be later attached to a model.

%   Copyright 1994-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/15 00:30:01 $  $Author: batserve $

% use the model config set or the default config set as a template
if nargin>0
  cs = copy(getActiveConfigSet(mdl));
else
  cs = Simulink.ConfigSet;
end

% change name and top-level parameters
cs.Name = 'RTWin';
set_param(cs, 'SimulationMode', 'external');

% modify "Solver" component only if it is variable step
if ~strcmpi(get_param(cs, 'SolverType'), 'Fixed-step')
  switch(get_param(cs, 'Solver'))
    case 'VariableStepDiscrete'
      slv = 'FixedStepDiscrete';
    case { 'ode23', 'ode23s', 'ode23t', 'ode23tb' }
      slv = 'ode3';
    otherwise
      slv = 'ode5';
  end
  set_param(cs, 'Solver', slv);
end

% modify "Data Import/Export" component
set_param(cs, 'LoadExternalInput', 'off');
set_param(cs, 'LoadInitialState', 'off');
set_param(cs, 'SaveFinalState', 'off');
set_param(cs, 'SaveOutput', 'off');
set_param(cs, 'SaveState', 'off');
set_param(cs, 'SaveTime',   'off' );

% modify "Optimization" component
% ... use defaults for all settings ...

% modify "Diagnostics" component
% ... use defaults for all settings ...

% modify "Hardware Implementation" component
slprivate('setHardwareDevice', getComponent(cs,'Hardware Implementation'), 'Production', '32-bit Real-Time Windows Target');

% modify Real-Time Workshop component
settings.TemplateMakefile = 'rtwin.tmf';
settings.MakeCommand      = 'make_rtw';
settings.Description      = 'Real-Time Windows Target';
cs.switchTarget('rtwin.tlc', settings);

% modify "Model Referencing" component
% ... use defaults for all settings ...

% modify "Stateflow Simulation" component
% ... use defaults for all settings ...


% return here if no model specified
if nargin==0
  return;
end

% return error if the model name is invalid or model not open
get_param(mdl,'handle');

% if the model has no continuous states, use "FixedStepDiscrete"
sizes = feval(mdl, [], [], [], 'sizes');
if sizes(1)==0
  set_param(cs, 'Solver', 'FixedStepDiscrete');
end

% attach the config set to the model and activate it
csname = get(cs,'Name');
if any(strcmp(getConfigSets(mdl), csname))
  warning('RTWIN:configsetexists', 'Configuration set "%s" is already attached to the model.\nUsing the existing configuration set.', csname);
else
  attachConfigSet(mdl, cs);
end
setActiveConfigSet(mdl, csname);

% clear unused output argument
if nargout==0
  clear cs;
end
