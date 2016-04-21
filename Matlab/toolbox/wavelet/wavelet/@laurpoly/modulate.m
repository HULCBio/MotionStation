function Q = modulate(P)
%MODULATE Modulation for a Laurent polynomial.
%   Q = MODULATE(P) returns the Laurent polynomial Q obtained by
%   a modulation on the Laurent polynomial P: Q(z) = P(-z).
%   
%   See also DYADDOWN, DYADUP, NEWVAR, REFLECT.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-Mar-2001.
%   Last Revision: 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:38:55 $

Q = newvar(P,'-z');
