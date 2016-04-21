function X = mtimes(A, B)
%TIMES  Symbolic matrix multiplication.
%   MTIMES(A,B) overloads symbolic A * B.
    
%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/16 22:22:58 $

A = sym(A);
B = sym(B);

if all(size(A) == 1) & all(size(B) == 1)
   % Scalar multiply
   X = maple(A,'*',B);

elseif all(size(A) == 1)
   % Scalar times matrix
   X = reshape(maple('scalarmul',B(:),A),size(B));

elseif all(size(B) == 1)
   % Matrix times scalar
   X = reshape(maple('scalarmul',A(:),B),size(A));

elseif ndims(A) > 2 | ndims(B) > 2
   error('symbolic:sym:mtimes:errmsg1','Input arguments must be 2-D.')

elseif size(A,2) == size(B,1)
   % Matrix multipliplication
   X = maple(A,'&*',B);

else
   error('symbolic:sym:mtimes:errmsg2','Inner matrix dimensions must agree.')
end
