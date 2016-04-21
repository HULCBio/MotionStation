function OL = getopenloop(LoopData)
%GETOPENLOOP  Computes normalized open-loop ZPK model.
%
%   The normalized open-loop is the open-loop transfer function 
%   where the ZPK gain of the compensator C is replaced by its sign.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.15 $  $Date: 2002/05/11 17:35:54 $

OL = LoopData.OpenLoop;
if isempty(LoopData.Plant.Model) | ~isequal(OL,[])
   % OpenLoop property contains uptodate normalized open-loop model
   return
end

% Recompute open loop if not available
CompData = LoopData.Compensator;
[ZeroC,PoleC] = getpz(CompData);
GainC = getzpkgain(CompData,'sign');  % normalization

switch LoopData.Configuration
case {1,2,3}
   % Construct open-loop ZPK data
   ZeroP = [LoopData.Plant.Zero ; LoopData.Sensor.Zero];
   PoleP = [LoopData.Plant.Pole ; LoopData.Sensor.Pole]; 
   GainP = LoopData.Plant.Gain * LoopData.Sensor.Gain;
   
case 4
   % The filter forms a minor loop
   % RE: Watch for cases where the minor loop cannot be closed (algebraic loop)
   MinorLoop = getminorloop(LoopData);
   if ~isfinite(MinorLoop)
      OL = zpk(NaN);  LoopData.OpenLoop = OL;  return
   else
      [ZeroP,PoleP,GainP] = zpkdata(MinorLoop,'v');
   end
end

% Construct open-loop ZPK data
Zero = [ZeroP ; ZeroC];
Pole = [PoleP ; PoleC]; 
Gain = (-LoopData.FeedbackSign) * GainP * GainC;

% Set property value
if Gain
   OL = zpk(Zero,Pole,Gain,LoopData.Ts);
else
   OL = zpk([],[],0,LoopData.Ts);  % no locus if loop gain is zero
end

% Store result in OpenLoop property to avoid recomputing it
LoopData.OpenLoop = OL;