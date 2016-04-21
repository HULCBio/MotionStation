function r = rref(A)
%RREF   Reduced row echelon form.
%   RREF(A) is the reduced row echelon form of the symbolic matrix A.
%
%   Example:
%       rref(sym(magic(4))) is not the identity.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.5 $  $Date: 2002/04/15 03:06:36 $

if all(size(A) == 1)
   r = sym(A ~= 0);
else
   r = maple('gaussjord',A);
end;
