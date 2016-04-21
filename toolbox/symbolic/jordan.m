function [V,J] = jordan(A)
%JORDAN Jordan Canonical Form.
%   JORDAN(A) computes the Jordan Canonical/Normal Form of the matrix A.
%   The matrix must be known exactly, so its elements must be integers
%   or ratios of small integers.  Any errors in the input matrix may
%   completely change its JCF.
%
%   [V,J] = JORDAN(A) also computes the similarity transformation, V, so
%   that V\A*V = J.  The columns of V are the generalized eigenvectors.
%
%   Example:
%      A = gallery(5);
%      [V,J] = jordan(A)
%
%   See also EIG, POLY.

%   Copyright 1993-2002 The MathWorks, Inc. 
%   $Revision: 1.11 $  $Date: 2002/04/15 03:13:47 $

if nargout < 2
   V = double(jordan(sym(A)));
else
   [V,J] = jordan(sym(A));
   V = double(V);
   J = double(J);
end
