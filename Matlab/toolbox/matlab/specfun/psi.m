%PSI  Psi (polygamma) function.
%   Y = PSI(X) evaluates the psi function for each element of X.
%   X must be real and nonnegative.  SIZE(Y) is the same as SIZE(X).
%   The psi function, also know as the digamma function, is the logarithmic
%   derivative of the gamma function: 
%
%      psi(x) = digamma(x) = d(log(gamma(x)))/dx = (d(gamma(x))/dx)/gamma(x).
%
%   Y = PSI(K,X) evaluates the K-derivative of psi at the elements of X.
%   For real integer-valued scalar K, SIZE(Y) is the same as SIZE(X).
%   PSI(0,X) is the digamma function, PSI(1,X) is the trigamma function,
%   PSI(2,X) is the tetragamma function, etc.
%
%   Y = PSI(K0:K1,X) evaluates derivatives of order K0 through K1 at X. The
%   vector K0:K1 must be real and integer-valued. If X is a vector, SIZE(Y) will
%   be NUMEL(K)-by-LENGTH(X). Otherwise, SIZE(Y) will be NUMEL(K)-by-SIZE(X).
%   Y(K,J) is the (K-1+K0)-th derivative of psi evaluated at X(J).
%
%   Examples:
%
%      -psi(1) = -psi(0,1) is Euler's constant, 0.5772156649015323.
%
%      psi(1,2) = pi^2/6 - 1.
%
%      x = (1:.005:1.250)';  [x gamma(x) gammaln(x) psi(0:1,x)' x-1]
%      produces the first page of table 6.1 of Abramowitz and Stegun.
%
%      psi(2:3,1:.01:2)' is a portion of table 6.2.
%
%   Ref: Abramowitz & Stegun, Handbook of Mathematical Functions,
%   sections 6.3 and 6.4.
%
%   See also GAMMA, GAMMALN, GAMMAINC.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/16 22:08:34 $

%   Mex file derived from a FORTRAN program by D. E. Amos,
%   ACM Transactions on Mathematical Software, 1983.
