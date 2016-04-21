function split(this,BoundType,idx,xMouse)
% Split specified constraint segment in two.

% Author: Kamesh Subbarao, P. Gahinet
% Copyright 1986-2004 The MathWorks, Inc.
switch BoundType
   case 'LowerBound'
      px = 'LowerBoundX';
      py = 'LowerBoundY';
      pw = 'LowerBoundWeight';
   case 'UpperBound'
      px = 'UpperBoundX';
      py = 'UpperBoundY';
      pw = 'UpperBoundWeight';
end
nseg = size(this.(px),1);

% Compute relative x position
xV = this.(px)(idx,:);
yV = this.(py)(idx,:);
t = max(0.1,min(0.9,(xMouse-xV(1))/(xV(2)-xV(1))));
newx = (1-t) * xV(1) + t * xV(2);
newy = (1-t) * yV(1) + t * yV(2);

% Update bound data
this.(px) = [this.(px)(1:idx-1,:);...
   this.(px)(idx,1) newx;...
   newx this.(px)(idx,2);...
   this.(px)(idx+1:nseg,:)];

this.(py) = [this.(py)(1:idx-1,:);...
   this.(py)(idx,1) newy;...
   newy this.(py)(idx,2);...
   this.(py)(idx+1:nseg,:)];

this.(pw) = this.(pw)([1:idx idx idx+1:nseg],:);
