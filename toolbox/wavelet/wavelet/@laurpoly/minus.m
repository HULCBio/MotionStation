function P = minus(A,B)
%MINUS Laurent polynomial substraction.
%   P = MINUS(A,B) returns a Laurent polynomial which is
%   the difference of the two Laurent polynomials A and B.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Mar-2001.
%   Last Revision: 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:38:52 $

P = plus(A,-B);