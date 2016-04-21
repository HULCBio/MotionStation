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

%   Author(s): P. Gahinet
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $  $Date: 2002/04/10 05:10:26 $

PlotAxes = Constr.Parent;

switch action
case 'init'
   % Initialization
   % If the mouse is selecting this constraint, move pointer to constraint edge 
   HostFig = PlotAxes.Parent;
   if Constr.HG.Patch==hittest(HostFig)
      if Constr.Ts
         w0 = Constr.Ts * Constr.Frequency;
         phi = acos(min(1,-log(min(1,eps+X^2+Y^2))/2/w0));
         Z = exp(-w0*exp(1i*phi));  % curve's edge
         X = real(Z);   Y = sign(Y) * abs(imag(Z));
      else
         f = Constr.Frequency/(eps+sqrt(X^2+Y^2));
         X = X * f;   Y = Y * f;
      end
      % Move pointer to new (X0,Y0)
      moveptr(PlotAxes,'init')
      moveptr(PlotAxes,'move',X,Y);
   end
   
   % Model is
   %   Ts = 0:  w = w0 * sqrt(X^2+Y^2) / sqrt(X0^2+Y0^2)
   %   Ts > 0:  w = w0 * f(X,Y)/f(X0,Y0)  where  
   %              f(X,Y) = sqrt((log(X^2+Y^2)/2)^2 + atan2(Y,X)^2)
   Constr.AppData = struct('InitParam',Constr.Frequency); 
   
case 'restrict'
   % Restrict displacement (X0,Y0)->(X,Y) to account for constraints X<0
   if Constr.Ts
      % Impose X^2+Y^2<1
      tol2 = 1-sqrt(eps);
      u0 = [X0;Y0];       
      r0 = norm(u0);
      if X^2+Y^2>tol2,
         u = [X-X0;Y-Y0];
         t = max(real(roots([u'*u 2*u0'*u r0^2-tol2])));  % one real root in [0,1]
         X = X0 + t * u(1);
         Y = Y0 + t * u(2);
      end
   else
      % Impose X < -sqrt(eps)
      tol = -sqrt(eps);
      if X>tol
         Y = Y0 + (Y-Y0) * (tol-X0)/(X-X0);
         X = tol;
      end
   end
   
case 'update'
   % Update natural frequency
   if Constr.Ts
      f = sqrt((log([X0 X].^2+[Y0 Y].^2)/2).^2 + atan2([Y0 Y],[X0 X]).^2);
   else
      f = sqrt([X0 X].^2+[Y0 Y].^2);
   end
   Constr.Frequency = Constr.AppData.InitParam * f(2)/f(1);
   
   % Update graphics and notify observers
   update(Constr)
   
   % Status
   Type = Constr.Type;  Type(1) = upper(Type(1));
   LocStr = sprintf('%s bound on natural frequency: %0.3g %s.',...
      Type,unitconv(Constr.Frequency,'rad/sec',Constr.FrequencyUnits),Constr.FrequencyUnits);
   X = sprintf('Move constraint to adjust natural frequency bound and release the mouse.\n%s',LocStr); 
   
end