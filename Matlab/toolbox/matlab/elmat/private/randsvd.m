function A = randsvd(n, kappa, mode, kl, ku, method)
%RANDSVD Random matrix with pre-assigned singular values.
%   A = GALLERY('RANDSVD', N, KAPPA, MODE, KL, KU) is a banded random
%   matrix of order N with COND(A) = KAPPA and singular values from the
%   distribution MODE. If N is a two-element vector, A is N(1)-by-N(2).
%
%   MODE may be one of the following values:
%       1: one large singular value,
%       2: one small singular value,
%       3: geometrically distributed singular values,
%       4: arithmetically distributed singular values,
%       5: random singular values with uniformly distributed logarithm.
%   If omitted, MODE defaults to 3, and KAPPA defaults to SQRT(1/EPS).
%   If MODE < 0 then the effect is as for ABS(MODE) except that in the
%   original matrix of singular values the order of the diagonal
%   entries is reversed: small to large instead of large to small.
%
%   KL and KU are the number of lower and upper off-diagonals
%   respectively. If they are omitted, a full matrix is produced.
%   If only KL is present, KU defaults to KL.
%
%   Special case: KAPPA < 0
%      A is a random full symmetric positive definite matrix with
%      COND(A) = -KAPPA and eigenvalues distributed according to
%      MODE. KL and KU, if present, are ignored.
%
%   A = GALLERY('RANDSVD', N, KAPPA, MODE, KL, KU, METHOD) specifies
%   how the computations are carried out.
%   METHOD = 0 is the default, while METHOD = 1 uses an alternative
%   method that is much faster for large dimensions, even though it uses
%   more flops.

%   Acknowledgement:
%   This routine is similar to the more comprehensive Fortran routine
%   xLATMS in the following reference:
%
%   Reference:
%   [1] J. W. Demmel and A. McKenney, A test matrix generation suite,
%       LAPACK Working Note #9, Courant Institute of Mathematical
%       Sciences, New York, 1989.
%
%   Nicholas J. Higham
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.13.4.2 $  $Date: 2004/01/24 09:21:45 $

if nargin < 2 || isempty(kappa), kappa = sqrt(1/eps); end
if nargin < 3 || isempty(mode), mode = 3; end
if nargin < 4 || isempty(kl), kl = n-1; end  % Full matrix.
if nargin < 5 || isempty(ku), ku = kl; end   % Same upper and lower bandwidths.
if nargin < 6, method = 0; end

if abs(kappa) < 1 
  error('MATLAB:randsvd:KappaLTOne', 'Condition number must be at least 1!') 
end
posdef = 0; if kappa < 0, posdef = 1; kappa = -kappa; end  % Special case.

p = min(n);
m = n(1);              % Parameter n specifies dimension: m-by-n.
n = n(length(n));

if p == 1              % Handle case where A is a vector.
   A = randn(m, n);
   A = A/norm(A);
   return
end

% Set up vector sigma of singular values.
switch abs(mode)

   case 1
        sigma = ones(p,1)./kappa;
        sigma(1) = 1;

   case 2
        sigma = ones(p,1);
        sigma(p) = 1/kappa;

   case 3
        factor = kappa^(-1/(p-1));
        sigma = factor.^(0:p-1);

   case 4
        sigma = ones(p,1) - (0:p-1)'/(p-1)*(1-1/kappa);

   case 5    % In this case cond(A) <= kappa.
        sigma = exp( -rand(p,1)*log(kappa) );

end

% Convert to diagonal matrix of singular values.
if mode < 0
   sigma = sigma(p:-1:1);
end
sigma = diag(sigma);

if posdef                % Handle special case.
   Q = qmult(p,method);
   A = Q'*sigma*Q;
   A = (A + A')/2;       % Ensure matrix is symmetric.
   return
end

if m ~= n
   sigma(m, n) = 0;      % Expand to m-by-n diagonal matrix.
end

if kl == 0 & ku == 0     % Diagonal matrix requested - nothing more to do.
   A = sigma;
   return
end

% A = U*sigma*V, where U, V are random orthogonal matrices from the
% Haar distribution.
A = qmult(sigma',method);
A = qmult(A',method);

if kl < n-1 | ku < n-1   % Bandwidth reduction.
   A = bandred(A, kl, ku);
end
