function cleanup(this,BoundType,AbsTol)
% Eliminate constraints with zero X width

% Author: P. Gahinet
% Copyright 1986-2004 The MathWorks, Inc.
if strcmpi(BoundType(1),'l')
   % Find all constraints with negligible width
   x = [this.LowerBoundX(:,1);this.LowerBoundX(end,2)];
   idxDel = find(diff(x)<=AbsTol);
   % Delete them
   x(1+idxDel,:) = [];
   this.LowerBoundX = [x(1:end-1) , x(2:end)];  % no gap introduced
   this.LowerBoundY(idxDel,:) = [];
   this.LowerBoundWeight(idxDel,:) = [];
else
   x = [this.UpperBoundX(:,1);this.UpperBoundX(end,2)];
   idxDel = find(diff(x)<=AbsTol);
   % Delete them
   x(1+idxDel,:) = [];
   this.UpperBoundX = [x(1:end-1) , x(2:end)];  % no gap introduced
   this.UpperBoundY(idxDel,:) = [];
   this.UpperBoundWeight(idxDel,:) = [];   
end

