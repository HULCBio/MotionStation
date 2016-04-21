function [v, beta, s] = house(x, k)
%HOUSE Householder matrix that reduces a vector to a multiple of e_1.
%   [V, BETA, S] = GALLERY('HOUSE',X, K) takes an N-by-1 vector X
%   and returns V and BETA such that H*X = S*e_1,
%   where e_1 is the first column of EYE(N), ABS(S) = NORM(X),
%   and H = EYE(N) - BETA*V*V' is a Householder matrix.
%   The parameter K determines the sign of S:
%      K = 0 (default): sign(S) = -sign(X(1)) ("usual" choice),
%      K = 1:           sign(S) = sign(X(1))  (alternative choice).
%   If X is real then a further option, for real X only, is
%      K = 2:           sign(S) = 1.
%   If X is complex, then sign(X) = exp(i*arg(X)) which equals X./abs(X) 
%   when X ~= 0.
%   In two special cases V = 0, BETA = 1 and S = X(1) are returned
%   (hence H = I, which is not strictly a Householder matrix):
%      - When X = 0.
%      - When X = alpha*e_1 and either K = 1, or K = 2 and alpha >= 0.

%   References:
%   [1] G. H. Golub and C. F. Van Loan, Matrix Computations, third edition,
%       Johns Hopkins University Press, Baltimore, Maryland, 1996, Sec. 5.1.
%   [2] N. J. Higham, Accuracy and Stability of Numerical Algorithms,
%       Society for Industrial and Applied Mathematics,
%       Philadelphia, PA, 1996; Sec. 18.1.
%   [3] G. W. Stewart, Introduction to Matrix Computations, Academic Press,
%       New York, 1973, pp. 231-234, 262.
%   [4] J. H. Wilkinson, The Algebraic Eigenvalue Problem, Oxford University
%       Press, 1965, pp. 48-50.
%
%   Nicholas J. Higham
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.11.4.2 $  $Date: 2004/01/24 09:21:41 $
  
[n, m] = size(x);
if m > 1, error('MATLAB:house:ArgSize','Argument must be a column vector.'), end
if nargin < 2, k = 0; end

v = x;
nrmx = norm(x);
if nrmx == 0, beta = 1; s = 0; return, end    % Quit if x is the zero vector.

s = nrmx * mysign(x(1));

if k == 2
   if ~any(imag(x))
      if s < 0, k = 0; else k = 1; end
   else
      k = 0;
   end
end

if k == 0
   s = -s;
   v(1) = v(1) - s;      
else
   v(1) = -norm(x(2:n))^2 / (x(1)+s)';     % NB the conjugate.
   if v(1) == 0 % Special case where V = 0: need H = I.
      beta = 1;
      return
   end
end
beta = -1/(s'*v(1));                       % NB the conjugate.
