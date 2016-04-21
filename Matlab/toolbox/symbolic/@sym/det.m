function d = det(A)
%DET    Symbolic matrix determinant.
%   DET(A) is the determinant of the symbolic matrix A.
%
%   Examples:
%       det([a b;c d]) is a*d-b*c.

%   Copyright 1993-2002 The MathWorks, Inc.
%   $Revision: 1.10 $  $Date: 2002/04/15 03:10:36 $

if all(size(A) == 1)
   d = A;
else
   d = maple('det',A);
end;
