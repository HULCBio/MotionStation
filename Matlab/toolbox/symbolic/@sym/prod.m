function p = prod(A,dim)
%PROD   Product of the elements.
%   For vectors, PROD(X) is the product of the elements of X.
%   For matrices, PROD(X) or PROD(X,1) is a row vector of column products
%   and PROD(X,2) is a column vector of row products.
%
%   See also SUM.
 
%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.8 $  $Date: 2002/04/15 03:10:12 $

if nargin == 1 & any(size(A) == 1)
   p = sym(1);
   for k = 1:prod(size(A))
      p = p * A(k);
   end
elseif nargin == 1 | dim == 1
   p = sym(ones(1,size(A,2)));
   for i = 1:size(A,1)
      p = p .* A(i,:);
   end
else
   p = sym(ones(size(A,1),1));
   for j = 1:size(A,2);
      p = p .* A(:,j);
   end
end
