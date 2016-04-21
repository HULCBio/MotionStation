function R = isequal(A,B)
%ISEQUAL True if Laurent matrices are numerically equal.
%   ISEQUAL(A,B) returns 1 if the two Laurent matrices
%   A and B are equal and 0 otherwise.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 11-Jun-2003.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:39:14 $ 

R = eq(A,B);
