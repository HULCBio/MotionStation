function RunLog = getCurrentResponseG(this,GradModel,idxRuns)
% Logs current response of gradient model

%   Author: P. Gahinet
%   $Revision: 1.1.6.4 $ $Date: 2004/04/11 00:46:29 $
%   Copyright 1986-2004 The MathWorks, Inc.
nspec = length(this.Specs);
LeftPorts = zeros(nspec,1);
RightPorts = zeros(nspec,1);

% Simulation options
SimOpts = this.SimOptions;
SimOpts.InitialState = [];  % read from grad. model

% Activate data logging ports for spec's constraints
for ct=1:nspec
   C = this.Specs(ct);
   % Data logging ports in Left subsystem
   LeftID = sprintf('%s_L',C.SignalSource.LogID);
   LeftPorts(ct) = find_system(GradModel,...
      'FindAll','on','FollowLinks','on','LookUnderMasks','all',...
      'Type','port','PortType','outport',...
      'DataLoggingName',LeftID);
   % Data logging ports in Right subsystem
   RightID = sprintf('%s_R',C.SignalSource.LogID);
   RightPorts(ct) = find_system(GradModel,...
      'FindAll','on','FollowLinks','on','LookUnderMasks','all',...
      'Type','port','PortType','outport',...
      'DataLoggingName',RightID);
end

% Enable logging
AllPorts = [LeftPorts;RightPorts];
set(AllPorts,'DataLogging','on','TestPoint','on');

% Simulate model (log written to local GradLog variable)
ws = warning('off'); lw = lastwarn;
Tf = getSimTime(this);
if isempty(this.Runs)
   % Single (nominal) simulation
   try
      sim(GradModel,Tf,SimOpts);
   catch
      GradLog = [];
   end
   % Store it in DataLog
   RunLog = {GradLog};
   
else
   % Multi-run test
   % Initialize data log
   RunLog = cell(getGridSize(this.Runs));
   if nargin==1
      idxRuns = 1:numel(RunLog);
   end
   % Save current parameter values
   Params = getParNames(this.Runs);
   NomVals = utEvalParams(GradModel,Params);
   % Simulate for each trial value of uncertain parameters
   UncVals = NomVals;
   for ct=1:length(idxRuns)
      idxr = idxRuns(ct);
      % Assign values of uncertain parameters
      s = getsample(this.Runs,idxr,Params);
      for ctp=1:length(UncVals)
         UncVals(ctp).Value = s.(UncVals(ctp).Name);
      end
      utAssignParams(GradModel,UncVals)
      % Simulate
      try
         sim(GradModel,Tf,SimOpts);
         RunLog{idxr} = GradLog;
      end
   end
   % Restore original values
   utAssignParams(GradModel,NomVals)
end
warning(ws), lastwarn(lw)

% Deactivate data logging ports
set(AllPorts,'DataLogging','off','TestPoint','off');
