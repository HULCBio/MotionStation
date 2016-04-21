function A = randcolu(n, x, k)
%RANDCOLU Random matrix with normalized columns and specified singular values.
%   A = GALLERY('RANDCOLU',N) is a random N-by-N matrix with columns of
%   unit 2-norm, with random singular values whose squares are from a
%   uniform distribution.
%   A'*A is a correlation matrix of the form produced by
%   GALLERY('RANDCORR',N).
%
%   GALLERY('RANDCOLU',X), where X is an N-vector (N > 1), produces
%   a random N-by-N matrix having singular values given by the vector X.
%   X must have nonnegative elements whose sum of squares is N.
%   GALLERY('RANDCOLU',X,M), where M >= N, produces an M-by-N matrix.
%   GALLERY('RANDCOLU',X,M,K) provides a further option:
%   For K = 0 (the default) DIAG(X) is initially subjected to a random
%       two-sided orthogonal transformation and then a sequence of
%       Givens rotations is applied.
%   For K = 1, the initial transformation is omitted. This is much faster,
%       but the resulting matrix may have zero entries.

%  Reference:
%  [1] P. I. Davies and N. J. Higham, Numerically stable generation of
%      correlation matrices and their factors, BIT, 40 (2000), pp. 640-651.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/05/19 11:16:12 $

if nargin < 3, k = 0; end
if nargin >= 2, m = x; x = n; n = length(x); end
if nargin == 1
   if length(n) > 1
      x = n;
      n = length(x);
   else
      x = rand(n,1);
      x = sqrt(n)*x/norm(x);
   end
   m = n;
end

if m < n 
  error('MATLAB:randcolu:SizeM', 'M should be >= LENGTH(X).') 
end
if abs(sum(x.^2) - n)/n > 100*eps | any(x < 0)
   error('MATLAB:randcolu:InvalidX',...
         'Elements of X must be nonnegative with sum of squares N.')
end

A = zeros(m,n);
for i = 1:n
   A(i,i) = x(i);
end

if k == 0
   A = qmult(A);    % Forming A --> U*A*V where U and V are two random
   A = qmult(A')';  %               orthogonal matrices.
end

a = sum(A .* A);

y = find(a<1);
z = find(a>1);

while length(y) > 0 && length(z) > 0

   i = y(ceil(rand*length(y)));
   j = z(ceil(rand*length(z)));
   if i > j, temp = i; i = j; j = temp; end

   aij = A(:,i)'*A(:,j);
   alpha = sqrt(aij^2 - (a(i)-1)*(a(j)-1));

   t(1) = (aij + mysign(aij)*alpha)/(a(j)-1);
   t(2) = (a(i)-1)/((a(j)-1)*t(1));
   t = t(ceil(rand*2));  % Choose randomly from the two roots.
   c = 1/sqrt(1 + t^2) ;  s = t*c ;

   A(:,[i,j]) =   A(:,[i,j]) * [c s ; -s c] ;

   a(j) = a(j) + a(i) - 1;
   a(i) = 1;

   y = find(a<1);
   z = find(a>1);

end
