function M = minus(A,B)
%MINUS Laurent matrices substraction.
%   M = MINUS(A,B) returns a Laurent matrix which is
%   the difference of the two Laurent matrices A and B.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 29-Mar-2001.
%   Last Revision 12-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:39:17 $ 

M = plus(A,-B);