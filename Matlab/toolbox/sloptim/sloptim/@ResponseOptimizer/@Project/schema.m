function schema
% Generic Response Optimizer project (runtime data-oriented object).

%   Author(s): Kamesh Subbarao, P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('ResponseOptimizer'),'Project');
c.Description = 'Generic Response Optimization Project';

%%%%%%%%%%%%%%%%%%%%%%
%-- Public Properties
%%%%%%%%%%%%%%%%%%%%%%
p = schema.prop(c,'Name','string');
p.Description = 'Project name';

p = schema.prop(c,'Parameters','handle vector');  % vector of @Parameter objects
p.Description = 'Tuned parameters';

p = schema.prop(c,'OptimOptions','MATLAB array'); % @OptimOptions
p.Description = 'Optimizer settings';

p = schema.prop(c,'OptimStatus','string');
p.Description = 'Optimization status [{idle}|run|stop|error]';
p.SetFunction = @localManageState;
p.FactoryValue = 'idle';
p.AccessFlags.Serialize = 'off';

p = schema.prop(c,'Tests','handle vector');
p.Description = 'Tests or simulations to conduct as part of design optimization';


%%%%%%%%%%%%%%%%%%%%%%%%%%
%--- Private Properties
%%%%%%%%%%%%%%%%%%%%%%%%%%
% Version
p = schema.prop(c,'Version','double');
p.FactoryValue = 1.0;
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';

% Listeners
p = schema.prop(c,'Listeners','handle vector');
p.Description = 'Listeners';
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.PublicGet = 'off';
p.AccessFlags.Serialize = 'off';

%------------------ local functions --------------------

function NewState = localManageState(this,NewState)
% Manages state transitions
switch NewState
   case 'run'
      % Save data logging settings
      logSave(this)

      % Initialization tasks
      for ct=1:length(this.Tests)
         optimSetup(this.Tests(ct))
      end
      
   case 'idle'
      if any(strcmp(this.OptimStatus,{'run','stop'}))
         % Normal termination tasks
         for ct=1:length(this.Tests)
            optimCleanup(this.Tests(ct))
         end

         % Restore data logging settings
         logRestore(this)
      end
      
   case 'error'
      % Clean up after error
     logRestore(this)
      
end
