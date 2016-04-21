function NewLoc = movepz(Editor,PZGroup,PZID,X,Y,Ts)
%MOVEPZ  Updates pole/zero group to track mouse location (X,Y) in editor axes.

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.6 $ $Date: 2002/04/10 04:57:53 $

switch PZGroup.Type
case 'Real'
   % Real pole/zero
   set(PZGroup,PZID,X);
   NewLoc = X;
   
case 'Complex'
   % Complex pole/zero
   set(PZGroup,PZID,[X + 1i * abs(Y) ; X - 1i * abs(Y)]);
   NewLoc = X + 1i * Y;
   
case 'LeadLag'
   % Lead or lag network (s+tau1)/(s+tau2)  
   % Maintain stability
   if Ts
       X = X/max(1,abs(X));
   else
       X = min(0,X);  
   end
   set(PZGroup,PZID,X);
   NewLoc = X;
   
case 'Notch'
   % Notch filter. If R1 is the dragged root, the other root R2 moves 
   % on a constant damping ray and |R2| tracks |R1|.
   r1 = X + 1i * Y;
   [Wn,z1] = damp(r1,Ts);  % new natural freq and damping of moved root
   
   % Determine new value of the other root
   % RE: Enforce damping constraint |Zeta_zero/Zeta_pole|<=1
   if strcmp(PZID,'Pole')
      % Moving a pole: impose |z2/z1|<=1
      [junk,z2] = damp(PZGroup.Zero(1),Ts);  % current damping of other root
      z2 = sign(z2) * min(abs(z2),abs(z1));
      PZIDc = 'Zero';
  else
      % Moving a zero: impose |z1/z2|<=1
      [junk,z2] = damp(PZGroup.Pole(1),Ts);  % current damping of other root
      z2 = sign(z2) * max(abs(z2),abs(z1));
      PZIDc = 'Pole';
   end
   r2 = Wn * (-z2 + 1i * sqrt(1-z2^2));
   if Ts
      r2 = exp(r2*Ts);
   end
   
   % Update group data
   set(PZGroup,PZID,real(r1)+[1i;-1i]*abs(imag(r1)));
   set(PZGroup,PZIDc,real(r2)+[1i;-1i]*abs(imag(r2)));
   NewLoc = [r1 ; r2];
   
end


