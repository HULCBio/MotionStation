function [X,Y] = move(Constr,action,X,Y,X0,Y0)
%MOVE  Moves constraint
% 
%   [X0,Y0] = CONSTR.MOVE('init',X0,Y0) initialize the move. The 
%   pointer may be slightly moved to sit on the constraint edge
%   and thus eliminate distorsions due to patch thickness.
%
%   [X,Y] = CONSTR.MOVE('restrict',X,Y,X0,Y0) limits the displacement
%   to locations reachable by CONSTR.
%
%   STATUS = CONSTR.MOVE('update',X,Y,X0,Y0) moves the constraint.
%   For constraints indirectly driven by the mouse, the update is
%   based on a displacement (X0,Y0) -> (X,Y) for a similar constraint 
%   initially sitting at (X0,Y0).

%   Author(s): N. Hickey, P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.14 $  $Date: 2002/04/10 05:07:44 $

% RE: Incremental move is not practical because the constraint cannot
%     track arbitrary mouse motion (e.g., enter negative gain zone)

MagAxes = Constr.Parent;
XUnits = Constr.FrequencyUnits;
YUnits = Constr.MagnitudeUnits;
Ylinabs = strcmp(YUnits,'abs') & strcmp(get(MagAxes,'Yscale'),'linear');

switch action
case 'init'
   % Initialization
   if Ylinabs 
      % If the mouse is selecting this constraint, move pointer to (X0,Y(X0) 
      % to avoid distorsions due to patch thickness
      HostFig = MagAxes.Parent;
      if Constr.HG.Patch==hittest(HostFig)
         Y = unitconv(Constr.Magnitude(1),'dB','abs') * ...
            (X/unitconv(Constr.Frequency(1),'rad/sec',XUnits))^(Constr.slope/20);
         % Move pointer to new (X0,Y0)
         moveptr(MagAxes,'init')
         moveptr(MagAxes,'move',X,Y);
      end
   end
   % Model is
   %    Freq = Freq0 * (X/X0)
   %    Mag = Mag0 + (YdB-Y0dB)
   % RE: Don't save (X0,Y0) here as it may be modified by other selected 
   %     constraint during init
   Constr.AppData = struct('Freq0',Constr.Frequency,'Mag0',Constr.Magnitude);
   
case 'restrict'
   % Restrict displacement (X0,Y0)->(X,Y) to account for constraints on mag and freq.
   if strcmp(get(MagAxes,'Xscale'),'linear')
      X = max(X,1e-3*max(get(MagAxes,'Xlim')));  % prevent negative freq
   end
   if Constr.Ts
      X = min(X,(X0/Constr.AppData.Freq0(2))*pi/Constr.Ts);  % stay left of Nyquist freq
   end
   if Ylinabs
      Y = max(Y,1e-3*max(get(MagAxes,'Ylim')));  % prevent negative gain
   end
   
case 'update'
   % Update frequency, preserving its X extent in decades
   Constr.Frequency = Constr.AppData.Freq0 * (X/X0);
   
   % Update magnitude (in dB). 
   Constr.Magnitude = Constr.AppData.Mag0 + diff(unitconv([Y0 Y],YUnits,'dB'));
   
   % Update graphics and notify observers
   update(Constr)
   
   % Status
   Freqs = unitconv(Constr.Frequency,'rad/sec',XUnits);
   LocStr = sprintf('Current location:  from %0.3g to %0.3g %s',Freqs(1),Freqs(2),XUnits);
   X = sprintf('Move constraint to desired location and release the mouse.\n%s',LocStr); 
   
end