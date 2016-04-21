function Q = mpower(P,pow)
%MPOWER Laurent polynomial exponentiation.
%   MPOWER(P,POW) overloads Laurent polynomial P^POW.
%   For a positive integer POW, Q = mpower(P,POW)  
%   returns the Laurent polynomial Q = P^POW.
%   For a negative integer POW and for a monomial P
%   Q = mpower(P,POW) returns the monomial Q = P^POW.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 19-Jun-2003.
%   Last Revision: 19-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:38:56 $

if pow~=fix(pow)
    error('Invalid value for power argument.')
end
Q = 1;
if pow>0
    for k = 1:pow , Q = Q*P; end
elseif pow<0
    if ismonomial(P)
        D = 1/P;
        for k = 1:abs(pow) , Q = Q*D; end
    else
        error('For negative powers, P must be a monomial.')
    end
else
    
end