function OptimInfo = optimize(this,hText)
% Runs response optimization.

% Author(s): P. Gahinet
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/11 00:46:18 $
if nargin==1
   hText = [];  % Display in command window
end

% Is the model loaded (RE: needed by checkSettings)?
LoadFlag = isempty(find(get_param(0,'Object'),'Name',this.Model));
if LoadFlag
   load_system(this.Model);
end

% Well-posed problem?
[hasTunedPar,hasCost,hasConstr] = checkSettings(this);
if ~hasTunedPar
   error('There are no parameters to optimize.')
elseif ~hasCost && ~hasConstr
   error('No constraint to satisfy or objective to optimize.')
end

% Create optimizer
switch this.OptimOptions.Algorithm;
   case 'fmincon'
      Optimizer = ResponseOptimizer.fmincon(this);
   case 'fminsearch'
      Optimizer = ResponseOptimizer.fminsearch(this);
   case 'lsqnonlin'
      error('LSQNONLIN is not supported in Simulink Response Optimization.')
   case 'patternsearch'
      Optimizer = ResponseOptimizer.patternsearch(this);
end

% Set info structure and output function
Optimizer.Info = struct(...
   'xMin',[],'xMax',[],'xScale',[],...
   'hasCost',hasCost,'hasConstr',hasConstr,'Display',hText);

% Change status to 'run' (see setFunction for side effects)
this.OptimStatus = 'run';

% Run optimization
sw = warning('off'); lw = lastwarn;
nrestart = 0;
status = -1;
while status~=1 && nrestart<=this.OptimOptions.Restarts && ...
      strcmp(this.OptimStatus,'run')
   if nrestart>0
      % Initialize with result from previous optimization
      initpar(this)
      if ~strcmp(Optimizer.Options.Display,'off')
         Optimizer.postMessage(sprintf('\nRestarting optimization...'),hText)
      end
   end
   OptimInfo = minimize(Optimizer);
   nrestart = nrestart+1;
   status = OptimInfo.ExitFlag;
end
warning(sw); lastwarn(lw)

% Sync up parameter dat with optimal X
Optimizer.syncProject(OptimInfo.X);

% Return to idle status
this.OptimStatus = 'idle';

% Display final parameter values
LocalDisplayFinal(this,hText)

% Clean up
if strcmp(this.OptimOptions.GradientType,'refined')
   try
      delete(Optimizer.Gradient)
   catch
      error('Error closing model %s.\n%s', Optimizer.Gradient.GradModel, lasterr);
   end
end

% Close model
if LoadFlag
   close_system(this.Model,0);
end

% ------------------------------------------------------------------------- %

function LocalDisplayFinal(this,hText)
% Display final parameter values
if ~strcmp(this.OptimOptions.Display,'off')
   for ct=1:length(this.Parameters)
      p = this.Parameters(ct);
      if any(p.Tuned(:))
         tmp = p.Value;
         str = strrep(evalc('tmp'),'tmp',p.Name);
         if isempty(hText)
            disp(str(1:end-1))
         else
            hText.append(str)
         end
      end
   end
end
