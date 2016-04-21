function N = winding(z,p,k,Td,Wc)
%WINDING  Computes the counterclockwise winding number of the Nyquist contour.
%
%   N = WINDING(Z,P,K,TD,WC) computes the winding number N of
%   the Nyquist contour around (-1,0).  The model is given in 
%   ZPK format and TD is the time delay in seconds.  The vector
%   WC contains all the 0dB crossover frequencies in [-Inf,Inf].
%
%   See also ALLMARGIN.

%   Author(s): P.Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $ $

% RE: 1) Assumes H(jw)~=-1 at the crossover frequencies 
%        (contour does not go through critical point)
%     2) Cannot handle the case Td=0 and H(Inf) = Inf (improper)

reldeg = length(z)-length(p);
if Td>0 && (reldeg>0 || (reldeg==0 && abs(k)>=1))
   N = Inf;
   return
end

% Shift jw-axis poles into LHP (limit case for Nyquist criterion)
idxjw = find(real(p)==0);
p(idxjw) = p(idxjw) - 1e3*eps*max(1,abs(p(idxjw)));

% Add -Inf and Inf to Wc partition of the real line
Wc = [-Inf,Wc,Inf];

% Compute total variation of Psi=phase(1+H(s))
dPsi = 0;
for ct=1:length(Wc)-1
   % Compute phase variation dPsi on [w1,w2]
   w1 = Wc(ct);   w2 = Wc(ct+1);  
   % Phase of H(jw) at w=w1,w2
   Phi1 = LocalGetPhase(z,p,k,Td,w1);
   Phi2 = LocalGetPhase(z,p,k,Td,w2);
   if isinf(w1)
      PhiMod1 = 0;  % equivalent phase seen from (-1,0)
   else
      PhiMod1 = mod(Phi1+pi,2*pi)-pi;  % phase of H(jw1) in (-pi,pi)
   end
   if isinf(w2)
      PhiMod2 = 0;  % equivalent phase seen from (-1,0)
   else
      PhiMod2 = mod(Phi2+pi,2*pi)-pi;  % phase of H(jw2)  in (-pi,pi)
   end
   % Add [w1,w2] contribution to dPsi
   InfFreqs = (isinf(w1) || isinf(w2));
   jwm = 0.5i*(w1+w2);
   if (InfFreqs && (reldeg<0 || (reldeg==0 && abs(k)<1))) || ...
      (~InfFreqs && (any(jwm==z) || ...
         log2(abs(k))+sum(log2(abs(jwm-z)))<sum(log2(abs(jwm-p)))))
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
% Estimate unwrapped phase of H(jw)

% Compute each term's contribution. When w varies from -Inf to Inf, the
% phase of (jw-r) varies in [pi/2,3*pi/2] if real(r)>0, and in [pi/2,-pi/2] 
% if real(r)<0
zPhi = pi/2 + atan2(real(z),w-imag(z));
pPhi = pi/2 + atan2(real(p),w-imag(p));
Phi = atan2(0,k) + sum(zPhi) - sum(pPhi);
if Td>0
   % Watch for NaN's when Td=0 and w=inf
   Phi = Phi - w*Td;
end
