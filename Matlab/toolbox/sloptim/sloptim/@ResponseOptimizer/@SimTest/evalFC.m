function FCVal = evalFC(this,CostConstr,x,j,Info)
% Evaluates cost or constraint vector.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:46:26 $
%   Copyright 1986-2004 The MathWorks, Inc.
Model = this.Model;
xx = x(1:end-1);  % parameters
gamma = x(end);   % slack
FCVal = zeros(0,1);

% Find indices of optimized runs
if isempty(this.Runs)
   idxRuns = 1;
else
   idxRuns = find(this.Runs.Optimized);
   if isempty(idxRuns)
      return
   end
end

% Get cost and constraint values at x
% RE: Optimized so that single simulation needed to evaluate 
%     both cost + constraints
if j==0
   % Constraint evaluation
   if ~isequal(this.DataLog.X,xx)
      % Simulate model at xx, log data, and compute constraint/cost
      %disp(sprintf('simulating to evaluate cost/constr (|x|=%.3g)',norm(xx)))
      this.DataLog.X = xx;
      [this.DataLog.Cost,this.DataLog.Constraint,this.DataLog.Data] = ...
         LocalSimFC(this,gamma,idxRuns,Info);
   end
   FCVal = real(this.DataLog.(CostConstr));
else
   % Constraint evaluation as part of gradient computation
   if isempty(this.GradLog)
      this.GradLog = struct('X',cell(length(xx),2),'Cost',[],'Constraint',[]);
   end
   idxLR = 1 + (j>0);
   j = abs(j);
   if ~isequal(this.GradLog(j,idxLR).X,xx)
      %disp(sprintf('simulating to evaluate gradient cost/constr (j=%d)',j))
      this.GradLog(j,idxLR).X = xx;
      [this.GradLog(j,idxLR).Cost,this.GradLog(j,idxLR).Constraint] = ...
         LocalSimFC(this,gamma,idxRuns,Info);
   end
   FCVal = this.GradLog(j,idxLR).(CostConstr);
end

%------------ Local Functions --------------------------------------

function [Cost,Constr,DataLog] = LocalSimFC(this,gamma,idxRuns,Info)
% Simulates model and evaluates constraint/cost
DataLog = getCurrentResponse(this,idxRuns);

% Evaluate costs/constraints for each run
CostSpecs = find(this.Specs,'Enable','on','CostEnable','on');
ConstrSpecs = find(this.Specs,'Enable','on','ConstrEnable','on');
Cost = zeros(0,1);
Constr = zeros(0,1);

for ctr=1:length(idxRuns)
   idxr = idxRuns(ctr);
   FailedSim = (isempty(DataLog{idxr}));
   if ~FailedSim
      LogWho = who(DataLog{idxr},'all');
   end

   if Info.hasConstr
      % Evaluate constraints
      for ct=1:length(ConstrSpecs)
         C = ConstrSpecs(ct);
         % Get logged data
         if FailedSim
            t = NaN;  y = [];
         else
            Log = utFindLog(DataLog{idxr},C.SignalSource.LogID,LogWho);
            [y,t] = utGetLogData(Log);
         end
         % Evaluate constraint
         Constr = [Constr ; evalconstr(C,t,y,gamma)];
      end
   end

   if Info.hasCost
      % Evaluate costs
      for ct=1:length(CostSpecs)
         F = CostSpecs(ct);
         % Get logged data
         if FailedSim
            t = NaN;  y = [];
        else
            Log = utFindLog(DataLog{idxr},F.SignalSource.LogID,LogWho);
            [y,t] = utGetLogData(Log);
         end
         % Evaluate constraint
         Cost = [Cost ; evalcost(F,t,y)];
      end
   end
end
