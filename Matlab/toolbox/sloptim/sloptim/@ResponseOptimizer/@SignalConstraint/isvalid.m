function boo = isvalid(this)
% Check if constraint is valid (lower bounds below upper bounds)

%   Author: P. Gahinet
%   Copyright 1986-2003 The MathWorks, Inc.
boo = true;

% All upper bound vertices should be above lower bound
nbnd = size(this.UpperBoundX,1);
ubvx = [this.UpperBoundX(:,1) ; this.UpperBoundX(nbnd,2)];
ubvy = [this.UpperBoundY(1,1) ; ...
   min(this.UpperBoundY(2:nbnd,1),this.UpperBoundY(1:nbnd-1,2)) ; ...
   this.UpperBoundY(nbnd,2)];
for ct=1:nbnd+1
   % Find lower bound below upper bound vertex #ct
   idx = find(this.LowerBoundX(:,1)<=ubvx(ct),1,'last');
   % Find lower bound value at x=UBVX(ct)
   if this.LowerBoundX(idx,1)==ubvx(ct)
      lby = this.LowerBoundY(idx,1);
      if idx>1
         lby = max(lby,this.LowerBoundY(idx-1,2));
      end
   else
      % interpolate
      lby = interp1(this.LowerBoundX(idx,:),this.LowerBoundY(idx,:),ubvx(ct));
   end
   % Compare
   if lby>ubvy(ct)
      boo = false; return
   end
end

% All lower bound vertices should be below upper bound
nbnd = size(this.LowerBoundX,1);
lbvx = [this.LowerBoundX(:,1) ; this.LowerBoundX(nbnd,2)];
lbvy = [this.LowerBoundY(1,1) ; ...
   max(this.LowerBoundY(2:nbnd,1),this.LowerBoundY(1:nbnd-1,2)) ; ...
   this.LowerBoundY(nbnd,2)];
for ct=1:nbnd+1
   % Find upper bound above lower bound vertex #ct
   idx = find(this.UpperBoundX(:,1)<=lbvx(ct),1,'last');
   % Find lower bound value at x=UBVX(ct)
   if this.UpperBoundX(idx,1)==lbvx(ct)
      uby = this.UpperBoundY(idx,1);
      if idx>1
         uby = min(uby,this.UpperBoundY(idx-1,2));
      end
   else
      % interpolate
      uby = interp1(this.UpperBoundX(idx,:),this.UpperBoundY(idx,:),lbvx(ct));
   end
   % Compare
   if uby<lbvy(ct)
      boo = false; return
   end
end

