function c = cross(a,b,dim)
%CROSS  Vector cross product.
%   C = CROSS(A,B) returns the cross product of the vectors
%   A and B.  That is, C = A x B.  A and B must be 3 element
%   vectors.
%
%   C = CROSS(A,B) returns the cross product of A and B along the
%   first dimension of length 3.
%
%   C = CROSS(A,B,DIM), where A and B are N-D arrays, returns the cross
%   product of vectors in the dimension DIM of A and B. A and B must
%   have the same size, and both SIZE(A,DIM) and SIZE(B,DIM) must be 3.
%
%   See also DOT.

%   Clay M. Thompson
%   updated 12-21-94, Denise Chen
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.18.4.1 $  $Date: 2003/05/01 20:43:31 $

% Special case: A and B are vectors
rowvec = 0;
if ndims(a)==2 && ndims(b)==2 && nargin<3
    if size(a,1)==1, a = a(:); rowvec = 1; end
    if size(b,1)==1, b = b(:); rowvec = 1; end
end;

% Check dimensions
if ~isequal(size(a),size(b)),
   error('MATLAB:cross:InputSizeMismatch', 'A and B must be same size.');
end

if nargin == 2
   dim = min(find(size(a)==3));
   if isempty(dim), 
     error('MATLAB:cross:InvalidDimAorB',...
           'A and B must have at least one dimension of length 3.');
   end
end;

% Check dimensions
if (size(a,dim)~=3) || (size(b,dim)~=3),
  error('MATLAB:cross:InvalidDimAorBForCrossProd',...
    'A and B must be of length 3 in the dimension in which the cross product is taken.')
end

% Permute so that DIM becomes the row dimension
perm = [dim:max(length(size(a)),dim) 1:dim-1];
a = permute(a,perm);
b = permute(b,perm);

% Calculate cross product
c = [a(2,:).*b(3,:)-a(3,:).*b(2,:)
     a(3,:).*b(1,:)-a(1,:).*b(3,:)
     a(1,:).*b(2,:)-a(2,:).*b(1,:)];
c = reshape(c,size(a));

% Post-process.
c = ipermute(c,perm);
if rowvec, c = c.'; end
