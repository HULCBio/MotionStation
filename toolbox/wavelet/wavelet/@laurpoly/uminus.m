function P = uminus(A)
%UMINUS Unary minus for Laurent polynomial.
%   -A negates the elements of A.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-Mar-2001.
%   Last Revision: 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2004/03/15 22:38:13 $ 

P = laurpoly(-A.coefs,A.maxDEG);
