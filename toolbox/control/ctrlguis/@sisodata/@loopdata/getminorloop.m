function ML = getminorloop(LoopData)
%GETMINORLOOP  Computes minor-loop ZPK model formed by the filter in configuration 4.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/06/11 17:30:09 $

% Quick exit if minor-loop is uptodate
ML = LoopData.MinorLoop;
if isempty(LoopData.Plant.Model) | ~isequal(ML,[])
   return
end

% Recompute minor loop if not available
G = LoopData.Plant.Model;
H = LoopData.Sensor.Model;
F = zpk(LoopData.Filter);
try
   % Use state-space form by default
   ML = feedback(ss(G)*ss(H),ss(F),+1);
catch
   % Improper case or algebraic loop: try the TF form
   try
      % RE: this may still error out, e.g., for G=H=F=1
      ML = feedback(tf(G)*tf(H),tf(F),+1);
   catch
      LoopData.send('SingularInnerLoop')
      ML = ss(NaN);  LoopData.MinorLoop = ML;   return
   end
end

% Compute zero/pole/gain form (needed by fixedpz and getopenloop)
% RE: Do not convert directly SS to ZPK as SMINREAL may reduce the order of the 
%     inner closed loop (which changes the plant order as seen from outer loop)
[z,g] = zero(ML);
p = pole(ML);
ML = zpk(z,p,g,LoopData.Ts);

% Store result in OpenLoop property to avoid recomputing it
LoopData.MinorLoop = ML;

