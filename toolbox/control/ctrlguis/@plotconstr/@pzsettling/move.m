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
%   $Revision: 1.9 $  $Date: 2002/04/10 05:08:25 $

persistent AbsLogSettlingTimeThreshold
PlotAxes = Constr.Parent;

switch action
case 'init'
   % Initialization
   TbxPrefs = cstprefs.tbxprefs;
   AbsLogSettlingTimeThreshold = abs(log(TbxPrefs.SettlingTimeThreshold));
   % If the mouse is selecting this constraint, move pointer to constraint edge 
   HostFig = PlotAxes.Parent;
   if Constr.HG.Patch==hittest(HostFig)
      if Constr.Ts
         f = Constr.geometry/(eps+sqrt(X^2+Y^2));
         X = X * f;   Y = Y * f;
      else
         X = Constr.geometry;
      end
      % Move pointer to new (X0,Y0)
      moveptr(PlotAxes,'init')
      moveptr(PlotAxes,'move',X,Y);
   end
   
   % Model is
   %   alpha = alpha0 + X - X0
   %   rho = rho + sqrt(X^2+Y^2) - sqrt(X0^2+Y0^2)
   Constr.AppData = struct('InitParam',Constr.geometry); % alpha or rho=exp(alpha*Ts)
   
case 'restrict'
   % Restrict displacement (X0,Y0)->(X,Y) to account for constraints alpha<0 (rho<1)
   if Constr.Ts
      u0 = [X0;Y0];       
      r0 = norm(u0);
      rmax = 1 - Constr.AppData.InitParam + r0;  % >=r0
      if X^2+Y^2>rmax^2,
         u = [X-X0;Y-Y0];
         t = max(real(roots([u'*u 2*u0'*u r0^2-rmax^2])));  % one real root in [0,1]
         X = X0 + t * u(1);
         Y = Y0 + t * u(2);
      end
   else
      X = min(X,X0-Constr.AppData.InitParam);
   end
   
case 'update'
   % Update settling time
   if Constr.Ts
      rho = Constr.AppData.InitParam + sqrt(X^2+Y^2) - sqrt(X0^2+Y0^2);
      alpha = log(rho)/Constr.Ts;
   else
      alpha = Constr.AppData.InitParam + X - X0;
   end
   Constr.SettlingTime = AbsLogSettlingTimeThreshold/(eps+abs(alpha));
   
   % Update graphics and notify observers
   update(Constr)
   
   % Status
   LocStr = sprintf('Upper bound on settling time: %0.3g sec.',Constr.SettlingTime);
   X = sprintf('Move constraint to adjust settling time bound and release the mouse.\n%s',LocStr); 
   
end