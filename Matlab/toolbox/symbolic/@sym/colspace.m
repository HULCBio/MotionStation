function B = colspace(A)
%COLSPACE Basis for column space.
%   The columns of B = COLSPACE(A) form a basis for the column space of A.
%   SIZE(B,2) is the rank of A.
%
%   Example:
%
%     colspace(sym(magic(4))) is
%
%       [  0,  1,  0]
%       [  0,  0,  1]
%       [  1,  0,  0]
%       [ -3,  1,  3]
%
%   See also NULL.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.12 $  $Date: 2002/04/15 03:09:15 $

if all(size(A) == 1)
   if strcmp(A.s,'0')
      B = sym([]); 
   else
      B = sym(1); 
   end
else
   B = maple('colspace',A).';
end
