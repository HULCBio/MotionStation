function P = eo2lp(E,O)
%EO2LP Recover a Laurent polynomial from its even and odd parts.
%   P = EO2LP(E,O) returns the Laurent polynomial P which
%   has E and O as even and odd part respectively.
%       E(z^2) = [P(z) + P(-z)]/2
%       O(z^2) = [P(z) - P(-z)] / [2*z^(-1)]
%   
%   See also EVEN, ODD.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 17-May-2001.
%   Last Revision 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:38:37 $ 

P = newvar(E,'z^2') + laurpoly(1,-1)*newvar(O,'z^2');
