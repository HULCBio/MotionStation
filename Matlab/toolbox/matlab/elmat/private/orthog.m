function Q = orthog(n, k)
%ORTHOG Orthogonal and nearly orthogonal matrices.
%   Q = GALLERY('ORTHOG',N,K) selects the K'th type of matrix of
%   order N. K > 0 for exactly orthogonal matrices, and K < 0 for
%   diagonal scalings of orthogonal matrices.
%
%   Available types are:
%   K = 1:  Q(i,j) = SQRT(2/(n+1)) * SIN( i*j*PI/(n+1) )
%           Symmetric eigenvector matrix for second difference matrix.
%           This is the default K.
%   K = 2:  Q(i,j) = 2/SQRT(2*n+1)) * SIN( 2*i*j*PI/(2*n+1) )
%           Symmetric.
%   K = 3:  Q(r,s) = EXP(2*PI*i*(r-1)*(s-1)/n) / SQRT(n)
%           Unitary, the Fourier matrix.  Q^4 is the identity.
%           This is essentially the same matrix as FFT(EYE(N))/SQRT(N)!
%   K = 4:  Helmert matrix: a permutation of a lower Hessenberg matrix,
%           whose first row is ONES(1:N)/SQRT(N).
%   K = 5:  Q(i,j) = SIN( 2*PI*(i-1)*(j-1)/n ) + COS( 2*PI*(i-1)*(j-1)/n ).
%           Symmetric matrix arising in the Hartley transform.
%   K = 6:  Q(i,j) = SQRT(2/N)*COS( (i-1/2)*(j-1/2)*PI/n ).
%           Symmetric matrix arising as a discrete cosine transform.
%   K = 7:  A particular Householder matrix: symmetric with
%           column sums SUM(Q) = [SQRT(n) zeros(1,n-1)].
%   K = -1: Q(i,j) = COS( (i-1)*(j-1)*PI/(n-1) )
%           Chebyshev Vandermonde-like matrix, based on extrema
%           of T(n-1).
%   K = -2: Q(i,j) = COS( (i-1)*(j-1/2)*PI/n) )
%           Chebyshev Vandermonde-like matrix, based on zeros of T(n).

%   References:
%   [1] N. J. Higham and D. J. Higham, Large growth factors in Gaussian
%       elimination with pivoting, SIAM J. Matrix Analysis and  Appl.,
%       10 (1989), pp. 155-164.
%   [2] P. Morton, On the eigenvectors of Schur's matrix, J. Number Theory,
%       12 (1980), pp. 122-127. (Re. orthog(n, 3))
%   [3] H. O. Lancaster, The Helmert Matrices, Amer. Math. Monthly,
%       72 (1965), pp. 4-12.
%   [4] D. Bini and P. Favati, On a matrix algebra related to the discrete
%       Hartley transform, SIAM J. Matrix Anal. Appl., 14 (1993),
%       pp. 500-507.
%   [5] G. Strang, The discrete cosine transform, SIAM Review, 41 (1999),
%       pp. 135-147.
%   [6] R. N. Khoury, Closest matrices in the space of generalized doubly
%       stochastic matrices, J. Math. Anal. and Appl., 222 (1998), pp. 562-568.
%       (Re. orthog(n, 7))
%
%   Nicholas J. Higham
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.10.4.3 $  $Date: 2004/01/24 09:21:43 $

if nargin == 1, k = 1; end

if k == 1
                                       % E'vectors second difference matrix
   m = (1:n)'*(1:n) * (pi/(n+1));
   Q = sin(m) * sqrt(2/(n+1));

elseif k == 2

   m = (1:n)'*(1:n) * (2*pi/(2*n+1));
   Q = sin(m) * (2/sqrt(2*n+1));

elseif k == 3                          % Vandermonde based on roots of unity

   m = 0:n-1;
   Q = exp(m'*m*2*pi*sqrt(-1)/n) / sqrt(n);

elseif k == 4                          % Helmert matrix

   Q = tril(ones(n));
   Q(1,2:n) = ones(1,n-1);
   for i=2:n
       Q(i,i) = -(i-1);
   end
   Q = diag( sqrt( [n 1:n-1] .* (1:n) ) ) \ Q;

elseif k == 5                          % Hartley matrix

   m = (0:n-1)'*(0:n-1) * (2*pi/n);
   Q = (cos(m) + sin(m))/sqrt(n);

elseif k == 6                          % DCT4

   m = (1:n)' -1/2; m = (m*m')*pi/n;
   Q = sqrt(2/n)*cos(m);

elseif k == 7                          % Particular Householder matrix.

   Q = ones(n)/sqrt(n);
   Q(2:end,2:end) = eye(n-1) - ones(n-1) * (1 + 1/sqrt(n))/(n-1);

elseif k == -1
                                       % Extrema of T(n-1)
   m = (0:n-1)'*(0:n-1) * (pi/(n-1));
   Q = cos(m);

elseif k == -2
                                       % Zeros of T(n)
   m = (0:n-1)'*(.5:n-.5) * (pi/n);
   Q = cos(m);

else

   error('MATLAB:orthog:InvalidParam2', 'Illegal value for second parameter.')

end
