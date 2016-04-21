function Trange = getAsymtoteConstraint(this,BoundType,MovedVertex,dy)
% Enforces parallel asymptotes

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:45:53 $
%   Copyright 1986-2003 The MathWorks, Inc.
if dy==0
   Trange = [-Inf,Inf];
else
   % Directions of last upper bound
   udir = [diff(this.UpperBoundX(end,:)) diff(this.UpperBoundY(end,:))];
   ldir = [diff(this.LowerBoundX(end,:)) diff(this.LowerBoundY(end,:))];
   if strcmp(BoundType(1),'L')
      % Find theta>=0 such that udir collinear with ldir+[0,theta]
      theta = -(udir(1)*ldir(2)-udir(2)*ldir(1))/udir(1);
      if MovedVertex==1
         % t*dy>-theta
         if dy>0
            Trange = [-theta/dy,Inf];
         else
            Trange = [-Inf,-theta/dy];
         end
      else
         % t*dy<theta
         if dy>0
            Trange =  [-Inf,theta/dy];
         else
            Trange = [theta/dy,Inf];
         end
      end
   else
      % Find theta<=0 such that ldir collinear with udir+[0,theta]
      theta = -(ldir(1)*udir(2)-ldir(2)*udir(1))/ldir(1);
      if MovedVertex==1
         % t*dy<-theta
         if dy>0
            Trange = [-Inf,-theta/dy];
         else
            Trange = [-theta/dy,Inf];
         end
      else
         % t*dy>theta
        if dy>0
            Trange = [theta/dy,Inf];
         else
            Trange = [-Inf,theta/dy];
         end
      end
   end
end