function C = clipdivide(A, B)
%CLIPDIVIDE Elementwise division with denominator clipping.
%   C = CLIPDIVIDE(A, B) modifies B so that no element is less than eps,
%   and then it performs element-wise division of A by the modified
%   version of B.  A and B must be real double arrays.

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/05/03 17:51:46 $

B(B < eps) = eps;
C = A ./ B;
