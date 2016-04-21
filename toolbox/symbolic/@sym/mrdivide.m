function X = mrdivide(B, A)
%MRDIVIDE Symbolic matrix right division.
%   MRDIVIDE(B,A) overloads symbolic B / A.
%   X = B/A solves the symbolic linear equations X*A = B.
%   Warning messages are produced if X does not exist or is not unique.  
%   Rectangular matrices A are allowed, but the equations must be
%   consistent; a least squares solution is not computed.
    
%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/04/16 22:22:57 $

B = sym(B);
A = sym(A);

if all(size(A) == 1)
   % Division by a scalar.
   X = rdivide(B,A);

elseif ndims(A) > 2 | ndims(B) > 2
   error('symbolic:sym:mrdivide:errmsg1','Input arguments must be 2-D.')

elseif size(A,2) ~= size(B,2)
   error('symbolic:sym:mrdivide:errmsg2','Second dimensions must agree.')

else
   % Matrix divided by matrix
   X = (A.'\B.').';
end
