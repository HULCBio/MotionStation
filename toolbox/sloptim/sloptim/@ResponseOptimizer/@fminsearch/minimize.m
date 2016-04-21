function OptimInfo = minimize(this)
% Solves constraint minimization problem associated with given optimizer.

% Author(s): P. Gahinet
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:46:42 $
hText = this.Info.Display;

% Param spec and data -> decision vector
v = par2var(this);
x0 = v.Initial;
xMin = v.Minimum;
xMax = v.Maximum;
this.Info.xMin = xMin;
this.Info.xMax = xMax;
if length(x0)>1 && (any(isfinite(xMin)) || any(isfinite(xMax)))
   warning('Ignoring lower and upper bounds on the tuned parameters.')
end

% Options
Options = this.Options;
Options.Display = 'off';  % Never use built-in display
TolFun = Options.TolFun;

% Find feasible solution
PhaseOne = false;
if this.Info.hasConstr
   FeasX0 = (max(this.evalconstr([x0;0],0))<=Options.TolCon);
   if ~(this.Info.hasCost && FeasX0)
      % Skip if cost minimization problem with feasible X0
      PhaseOne = true;
      Options.OutputFcn = @(x,y,z) LocalOutputFcn(x,y,z,1,this);
      Options.TolFun = Options.TolCon;
      if this.Info.hasCost && ~strcmp(this.Options.Display,'off')
         this.postMessage(sprintf('\nPhase one: Finding a feasible solution...'),...
            hText)
      end
      % Minimization:
      %    min max(c(x))
      if length(x0)==1 && isfinite(xMin) && isfinite(xMax)
         % Use FMINBND for scalar + constrained problems
         % RE: Both bounds must be finite
         this.showIter('init',hText,1)
         [x, fval, exitflag, output] = ...
            fminbnd( @(x) LocalFeas(x,this), xMin, xMax, Options);
      else
         % Use FMINSEARCH
         this.showIter('init',hText,2)
         [x, fval, exitflag, output] = ...
            fminsearch( @(x) LocalFeas(x,this), x0, Options);
      end
      % Check outcome
      if fval>Options.TolCon
         this.showIter('done',hText,-2)
         OptimInfo = struct('Cost',Inf,'X',x,'ExitFlag',-2,'Iteration',output.iterations);
         return
      else
         this.showIter('done',hText,2)
         x0 = x;
      end
   end
end

% Optimize cost
if this.Info.hasCost
   Options.OutputFcn = @(x,y,z) LocalOutputFcn(x,y,z,2,this);
   Options.TolFun = TolFun;
   if PhaseOne && ~strcmp(this.Options.Display,'off')
      this.postMessage(sprintf('\nPhase two: Minimizing tracking error...'),...
         hText)
   end
   % Minimize cost
   if length(x0)==1 && isfinite(xMin) && isfinite(xMax)
      % Use FMINBND for scalar + constrained problems
      % RE: Both bounds must be finite
      this.showIter('init',hText,1)
      [x, fval, exitflag, output] = ...
         fminbnd( @(x) LocalCost(x,this), xMin, xMax, Options);
   else
      % Use FMINSEARCH
      this.showIter('init',hText,2)
      [x, fval, exitflag, output] = ...
         fminsearch( @(x) LocalCost(x,this), x0, Options);
   end
   % Display termination message
   this.showIter('done',hText,exitflag)
end

% Output
OptimInfo = struct('Cost',fval,'X',x,...
   'ExitFlag',exitflag,'Iteration',output.iterations);

% ------------------------------------------------------------------------- %

function F = LocalFeas(x, this)
% Computes max constraint violation, ignoring the slack gamma
F = max(this.evalconstr([x;0],0));


function F = LocalCost(x, this)
% Computes max constraint violation, ignoring the slack gamma
C = max(this.evalconstr([x;0],0));
if C>this.Options.TolCon
   F = Inf;
else
   F = sum(this.evalcost(x,0));
end


function stop = LocalOutputFcn(x, state, type, Phase, Optimizer)
% Used to plot progress and stop optimization
drawnow % force processing of any stop event
Proj = Optimizer.Project;
% Time to stop?
if Phase==1
   % Feasibility
   stop = strcmp(Proj.OptimStatus,'stop') || ...
      (~isempty(state.fval) && state.fval<=Optimizer.Options.TolCon);
else
   % Optimality
   stop = strcmp(Proj.OptimStatus,'stop');
end
% Displays
if strcmp(type,'iter')
   if Phase==1 || ~stop 
      % Resync project data with current best X
      Optimizer.syncProject(x);
      % Update progress plots
      for ct=1:length(Proj.Tests)
         optimUpdate(Proj.Tests(ct))
      end
   end
   % Update display
   Optimizer.showIter(type,Optimizer.Info.Display,state,x)
end


