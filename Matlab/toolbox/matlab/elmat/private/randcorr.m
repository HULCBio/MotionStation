function A = randcorr(x, k)
%RANDCORR Random correlation matrix with specified eigenvalues.
%   GALLERY('RANDCORR',N) is a random N-by-N correlation matrix with
%   random eigenvalues from a uniform distribution.
%   A correlation matrix is a symmetric positive semidefinite matrix with
%   1s on the diagonal (see CORRCOEF).
%
%   GALLERY('RANDCORR',X) produces a random correlation matrix
%   having eigenvalues given by the vector X, where LENGTH(X) > 1.
%   X must have nonnegative elements summing to LENGTH(X).
%
%   An additional argument, K, can be supplied.
%   For K = 0 (the default) the diagonal matrix of eigenvalues is initially
%       subjected to a random orthogonal similarity transformation and then
%       a sequence of Givens rotations is applied.
%   For K = 1, the initial transformation is omitted. This is much faster,
%       but the resulting matrix may have some zero entries.

%  References:
%  [1] R. B. Bendel and M. R. Mickey, Population correlation matrices
%      for sampling experiments, Commun. Statist. Simulation Comput.,
%      B7 (1978), pp. 163-182.
%  [2] P. I. Davies and N. J. Higham, Numerically stable generation of
%      correlation matrices and their factors, BIT, 40 (2000), pp. 640-651.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.5.4.1 $  $Date: 2003/05/19 11:16:13 $

if nargin < 2, k = 0; end

n = length(x);
if n == 1 %  Handle scalar x.
   n = x;
   x = rand(n,1); x = n*x/sum(x);
end

if abs(sum(x)-n)/n > 100*eps | any(x < 0)
   error('MATLAB:randcorr:InvalidX',...
         'Elements of x must be nonnegative and sum to n.\n')
end

A = diag(x);
if k == 0
   Q = qmult(n);
   A = Q*A*Q';  % Not exploiting symmetry here.
end

a = diag(A);
y = find(a < 1);
z = find(a > 1);

while length(y) > 0 && length(z) > 0

    i = y(ceil(rand*length(y)));
    j = z(ceil(rand*length(z)));
    if i > j, temp = i; i = j; j = temp; end

    alpha = sqrt(A(i,j)^2 - (a(i)-1)*(a(j)-1));
    t(1) = (A(i,j) + mysign(A(i,j))*alpha)/(a(j)-1);
    t(2) = (a(i)-1)/((a(j)-1)*t(1));
    t = t(ceil(rand*2));  % Choose randomly from the two roots.
    c = 1/sqrt(1 + t^2);
    s = t*c;

    A(:,[i,j]) =  A(:,[i,j]) * [c s; -s c];
    A([i,j],:) = [c -s; s c] * A([i,j],:);

    % Ensure (i,i) element is exactly 1.
    A(i,i) = 1;

    a = diag(A);
    y = find(a < 1);
    z = find(a > 1);

end

% As last diagonal element was not explicitly set to 1:
for i = 1:n, A(i,i) = 1; end
A = (A + A')/2; % Force symmetry.
