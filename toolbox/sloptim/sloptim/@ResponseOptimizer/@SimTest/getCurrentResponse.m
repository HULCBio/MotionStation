function RunLog = getCurrentResponse(this,idxRuns)
% Logs current response of Simulink model.

%   Author: P. Gahinet
%   $Revision: 1.1.6.6 $ $Date: 2004/04/11 00:46:28 $
%   Copyright 1986-2004 The MathWorks, Inc.
Model = this.Model;
nspec = length(this.Specs);

% Activate data logging ports for spec's constraints
hOutport = zeros(nspec,1);
for ct=1:nspec
   C = this.Specs(ct);
   % Find associated port
   hOutport(ct) = find_system(Model,...
      'FindAll','on','FollowLinks','on','LookUnderMasks','all',...
      'Type','port','PortType','outport',...
      'DataLoggingName',C.SignalSource.LogID);
end

% Enable data logging
set(hOutport,'DataLogging','on','TestPoint','on');

% Simulate model (log written to local DataLog variable)
ws = warning('off'); lw = lastwarn;
Tf = getSimTime(this);
if isempty(this.Runs)
   % Single (nominal) simulation
   try
      sim(Model,Tf,this.SimOptions);
   catch
      DataLog = [];
   end
   % Store it in DataLog
   RunLog = {DataLog};
else
   % Multi-run test
   % Initialize data log
   RunLog = cell(getGridSize(this.Runs));
   if nargin==1
      idxRuns = 1:numel(RunLog);
   end
   % Save current parameter values
   Params = getParNames(this.Runs);
   NomVals = utEvalParams(Model,Params);
   % Simulate for each trial value of uncertain parameters
   UncVals = NomVals;
   for ct=1:length(idxRuns)
      idxr = idxRuns(ct);
      % Assign values of uncertain parameters
      s = getsample(this.Runs,idxr,Params);
      for ctp=1:length(UncVals)
         UncVals(ctp).Value = s.(UncVals(ctp).Name);
      end
      utAssignParams(Model,UncVals)
      % Simulate
      try
         sim(Model,Tf,this.SimOptions);
         RunLog{idxr} = DataLog;
      end
   end
   % Restore original values
   utAssignParams(Model,NomVals)
end
warning(ws), lastwarn(lw)

% Deactivate data logging ports
set(hOutport,'DataLogging','off','TestPoint','off');
