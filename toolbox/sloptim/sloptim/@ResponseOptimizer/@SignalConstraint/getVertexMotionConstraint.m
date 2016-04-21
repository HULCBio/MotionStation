function Trange = getVertexMotionConstraint(this,x0,y0,dx,dy,BoundType,Xrange)
% Computes collision-free range of motion for vertex (x0,y0) 
% of type BOUNDTYPE along direction dx,dy. The input XRANGE
% specifies built-in limits on the x range.

%   Author(s): P. Gahinet
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:45:56 $
%   Copyright 1986-2004 The MathWorks, Inc.
if dx==0 && dy==0
   Trange = [-Inf,Inf];  return
end

% Reduce problem to finding range for a lower bound vertex
if strcmp(BoundType(1),'L')
   ubx = this.UpperBoundX;
   uby = this.UpperBoundY;
else
   % Flip wrt x-axis
   y0 = -y0; dy = -dy;
   ubx = this.LowerBoundX;
   uby = -this.LowerBoundY;
end
nub = size(ubx,1);

% Find equation ax+by+c=0, b>=0 of trajectory for moved vertex
if dx>=0
   b = dx;  a = -dy;  c = x0*dy-y0*dx;
else
   b = -dx;  a = dy;  c = y0*dx-x0*dy;
end

% To allow for tangential motion (sliding along opposing constraint)
% find edges that contain the moved vertex and are parallel to the 
% direction of motion. Such edges do not constrain motion and are
% ignored
uM = [dx;dy];  uM = uM/norm(uM);  % direction of motion
isTangential = false(nub,1);
for ct=1:nub
   if ubx(ct,1)<=x0 && (ubx(ct,2)>=x0 || ct==nub)
      uE = [ubx(ct,2)-ubx(ct,1) ; uby(ct,2)-uby(ct,1)];  uE = uE/norm(uE);
      uV = [x0-ubx(ct,1) ; y0-uby(ct,1)];  uV = uV/norm(uV);
      isTangential(ct) = abs(uE'*uM)>1-sqrt(eps) && abs(uV'*uM)>1-1e-4;
   end
end

% Find upper bound edges with at least one vertex in [x1,x2], and
% such that a*xL+b*yL+c<=0 or a*xR+b*yR+c<=0
tmin = -Inf;  tmax = Inf;
zL = a*ubx(:,1)+b*uby(:,1)+c;
zR = a*ubx(:,2)+b*uby(:,2)+c;
idxE = find(ubx(:,2)>=Xrange(1) & ubx(:,1)<=Xrange(2) & ...
   (zL<=0 | zR<=0) & ~isTangential);
for ct=1:length(idxE)
   j = idxE(ct);
   % Compute equation y=aj*x+bj of edge support
   aj = diff(uby(j,:))/diff(ubx(j,:));
   bj = uby(j,1)-aj*ubx(j,1);
   B = y0-(aj*x0+bj);
   % Enforce B<=0 when edge contains x0
   if prod(ubx(j,:)-x0)<=0
      B = min(B,0);
   end
   % Compute effective constraint 
   if B<=0 && (zL(j)>0 || zR(j)>0)
      % Line ax+by+c=0 intersects edge y=aj*x+bj, and vertex
      % can move freely up to this contact point.
      % Imposes aj*(x0+t*dx)+bj>y0+t*dy -> A*t > B
      A = aj*dx-dy;
      if A>0
         tmin = max(tmin,B/A);
      elseif A<0
         tmax = min(tmax,B/A);
      end
   elseif ubx(j,2)<=x0
      % Edge is below trajectory and left of (x0,y0)
      Xrange(1) = max(Xrange(1),ubx(j,2));
   else
      Xrange(2) = min(Xrange(2),ubx(j,1));
   end
end

% Factor in XRANGE constraints
if dx~=0
   Trange = (Xrange-x0)/dx;
   tmin = max(tmin,min(Trange));  
   tmax = min(tmax,max(Trange));
end
% Protection against crossings due to roundoff
deadzone = 1e-3;
tmin = min(0,tmin+deadzone);
tmax = max(0,tmax-deadzone);
Trange = [tmin,tmax];
