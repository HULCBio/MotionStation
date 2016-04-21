function Z = null(A)
%NULL   Basis for null space.
%   The columns of Z = NULL(A) form a basis for the null space of A.
%   SIZE(Z,2) is the nullity of A.
%   A*Z is zero.
%   If A has full rank, Z is empty.
%
%   Example:
%
%     null(sym(magic(4))) is
%
%       [ -1]
%       [ -3]
%       [  3]
%       [  1]
%
%   See also COLSPACE.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.13 $  $Date: 2002/04/15 03:12:36 $

if all(size(A) == 1)
   if strcmp(A.s,'0')
      Z = sym(1); 
   else
      Z = sym([]); 
   end
else
   Z = maple('nullspace',A).';
end
