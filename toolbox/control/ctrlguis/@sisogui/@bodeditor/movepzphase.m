function Y = movepzphase(Editor,MovedGroup,PZID,X,Y,Ts,G0,Y0,Format)
%MOVEPZPHASE  Updates pole/zero group to track mouse location (X,Y) in editor axes.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $ $Date: 2002/04/10 04:57:07 $

% RE: Expects freq. in rad/sec and phase in radians

Format = lower(Format(1));
isPole = strcmp(PZID,'Pole');
sgnpz = 1-2*isPole;  % 1 if zero, -1 otherwise

% Derive continuous-time value 
switch MovedGroup.Type
    
case {'Real','LeadLag'}
   % Real root: control natural frequency + root sign
   R0 = dom2ct(G0.(PZID),Ts);   % initial value of moved root
   if ~isreal(R0)
      % Can only happen for z=-1
      Y = Y0;
   else
      % Compute phase variation DPH at w=X for both R=X and R=-X, 
      % and select root value for which DPH is closest to Y-Y0
      R0 = dom2ct(R0,Ts);
      R = [-X,X];
      switch Format
      case 'z'
         resp = i*X - R;
      case 't'
         resp = 1 - i*X./R;
      end
      Dph = sgnpz * atan2(imag(resp),real(resp));
      % Pick root that best matches phase variation
      [junk,imin] = min(abs(Dph - (Y-Y0)));
      R = R(imin);
      Y = Y0 + Dph(imin);
      set(MovedGroup,PZID,ct2dom(R,Ts));
   end
   
case 'Complex'
   % Complex root: control natural frequency and sign of real part
   R0 = dom2ct(G0.(PZID),Ts);
   R0 = R0(1);     % initial value of moved root
   Zeta0 = real(R0)/abs(R0);
   R = X * ([1 -1] * Zeta0 + 1i * sqrt(1-Zeta0^2));
   % Estimate phase variation at w=X for both root values
   switch Format
   case 'z'
      resp = (i*X - R) .* (i*X - conj(R));
   case 't'
      resp = (1 - i*X./R) .* (1 - i*X./conj(R));
   end
   Dph = sgnpz * atan2(imag(resp),real(resp));
   % Keep root for which DPH is closest to Y-Y0
   [junk,imin] = min(abs(Dph - (Y-Y0)));
   R = R(imin);
   Y = Y0 + Dph(imin);
   set(MovedGroup,PZID,ct2dom([R;conj(R)],Ts));
      
case 'Notch'
   % Notch filter: control only natural freq 
   z0 = dom2ct(G0.Zero,Ts);
   p0 = dom2ct(G0.Pole,Ts);
   % Keep damping and set Wn = X
   WnR = X/abs(z0(1));  % ratio Wn/Wn0
   MovedGroup.Zero = ct2dom(z0*WnR,Ts);
   MovedGroup.Pole = ct2dom(p0*WnR,Ts);
   Y = Y0;
   
end


%----------------------- Local function ----------------------

function r = dom2ct(r,Ts)
% Get equivalent root value in continuous-time domain
if Ts
    r = log(r)/Ts;
end

function r = ct2dom(r,Ts)
% Get equivalent root value in continuous-time domain
if Ts
    r = exp(Ts*r);
end
