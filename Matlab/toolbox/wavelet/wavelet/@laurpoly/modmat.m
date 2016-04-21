function M = modmat(H,G)
%MODMAT Modulation matrix associated to two Laurent polynomials.
%   M = MODMAT(H,G) returns the modulation matrix associated with
%   two Laurent polynomials. This matrix is such that:
%
%              | H(z)  H(-z) |
%       M(z) = |             |
%              | G(z)  G(-z) |
%
%   See also PPM.

%   M. Misiti, Y. Misiti, G. Oppenheim, J.M. Poggi 22-Jan-2003.
%   Last Revision: 13-Jun-2003.
%   Copyright 1995-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:38:54 $

M = laurmat({H , newvar(H,'-z'); G , newvar(G,'-z')});
