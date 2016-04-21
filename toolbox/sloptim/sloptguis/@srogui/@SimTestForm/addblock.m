function addblock(this,blk,Csettings)
% Adds constraint associated with given Simulink block.

%   $Revision: 1.1.6.5 $ $Date: 2004/04/11 00:45:09 $
%   Copyright 1986-2004 The MathWorks, Inc.

% Create constraint
switch get_param(blk,'ReferenceBlock')
   case 'srolib/Signal Constraint'
      % Signal Constraint object
      if ishandle(Csettings)
         % Inherit constraint settings from original block
         C = Csettings;
      else
         % Create constraint
         C = ResponseOptimizer.SignalConstraint;
         % Initialize constraint data (Csettings = x focus)
         C.init(Csettings,[0 1.2]);
      end
      % Update signal source
      SignalSource = ResponseOptimizer.SimSource;
      SignalSource.LogID = get_param(blk,'LogID');
      C.SignalSource = SignalSource;
end

% Add constraint to spec
this.Specs = [this.Specs ; C];
