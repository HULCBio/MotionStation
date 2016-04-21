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
%   $Revision: 1.7 $  $Date: 2002/04/10 05:10:56 $

PlotAxes = Constr.Parent;

switch action
case 'init'
   % Initialization
   % If the mouse is selecting this constraint, move pointer to constraint edge 
   HostFig = PlotAxes.Parent;
   Zeta = Constr.Damping;
   if any(Constr.HG.Patch==hittest(HostFig))
      if Constr.Ts
         z = exp((-Zeta+1i*sqrt(1-Zeta^2))*abs(log(X+1i*Y)));
         X = real(z);   
         Y = sign(Y) * abs(imag(z));
      else
         rho = sqrt(X^2+Y^2);
         X = -Zeta * rho;
         Y = sign(Y) * sqrt(1-Zeta^2) * rho;
      end
      % Move pointer to new (X0,Y0)
      moveptr(PlotAxes,'init')
      moveptr(PlotAxes,'move',X,Y);
   end
   
   % Model is
   %   Ts = 0:  Zeta = Zeta0 * f(X,Y)/f(X0,Y0)  where f(X,Y) = cos(atan2(|Y|,|X|))
   %   Ts > 0:  Zeta = Zeta0 * f(X,Y)/f(X0,Y0)  where f(X,Y) = -real(log(X+jY))/abs(log(X+jY))
   %            (uses Zeta = -real(log(z))/abs(log(z)) for z=X+jY)
   Constr.AppData = struct('InitParam',Zeta); 
   
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
      X = min(X,0);
   end
   
case 'update'
   % Update settling time
   if Constr.Ts
      z = log([X0+1i*Y0,X+1i*Y]);
      f = -real(z)./abs(z);
   else
      f = cos(atan2(abs([Y0 Y]),abs([X0 X])));
   end
   Constr.Damping = Constr.AppData.InitParam * f(2)/f(1);
   
   % Update graphics and notify observers
   update(Constr)
   
   % Status
   if strcmpi(Constr.Format,'damping')
      LocStr = sprintf('Min. damping: %0.3g (max. overshoot: %0.3g %s).',...
         Constr.Damping,Constr.overshoot,'%');
   else
      LocStr = sprintf('Max. overshoot: %0.3g %s (min. damping: %0.3g).',...
         Constr.overshoot,'%',Constr.Damping);
   end
   X = sprintf('Move constraint to adjust damping/overshoot bound and release the mouse.\n%s',LocStr); 
   
end