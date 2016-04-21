function T = triw(n, alpha, k)
%TRIW   Upper triangular matrix discussed by Wilkinson and others.
%   GALLERY('TRIW',N,ALPHA,K) is the upper triangular matrix with
%   ones on the diagonal and ALPHAs on the first K >= 0 superdiagonals.
%   N may be a 2-vector, in which case the matrix is N(1)-by-N(2)
%   and upper trapezoidal.
%   The defaults are ALPHA = -1, and K = N - 1. This yields the full
%   upper triangular matrix discussed by Kahan, Golub and Wilkinson.
%
%   Notes:
%   Ostrowski [3] shows that
%     COND(TRIW(N,2)) = COT(PI/(4*N))^2,
%   and for large ABS(ALPHA),
%     COND(TRIW(N,ALPHA)) is approx. ABS(ALPHA)^N*SIN(PI/(4*N-2)).
%
%   Adding -2^(2-N) to the (N,1) element makes TRIW(N) singular,
%   as does adding -2^(1-N) to all elements in the first column.

%   References:
%   [1] G. H. Golub and J. H. Wilkinson, Ill-conditioned eigensystems and
%       the computation of the Jordan canonical form, SIAM Review,
%       18(4), 1976, pp. 578-619.
%   [2] W. Kahan, Numerical linear algebra, Canadian Math. Bulletin,
%       9 (1966), pp. 757-801.
%   [3] A. M. Ostrowski, On the spectrum of a one-parametric family of
%       matrices, J. Reine Angew. Math., 193 (3/4), 1954, pp. 143-160.
%   [4] J. H. Wilkinson, Singular-value decomposition---basic aspects,
%       in D.A.H. Jacobs, ed., Numerical Software---Needs and Availability,
%       Academic Press, London, 1978, pp. 109-135.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/15 03:41:44 $

m = n(1);              % Parameter n specifies dimension: m-by-n.
n = n(length(n));

if nargin < 3, k = n-1; end
if nargin < 2, alpha = -1; end

T = tril( eye(m,n) + alpha*triu(ones(m,n), 1), k);
