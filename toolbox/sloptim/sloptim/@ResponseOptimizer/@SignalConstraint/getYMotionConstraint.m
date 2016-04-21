function dy = getYMotionConstraint(this,BoundType,idx)
% Computes admissible range of incremental vertical motion for
% bound #idx

%   Author: P. Gahinet
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:45:57 $
%   Copyright 1986-2003 The MathWorks, Inc.

% Find opposite vertices that constraint the vertical motion
LowerBoundMoved = strcmp(BoundType(1),'L');
if LowerBoundMoved
   % Moving lower bound
   x = this.LowerBoundX(idx,:);
   y = this.LowerBoundY(idx,:);
   % Find upper bounds traversed by lower bound motion path
   idxU = find(this.UpperBoundX(:,2)>=x(1) & this.UpperBoundX(:,1)<=x(2));
   % Collect their vertices
   vertX = this.UpperBoundX(idxU,:).';
   vertY = this.UpperBoundY(idxU,:).';
else
   % Moving upper bound
   x = this.UpperBoundX(idx,:);
   y = this.UpperBoundY(idx,:);
   % Find lower bounds traversed by lower bound motion path
   idxL = find(this.LowerBoundX(:,2)>=x(1) & this.LowerBoundX(:,1)<=x(2));
   % Clip these upper bounds to X range and collect their vertices
   vertX = this.LowerBoundX(idxL,:).';
   vertY = this.LowerBoundY(idxL,:).';
end

nv = numel(vertX);
if nv==0
   % Unconstrained
   dy = [-Inf , Inf];
else
   % Clip active opposite bounds to X range
   if vertX(1)<x(1)
      vertY(1) = interp1(vertX([1 2]),vertY([1 2]),x(1));
      vertX(1) = x(1);
   end
   if vertX(nv)>x(2)
      vertY(nv) = interp1(vertX([nv-1,nv]),vertY([nv-1,nv]),x(2));
      vertX(nv) = x(2);
   end
   % Compute equation y=ax+b of the line supporting the moved lower bound
   a = diff(y)/diff(x);
   b = y(1)-a*x(1);
   if LowerBoundMoved
      % Max vertical displacement is min(y-(ax+b)) over all vertices of these
      % upper bounds, where y=ax+b is the line supporting the moved lower
      % bound
      dy = [-Inf , min(vertY(:)-a*vertX(:)-b)];
   else
      dy = [max(vertY(:)-a*vertX(:)-b) , Inf];
   end
end
