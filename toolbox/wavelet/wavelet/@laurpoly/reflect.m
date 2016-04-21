function Q = reflect(P)
%REFLECT Reflection for a Laurent polynomial.
%   Q = REFLECT(P) returns the Laurent polynomial Q obtained by
%   a reflection on the Laurent polynomial P: Q(z) = P(1/z).
%   
%   See also DYADDOWN, DYADUP, MODULATE, NEWVAR.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-Mar-2001.
%   Last Revision: 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $ $Date: 2004/03/15 22:38:11 $ 

Q = newvar(P,'1/z');
