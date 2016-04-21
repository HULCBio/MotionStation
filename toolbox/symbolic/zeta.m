function Z = zeta(n,X)
%ZETA   Symbolic Riemann zeta function.
%   ZETA(z) = sum(1/k^z,k,1,inf).
%   ZETA(n,z) = n-th derivative of ZETA(z)

%   Copyright 1993-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/04/16 22:23:33 $

if nargin == 1
   Z = double(zeta(sym(n)));
else
   Z = double(zeta(sym(n),sym(X)));
end
