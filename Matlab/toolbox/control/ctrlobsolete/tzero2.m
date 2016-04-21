function z = tzero(a,b,c,d)
%TZERO2 Transmission zeros.
%   TZERO2(A,B,C,D) returns the transmission zeros of the state-space
%   system:
%       .
%       x = Ax + Bu
%       y = Cx + Du
%
%   Care must be exercised to disregard any large zeros that may
%   actually be at infinity.  It is best to use FORMAT SHORT E so
%   large zeros don't swamp out the display of smaller finite zeros.
%
%   This M-file finds the transmission zeros using an algorithm based
%   on QZ techniques.  It is not as numerically reliable as the 
%   algorithm in TZERO.
%
%   See also: TZERO.

% For more information on this algorithm, see:
%   [1] A.J Laub and B.C. Moore, Calculation of Transmission Zeros Using
%   QZ Techniques, Automatica, 14, 1978, p557
%
% For a better algorithm, not implemented here, see:
%   [2] A. Emami-Naeini and P. Van Dooren, Computation of Zeros of Linear 
%   Multivariable Systems, Automatica, Vol. 14, No. 4, pp. 415-430, 1982.
%

%   J.N. Little 4-21-85
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 06:32:11 $

error(nargchk(4,4,nargin));
[msg,a,b,c,d]=abcdchk(a,b,c,d); error(msg);

[n,m] = size(b);
[r,n] = size(c);
aa = [a b;c d];

if m == r
    [mcols, nrows] = size(aa);
    bb = zeros(mcols, nrows);
    bb(1:n,1:n) = eye(n);
    z = eig(aa,bb);
    z = z(~isnan(z) & finite(z)); % Punch out NaN's and Inf's
else
    nrm = norm(aa,1);
    if m > r
        aa1 = [aa;nrm*(rand(m-r,n+m)-.5)];
        aa2 = [aa;nrm*(rand(m-r,n+m)-.5)];
    else
        aa1 = [aa nrm*(rand(n+r,r-m)-.5)];
        aa2 = [aa nrm*(rand(n+r,r-m)-.5)];
    end
    [mcols, nrows] = size(aa1);
    bb = zeros(mcols, nrows);
    bb(1:n,1:n) = eye(n);
    z1 = eig(aa1,bb);
    z2 = eig(aa2,bb);
    z1 = z1(~isnan(z1) & finite(z1));   % Punch out NaN's and Inf's
    z2 = z2(~isnan(z2) & finite(z2));
    nz = length(z1);
    for i=1:nz
        if any(abs(z1(i)-z2) < nrm*sqrt(eps))
            z = [z;z1(i)];
        end
    end
end
