function OptimInfo = minimize(this)
% Solves constraint minimization problem associated with given optimizer.

% Author(s): P. Gahinet
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:46:45 $
hText = this.Info.Display;

% Param spec and data -> decision vector
v = par2var(this);
x0 = v.Initial;
xMin = v.Minimum;
xMax = v.Maximum;
this.Info.xMin = xMin;
this.Info.xMax = xMax;

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
      Options.OutputFcns = @(x,y,z) LocalOutputFcn(x,y,z,1,this);
      Options.TolFun = Options.TolCon;
      if this.Info.hasCost && ~strcmp(this.Options.Display,'off')
         this.postMessage(sprintf('\nPhase one: Finding a feasible solution...'),...
            hText)
      end
      % Header
      this.showIter('init',hText)
      % Minimize max(c)
      [x, fval, exitflag, output] = patternsearch(@(x) LocalFeas(x,this),...
         x0,[],[],[],[],xMin,xMax,Options);
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
   Options.OutputFcns = @(x,y,z) LocalOutputFcn(x,y,z,2,this);
   Options.TolFun = TolFun;
   if PhaseOne && ~strcmp(this.Options.Display,'off')
      this.postMessage(sprintf('\nPhase two: Minimizing tracking error...'),...
         hText)
   end
   % Header
   this.showIter('init',hText)
   % Minimize cost
   [x, fval, exitflag, output] = patternsearch(@(x) LocalCost(x,this),...
      x0,[],[],[],[],xMin,xMax,Options);
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


function [stop,options,optchanged] = ...
   LocalOutputFcn(state, options, stage, Phase, Optimizer)
% Used to plot progress and stop optimization
optchanged = false;
drawnow % force processing of any stop event
Proj = Optimizer.Project;
% Time to stop?
if Phase==1
   % Feasibility
   stop = strcmp(Proj.OptimStatus,'stop') || state.fval<=Optimizer.Options.TolCon;
else
   % Optimality
   stop = strcmp(Proj.OptimStatus,'stop');
end
% Displays
if strcmp(stage,'iter')
   % Update display
   Optimizer.showIter(stage,Optimizer.Info.Display,state)
   % Update progress plots
   if Phase==1 || ~stop
      % Resync project data with current best X
      Optimizer.syncProject(state.x);
      % Update plots
      for ct=1:length(Proj.Tests)
         optimUpdate(Proj.Tests(ct))
      end
   end
end
