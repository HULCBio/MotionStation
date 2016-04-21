function dFC = evalconstrG(this,CostConstr,GradModel,x,j,xL,xR,Info)
% Evaluates cost variation induced by dxj by simulating gradient model.

%   $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:46:27 $
%   Copyright 1986-2004 The MathWorks, Inc.
Model = this.Model;
gammaL = xL(end);
gammaR = xR(end);
xx = x(1:end-1);  % parameters

% Find indices of optimized runs
if isempty(this.Runs)
   idxRuns = 1;
else
   idxRuns = find(this.Runs.Optimized);
end

% Create gradient data log if empty
if isempty(this.GradLog)
   % Cost -> cost variation, Constraint -> constraint variation
   this.GradLog = struct('X',cell(size(xx)),'Cost',[],'Constraint',[]);
end

% Simulate gradient model if data is not already cached
if ~isequal(this.GradLog(j).X,xx)
   %disp(sprintf('simulating to evaluate gradient cost/constr (j=%d)',j))
   this.GradLog(j).X = xx;
   [this.GradLog(j).Cost,this.GradLog(j).Constraint] = ...
      LocalSimFCG(this,gammaL,gammaR,GradModel,idxRuns,Info);
end

dFC = this.GradLog(j).(CostConstr);
   
%------------ Local Functions --------------------------------------

function [DCost,DConstr] = LocalSimFCG(this,gammaL,gammaR,GradModel,idxRuns,Info)
% Simulates model and evaluates constraint/cost
GradLog = getCurrentResponseG(this,GradModel,idxRuns);

% Evaluate costs/constraints for each run
CostSpecs = find(this.Specs,'Enable','on','CostEnable','on');
ConstrSpecs = find(this.Specs,'Enable','on','ConstrEnable','on');
DCost = zeros(0,1);
DConstr = zeros(0,1);

for ctr=1:length(idxRuns)
   idxr = idxRuns(ctr);
   FailedSim = (isempty(GradLog{idxr}));
   if ~FailedSim
      LogWho = who(GradLog{idxr},'all');
   end

   if Info.hasConstr
      % Evaluate constraints
      for ct=1:length(ConstrSpecs)
         C = ConstrSpecs(ct);
         % Get logged data
         if FailedSim
            % REVISIT: need to properly size y (nchannels)
            delta = zeros(size(evalconstr(C,NaN,0)));
         else
            LogName = C.SignalSource.LogID;
            DataL = utFindLog(GradLog{idxr},sprintf('%s_L',LogName),LogWho);
            [yL,tL] = utGetLogData(DataL);
            DataR = utFindLog(GradLog{idxr},sprintf('%s_R',LogName),LogWho);
            [yR,tR] = utGetLogData(DataR);
            delta = evalconstr(C,tR,yR,gammaR) - evalconstr(C,tL,yL,gammaL);
         end
         % Evaluate constraint
         DConstr = [DConstr ; delta];
      end
   end

   if Info.hasCost
      % Evaluate costs
      for ct=1:length(CostSpecs)
         F = CostSpecs(ct);
         % Get logged data
         if FailedSim
            % REVISIT: need to properly size y (nchannels)
            delta = zeros(size(evalconstr(F,NaN,0)));
         else
            LogName = F.SignalSource.LogID;
            DataL = utFindLog(GradLog{idxr},sprintf('%s_L',LogName),LogWho);
            [yL,tL] = utGetLogData(DataL);
            DataR = utFindLog(GradLog{idxr},sprintf('%s_R',LogName),LogWho);
            [yR,tR] = utGetLogData(DataR);
            delta = evalconstr(F,tR,yR,gammaR) - evalconstr(F,tL,yL,gammaL);
         end
         % Evaluate constraint
         DCost = [DCost ; delta];
      end
   end

end
