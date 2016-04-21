function r = rank(A)
%RANK   Symbolic matrix rank.
%   RANK(A) is the rank of the symbolic matrix A.
%
%   Example:
%       rank([a b;c d]) is 2.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.6 $  $Date: 2002/04/15 03:09:12 $

if all(size(A) == 1)
   r = sym(A ~= 0);
else
   r = maple('rank',A);
end;
