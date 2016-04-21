function yi=interp1q(x,y,xi)
%INTERP1Q Quick 1-D linear interpolation.
%   F=INTERP1Q(X,Y,XI) returns the value of the 1-D function Y at the
%   points XI using linear interpolation. Length(F)=length(XI).
%   The vector X specifies the coordinates of the underlying interval.
%   
%   If Y is a matrix, then the interpolation is performed for each column
%   of Y in which case F is length(XI)-by-size(Y,2).
%
%   NaN's are returned for values of XI outside the coordinates in X.
%
%   INTERP1Q is quicker than INTERP1 on non-uniformly spaced data because
%   it does no input checking. For INTERP1Q to work properly:
%   X must be a monotonically increasing column vector.
%   Y must be a column vector or matrix with length(X) rows.
%
%   Class support for inputs x, y, xi:
%      float: double, single
%
%   See also INTERP1.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.15.4.1 $  $Date: 2004/03/02 21:47:45 $

siz = size(xi);
if length(xi)~=1
   [xxi,k] = sort(xi);
   [dum,j]=sort([x;xxi]);
   r(j)=1:length(j);
   r=r(length(x)+1:end)-(1:length(xxi));
   r(k)=r;
   r(xi==x(end))=length(x)-1;
   ind=find((r>0) & (r<length(x)));
   ind = ind(:);
   yi = NaN(length(xxi),size(y,2), superiorfloat(x,y,xi));
   rind = r(ind);
   u = (xi(ind)-x(rind))./(x(rind+1)-x(rind));
   yi(ind,:)=y(rind,:)+(y(rind+1,:)-y(rind,:)).*u(:,ones(1,size(y,2)));
else
   % Special scalar xi case
   r = max(find(x <= xi));
   r(xi==x(end)) = length(x)-1;
   if isempty(r) | (r<=0) | (r>=length(x))
      yi = NaN(1,size(y,2),superiorfloat(x,y,xi));
   else
      u = (xi-x(r))./(x(r+1)-x(r));
      yi=y(r,:)+(y(r+1,:)-y(r,:)).*u(:,ones(1,size(y,2)));
   end
end

if (min(size(yi))==1) & (prod(siz)>1), 
   yi = reshape(yi,siz); 
end
