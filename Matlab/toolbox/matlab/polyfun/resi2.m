function coeff = resi2(u,v,pole,n,k)
%RESI2  Residue of a repeated pole.
%   RESI2(U,V,POLE,N,K) returns the residue of a repeated pole
%   of order N and the K-th power denominator of [1 -pole], where
%   U and V represent the original polynomial ratio U/V.
%   For example, if P is a pole of multiplicity 2,
%   then this routine should be called twice with N = 2,
%   first using K = 1, then K = 2.  If K is not provided,
%   it defaults to N.  If N is not provided, it defaults to 1.
%
%   RESI2 is used by RESIDUE to compute the partial fraction
%   expansion of repeated poles.
%
%   See also RESIDUE, POLYDER.

%   Reference:
%     A.V. Oppenheim and R.W. Schafer, Digital Signal Processing,
%     Prentice-Hall, 1975, p. 56-58.  The method is described in 
%     most signal processing and control theory texts.

%   Charles R. Denham, MathWorks, 1988.
%   Copyright 1984-2002 The MathWorks, Inc.
%   $Revision: 5.8 $  $Date: 2002/04/15 04:24:36 $

if nargin < 4, n = 1; end
if nargin < 5, k = n; end

u = u(:).'; v = v(:).'; p = [1 -pole];
for j = 1:n, v = deconv(v,p); end
for j = 1:n-k, [u,v] = polyder(u,v); end
c = 1; if k < n, c = prod(1:n-k); end
coeff = (polyval(u,pole) ./ polyval(v,pole)) ./ c;
