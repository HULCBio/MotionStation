function Y = movepzmag(Editor,MovedGroup,PZID,X,Y,Ts,G0,Y0,Format)
%MOVEPZMAG  Updates pole/zero group to track mouse location (X,Y) in editor axes.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $ $Date: 2002/04/10 04:57:04 $

%  RE: * Dragging on the mag plot can't change root stability
%      * G0 contains initial p/z values for moved group
%      * Units are f = rad/sec and mag = abs

Format = lower(Format(1));
isPole = strcmp(PZID,'Pole');
sgnpz = 1-2*isPole;  % 1 if zero, -1 otherwise

% Update group data
switch MovedGroup.Type
    
case 'Real'
   % Real root
   % RE: Can't be s=0 or z=1!
   R0 = dom2ct(G0.(PZID),Ts);   % initial value of moved root
   if ~isreal(R0)
      % Can only happen for z=-1
      Y = Y0;
   else
      R = sign(R0) * X;   % new value
      set(MovedGroup,PZID,ct2dom(R,Ts));
      % Determine correct mag value Y by evaluating H0(s)/(s-X) or H0(s)/(1-s/X)
      % at s=jX and using |H0(jX)|=Y0
      switch Format
      case 'z'
         resp = 1i*X - R;
      case 't'
         resp = 1 - 1i*X/R;
      end
      Y = Y0 * abs(resp)^sgnpz;   
   end
   
case 'LeadLag'
    % Lead/lag group
    R0 = dom2ct(G0.(PZID),Ts);   % initial value of moved root
    if ~isreal(R0)
        % Can only happen for z=-1
        Y = Y0;
    else
        set(MovedGroup,PZID,ct2dom(sign(R0)*X,Ts));
        % Determine correct mag value Y
        R = dom2ct([MovedGroup.Zero;MovedGroup.Pole],Ts);
        switch Format  
        case 'z'
            resp = (1i*X - R(1))/(1i*X - R(2));  % new lead/lag response at w=X
        case 't'
            resp = (1 - 1i*X/R(1))/(1 - 1i*X/R(2));
        end
        Y = Y0 * abs(resp);
    end
   
case 'Complex'
   % Complex root (natural freq = X)
   R0 = dom2ct(G0.(PZID),Ts);
   R0 = R0(1);     % initial value of moved root
   sgnR0 = (real(R0)>0)-(real(R0)<=0);
   
   % Evaluating H(s) = H0(s)/(s-R)/(s-conj(R)) at s = j*X  for R = (Zeta,X) 
   % gives
   %     Y = Y0 * (2*zeta*X^2)^sgnpz
   % with sgnpz=1 if moved root is a zero, -1 otherwise. The formula becomes
   %     Y = Y0 * (2*zeta)^sgnpz
   % for the bode format. Solve for ZETA:
   switch Format
   case 'z'
      Xs = X^2;
   case 't'
      Xs = 1;
   end
   
   % New damping factor
   Zeta = (Y/Y0)^sgnpz / 2 / Xs;
   if Zeta>1,
      % RE: Zeta<=1 required to have complex roots
      Zeta = 1;
      Y = Y0 * (2 * Xs)^sgnpz;
   end
   
   R = X * (sgnR0 * Zeta + 1i * sqrt(1-Zeta) * sqrt(1+Zeta));  % new value
   set(MovedGroup,PZID,ct2dom([R;conj(R)],Ts));
   
case 'Notch'
   % Notch filter (s^2+2*ZetaZ*w0*s+w0^2)/(s^2+2*ZetaP*w0*s+w0^2)
   % Mag motion controls W0 and ZetaZ (ZetaP is fixed)
   
   % Evaluating H(s) = H0(s) * Notch(s) at s = j*X  gives
   %    Y = Y0 * abs(ZetaZ/ZetaP)
   [w0,ZetaZ] = damp(G0.Zero(1),Ts);   % initial zero damping
   [w0,ZetaP] = damp(G0.Pole(1),Ts);   % initial pole damping (fixed)  
   
   % Update zero damping
   sgnZetaZ = (ZetaZ>0)-(ZetaZ<=0);
   ZetaZ = sgnZetaZ * abs(ZetaP) * min(Y/Y0,1); 
   Y = Y0 * abs(ZetaZ/ZetaP);
   
   % Update notch data
   z = X * (-ZetaZ + 1i * sqrt(1-ZetaZ^2));
   p = X * (-ZetaP + 1i * sqrt(1-ZetaP^2));
   MovedGroup.Zero = ct2dom([z;conj(z)],Ts);
   MovedGroup.Pole = ct2dom([p;conj(p)],Ts);
   
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