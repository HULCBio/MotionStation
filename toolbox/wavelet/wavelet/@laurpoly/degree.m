function d = degree(P)
%DEGREE Degree for Laurent polynomial.
%   d = DEGREE(P) returns the degree of the Laurent polynomial P.
%   If:
%      P(Z) = C(1)*Z^(n) + C(2)*z^(n-1) + ... + C(L)*z^(n-L+1)
%   then: 
%      d = n-(n-L+1) - n = L-1

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Mar-2001.
%   Last Revision 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:38:32 $ 

d = length(P.coefs)-1;
