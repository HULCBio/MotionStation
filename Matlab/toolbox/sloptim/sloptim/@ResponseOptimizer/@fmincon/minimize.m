function OptimInfo = minimize(this)
% Solves constraint minimization problem associated with given optimizer.

% Author(s): P. Gahinet
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.7 $ $Date: 2004/04/11 00:46:38 $

% Param spec and data -> decision vector
v = par2var(this);
x0 = [v.Initial ; 0];
xMin = [v.Minimum ; 0];
xMax = [v.Maximum ; Inf];
xScale = [v.Typical ; 1];
this.Info.xMin = xMin;
this.Info.xMax = xMax;
this.Info.xScale = xScale;

% Setup
if this.Info.hasConstr
   ConstrFun = @LocalConstrFun;
else
   ConstrFun = [];
end
Options = this.Options;
Options.Display = 'off';  % Never use built-in display
Options.TypicalX = max(1,xScale); 
Options.OutputFcn = @LocalOutput;

% Startup display
this.showIter('init',this.Info.Display)
   
% Minimization:
%    min gamma over x,gamma subject to c(x,gamma)<=0, gamma>=0   
[x, fval, exitflag, output] = fmincon( @LocalCostFun, x0, ...
   [], [], [], [], xMin, xMax, ConstrFun, Options, this );

% Output
OptimInfo = struct('Cost',fval,'X',x,...
   'ExitFlag',exitflag,'Iteration',output.iterations);

% Termination message
this.showIter('done',this.Info.Display,exitflag)
   
% ------------------------------------------------------------------------- %

function stop = LocalOutput(x, state, type, Optimizer)
% Used to plot progress and stop optimization
drawnow % force processing of any stop event
Proj = Optimizer.Project;
stop = strcmp(Proj.OptimStatus,'stop');
if strcmp(type,'iter')
   if ~stop
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


function [F, G] = LocalCostFun(x, this)
% Computes cost function and its gradient
GradRequest = (nargout>1);

if this.Info.hasCost
   % Minimize objective sum(evalcost(Spec))
   % RE: Ignoring slack variable in this case
   F = sum(this.evalcost(x,0));
   if GradRequest
      if strcmp(this.Project.OptimOptions.GradientType,'basic')
         % Compute gradient by finite differencing
         G = this.numgrad('evalcost',x,this.Info);
      else
         % Compute gradient by simulation of gradient model
         G = this.simgrad('evalcostG',x,this.Info);
      end
      if isempty(G)
         G = zeros(length(x),1);
      else
         G = [sum(G,2) ; 0];
      end
   end
else
   nv = length(x);
   F = x(nv);  % slack
   G = [zeros(nv-1,1) ; 1];
end
% Update TypicalX
% RE: At major steps only to insulate TypicalX from large X tried during
%     line search
if GradRequest
   this.Info.xScale = max(this.Info.xScale,abs(x));
end


% ------------------------------------------------------------------------- %
function [C, Ceq, G, Geq] = LocalConstrFun(x, this)
% Evaluates nonlinear constraints and their gradient
nv = length(x);
if this.Info.hasCost
   % RE: Ignoring slack variable in this case
   x(nv) = 0;
end
C = this.evalconstr(x,0);
Ceq = [];

if nargout>2
   % Gradient wrt decision variables
   if strcmp(this.Project.OptimOptions.GradientType,'basic')
      % Compute gradient by finite differencing
      G = this.numgrad('evalconstr',x,this.Info);
   else
      % Compute gradient by simulation of gradient model
      G = this.simgrad('evalconstrG',x,this.Info);
   end
   % Add gradient wrt slack (saves 1-2 simulations / iter)
   if isempty(G)
      G = zeros(length(x),length(C));
   elseif this.Info.hasCost
      G = [G ; zeros(1,length(C))];
   else
      G = [G ; this.slackgrad(x)];
   end
   Geq = [];
end

