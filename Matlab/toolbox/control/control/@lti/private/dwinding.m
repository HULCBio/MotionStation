function N = dwinding(z,p,k,Ts,Td,Wc)
%WINDING  Computes the counterclockwise winding number of the Nyquist contour.
%
%   N = DWINDING(Z,P,K,TS,TD,WC) computes the winding number N of
%   the Nyquist contour around (-1,0) for discrete-time systems.  
%   The model is given in ZPK format and TS and TD are the sample
%   time in second and the delay in number of sample periods.  
%   The vector WC contains the 0dB crossover frequencies in 
%   [-pi/Ts,pi/Ts].
%
%   See also ALLMARGIN.

%   Author(s): P.Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.1 $  $Date: 2002/05/22 19:13:10 $

% RE: Assumes that H(jw)~=-1 at the crossover frequencies 
%     (contour does not go through critical point)

% Shift poles on unit circle into unit disk (limit case for Nyquist criterion)
idxuc = find(abs(p)==1);
p(idxuc) = (1-1e3*eps)*p(idxuc);

% Add -Inf and Inf to Wc partition of the real line
Wc = Ts * Wc;   % normalized frequencies
Wc = [-pi,Wc(Wc>-pi & Wc<pi),pi];

% Compute total variation of Psi=phase(1+H(z)) where z=exp(jw)
dPsi = 0;
for ct=1:length(Wc)-1
   % Phase variation in [w1,w2]
   w1 = Wc(ct);   w2 = Wc(ct+1);  
   % Phase of H(jw) at w=w1,w2
   Phi1 = LocalGetPhase(z,p,k,Td,w1);
   Phi2 = LocalGetPhase(z,p,k,Td,w2);
   if w1==-pi
      PhiMod1 = 0;
   else
      PhiMod1 = mod(Phi1+pi,2*pi)-pi;  % phase of H(jw1) in (-pi,pi)
   end
   if w2==pi
      PhiMod2 = 0;
   else
      PhiMod2 = mod(Phi2+pi,2*pi)-pi;  % phase of H(jw2)  in (-pi,pi)
   end
   % Add [w1,w2] contribution to dPsi
   wm = (w1+w2)/2;
   zm = exp(1i*wm);
   if any(z==zm) || log2(abs(k))+sum(log2(abs(zm-z)))<sum(log2(abs(zm-p)))
      % Gain is <1 on [w1,w2]
      dPsi = dPsi + (PhiMod2-PhiMod1)/2;
   else
      % Gain is >1 on [w1,w2]
      dPsi = dPsi + Phi2-Phi1 - (PhiMod2-PhiMod1)/2;
   end
end

% Get winding number
N = round(dPsi/2/pi);


%--------------------- Local Functions --------------------

%%%%%%%%%%%%%%%%%
% LocalGetPhase %
%%%%%%%%%%%%%%%%%
function Phi = LocalGetPhase(z,p,k,Td,w)
% Estimate unwrapped phase of H(exp(j*w)) for some w in [-pi,pi]
zw = exp(1i*w);

% Zero contribution
rhoz = abs(z);
isStable = (rhoz<1);
thz1 = angle(z(isStable));
zPhi1 = w + atan2(sin(w-thz1),1./rhoz(isStable)-cos(w-thz1));
thz2 = angle(z(~isStable));
zPhi2 = pi-thz2 + atan2(sin(thz2-w),rhoz(~isStable)-cos(thz2-w));

% Pole contribution
rhop = abs(p);
isStable = (rhop<1);
thp1 = angle(p(isStable));
pPhi1 = w + atan2(sin(w-thp1),1./rhop(isStable)-cos(w-thp1));
thp2 = angle(p(~isStable));
pPhi2 = pi-thp2 + atan2(sin(thp2-w),rhop(~isStable)-cos(thp2-w));

% Unwrapped phase
Phi = atan2(0,k) + sum(zPhi1) + sum(zPhi2) - sum(pPhi1) - sum(pPhi2) - w*Td;
