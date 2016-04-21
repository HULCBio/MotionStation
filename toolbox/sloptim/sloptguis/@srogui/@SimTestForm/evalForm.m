function Test = evalForm(this,ModelWS,ModelWSVars)
% Evaluates literal test specification in appropriate workspace.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.3 $ $Date: 2004/03/10 21:56:08 $
%   Copyright 1986-2004 The MathWorks, Inc.
Model = this.Model;
Test = ResponseOptimizer.SimTest;
Test.Enable = this.Enable;
Test.Optimized = this.Optimized;
Test.Model = Model;

% Validate model configuration and resolve port width
% Compile
OrigSettings = localApplySettings(Model,this.SimOptions);
try
   feval(Model,[],[],[],'compile');
   % Resolve signal size for all active constraints
   getPortDims(this)
   % Terminate
   feval(Model,[],[],[],'term');
   localRestoreSettings(Model,OrigSettings)
catch
   localRestoreSettings(Model,OrigSettings)
   rethrow(lasterror)
end
   
% Specs and runs
% RE: Make copy of Specs so that modifying constraints during optimization 
%     has no effect on result
if ~isempty(this.Specs)
   Test.Specs = copy(this.Specs);
end
if ~isempty(this.Runs)
   Test.Runs = evalForm(this.Runs,ModelWS,ModelWSVars);
end

% Options
Test.SimOptions = evalForm(this.SimOptions,this.Model,ModelWS,ModelWSVars);

% User-defined stop time
try
   [Test.StartTime,Test.StopTime] = getSimInterval(this);
catch
   error('Invalid StartTime or StopTime settings.')
end


%------------------ Local function ------------------

function s0 = localApplySettings(Model,s)
% Applies sim options to Model after saving current options
Dirty = get_param(Model,'Dirty');
s = get(s);
if strcmp(s.StartTime,'auto')
   s.StartTime = get_param(Model,'StartTime');
end
if strcmp(s.StopTime,'auto')
   s.StopTime = get_param(Model,'StopTime');
end
% g201041: compilation not supported in accel mode
s.SimulationMode = 'normal'; 
% Save original settings
Fields = fieldnames(s);
s0 = s;
s0.SimulationMode = get_param(Model,'SimulationMode');
for ct=1:length(Fields)
   f = Fields{ct};
   s0.(f) = get_param(Model,f);
   set_param(Model,f,s.(f))
end
s0.Dirty = Dirty;


function localRestoreSettings(Model,s0,Dirty)
% Restore original model options
Fields = fieldnames(s0);
for ct=1:length(Fields)
   f = Fields{ct};
   set_param(Model,f,s0.(f))
end
   


