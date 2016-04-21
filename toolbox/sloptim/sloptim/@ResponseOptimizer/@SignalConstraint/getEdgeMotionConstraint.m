function Trange = getEdgeMotionConstraint(this,xA,yA,x0,y0,dx,dy,BoundType,Xrange)
% Computes collision-free range of motion for vertex B of edge [A,B] 
% of type BOUNDTYPE.  The initial position of B is (x0,y0) and B moves
% along direction dx,dy. The input XRANGE specifies built-in limits on 
% the x range.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:45:54 $
%   Copyright 1986-2003 The MathWorks, Inc.

% Reduce problem to finding range for a lower bound vertex
if strcmp(BoundType(1),'L')
   ubx = this.UpperBoundX;
   uby = this.UpperBoundY;
else
   % Flip wrt x-axis
   y0 = -y0; yA = -yA; dy = -dy;
   ubx = this.LowerBoundX;
   uby = -this.LowerBoundY;
end

% Collect upper bound vertices
xv = ubx(:);
yv = uby(:);

% Motion of B is parameterized as (x0+t*dx,y0+t*dy). Find value tv(j)
% for which edge line touches vertex (xv(j),yv(j))
e = sign(x0-xA);
xvA = xv-xA;
yvA = yv-yA;
r = (y0-yA)*xvA-(x0-xA)*yvA;
s = dx * yvA - dy * xvA;
% Enforce e*r<=0 when xv in [xA,x0] (otherwise moved edge
% can go though upper vertex due to roundoff errors)
r(xvA.*(xv-x0)<=0 & e*r>0) = 0;
idxNZ = find(s~=0);
s = s(idxNZ);
tv = r(idxNZ)./s;

% Discard values of tv corresponding to contact point outside [A,B]
xv = xv(idxNZ);
ikeep = find((xv-xA).*(xv-x0-tv*dx)<=0);
tv = tv(ikeep);

% Resulting constraints on t
islb = (e*s(ikeep)>0);
% RE: Beware of tv>0 when contact occurs after vertex B has already
% traversed the edge containing (xv,yv)
tmin = max([-Inf;tv(islb & tv<=0)]);
tmax = min([tv(~islb & tv>=0);Inf]);
% Protection against crossings due to roundoff
deadzone = 1e-3;
tmin = min(0,tmin+deadzone);
tmax = max(0,tmax-deadzone);
Trange = [tmin,tmax];
