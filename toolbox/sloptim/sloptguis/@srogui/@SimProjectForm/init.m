function init(this,Model,SkipSpecFlag)
% Initializes literal project and adds specs for all SRO blocks 
% in the specified model.

%   $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:45:01 $
%   Copyright 1986-2004 The MathWorks, Inc.
this.Model = Model;
this.OptimOptions = srogui.OptimOptionForm;

% Simulation options
SimOpt = slcontrol.SimOptionForm;
SimOpt.initialize(Model);

% Create test
Test = srogui.SimTestForm;
Test.Model = Model;
Test.SimOptions = SimOpt;
this.Tests = Test;

% Add one spec per SRO block in model
if nargin<3
   % Find all SRO blocks
   SROBlocks = find_system(Model,'FollowLinks','on','LookUnderMasks','all',...
      'RegExp','on','BlockType','SubSystem','LogID','SRO_DataLog_\d');

   % Find start/stop times
   [StartTime,StopTime,Fail] = utGetSimInterval(Model,'finite');
   if Fail
      % RE: Cannot happen when opening block dialog
      %     (trapped by Simulink before)
      error('Could not evaluate model''s start or stop time.')
   end
   XFocus = [StartTime StopTime];

   % Create on constraint per block
   for ct=1:length(SROBlocks)
      % Determine signal name if any
      blk = SROBlocks{ct};
      h = get_param(blk,'PortHandles');
      SignalName = get_param(h.Inport,'Name');
      % Create source object
      SignalSource = ResponseOptimizer.SimSource;
      SignalSource.Name = SignalName;
      SignalSource.LogID = get_param(blk,'LogID');
      % Create constraint
      C = ResponseOptimizer.SignalConstraint;
      C.SignalSource = SignalSource;
      % Initialize constraint data
      C.init(XFocus,[0 1.2]);
      % Add constraint to spec
      Test.Specs = [Test.Specs ; C];
   end
end
