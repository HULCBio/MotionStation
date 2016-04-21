function musldemo
%MUSLDEMO Musol4 demo
%

% R. Y. Chiang & M. G. Safonov 3/88
% Copyright 1988-2004 The MathWorks, Inc.
% All Rights Reserved.
% $Revision: 1.6.4.3 $

format compact
echo on
clc
% This file demonstrates how to use musol4.
% Suppose we like to compute the upper bound described in file
% musol4.m for the matrix M with real part M1 and imaginary part M2:

M1 = [ ...
   5.2829e+00   5.7683e+00  -2.4004e+00   1.2205e+00  -6.4148e+00
   9.7769e-01   2.9786e+00  -3.0408e+00   5.0257e-01  -2.6504e+00
   7.0819e+00   9.6324e+00  -3.5750e+00   3.3016e+00  -6.7030e+00
  -1.6261e+00  -2.9763e+00   1.6870e+00  -1.0603e+00   1.2211e+00
   2.3056e+00   4.3712e+00  -2.4785e+00   2.6152e+00  -1.9832e+00];

M2 = [ ...
  -1.1308e+00  -1.7785e+00   8.7974e-01  -7.5206e-01   1.2089e+00
  -3.5255e-01  -5.7002e-01   2.9305e-01  -2.5442e-01   3.7691e-01
  -1.3724e+00  -2.1501e+00   1.0741e+00  -9.1188e-01   1.4669e+00
   3.5839e-01   5.5101e-01  -2.7290e-01   2.3565e-01  -3.7663e-01
  -4.9015e-01  -7.8706e-01   4.0215e-01  -3.3617e-01   5.3261e-01];

% i.e.,

M = M1 + sqrt(-1)*M2;

pause
clc
% The largest singular value of M is
max(svd(M))

% and the spectral radius of M is
max(abs(eig(M)))

pause
t0 = clock;
clc
% Let the structure be all scalar blocks as in
K = [1 1 1 1 1];

% Let the first, the third and the fifth blocks be real,
% and let the rest of blocks be complex, as in
T = [1 2 1 2 1];

% Now we compute the upper bound. The result is
r = musol4(M,K,T)

% The elapsed time for above computation is
etime(clock, t0)
pause

t0 = clock;
clc
% Now, we compute it again with respect to all complex blocks, i.e., let
T = [2 2 2 2 2];

% The result is
[r,D] = musol4(M,K,T)

% The elapsed time for above computation is
etime(clock, t0)
pause

clc
% With all complex blocks, the matrix D returned by musol4
% will be such that max(svd(D*M/D))=r.
% Let us check
r
max(svd(D*M/D))
pause

t0 = clock;
clc
% Finally, we compute it again with respect to all real blocks, i.e., let
T = [1 1 1 1 1];

% The result is
[r,D,G] = musol4(M,K,T)

% The elapsed time for above computation is
etime(clock, t0)
pause

clc
% If any block is real, then the matrices D and G returned by musol4
% will be such that the matrix
W = M'*D^2*M + sqrt(-1)*(G*M-M'*G) - r^2*D^2;
% is negative semi-definite, i.e., all the eigenvalues
% of W are nonpositive and at least one of them is zero.
% Let us check

eig(W)
pause

clc
% Equivalently, the generalized Popov multiplier
Mult = D^2 + sqrt(-1)*G/r;
% of Safonov and Lee will be such that the Hermitian part of the matrix
X = Mult*(r*eye(5)-M)/(r*eye(5)+M);
% is positive semi-definite.
% Let us check

eig((X+X')/2)
pause

echo off
format loose
