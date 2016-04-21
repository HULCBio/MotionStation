function E = even(P)
%EVEN Even part of a Laurent polynomial.
%   E = EVEN(P) returns the even part E of the Laurent polynomial P.
%   The polynomial E is such that:  
%           E(z^2) = [P(z) + P(-z)]/2
%   
%   See also DYADDOWN, ODD.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 21-Mar-2001.
%   Last Revision 15-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $ $Date: 2004/04/13 00:38:42 $ 

% EVEN(P) == DYADDOWN(P)
%-----------------------
C = P.coefs;
D = P.maxDEG;
E = laurpoly(C(1+mod(D,2):2:end),floor(D/2));
