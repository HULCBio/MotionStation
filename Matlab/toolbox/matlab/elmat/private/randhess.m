function H = randhess(x)
%RANDHESS Random, orthogonal upper Hessenberg matrix.
%   H = GALLERY('RANDHESS',N) returns an N-by-N real, random,
%   orthogonal upper Hessenberg matrix.
%
%   H = GALLERY('RANDHESS',X), where X is an arbitrary real N-vector
%   (N > 1), constructs H non-randomly using the elements of X
%   as parameters.
%
%   In both cases, H is constructed via a product of N-1 Givens rotations.

%   Note:
%   See [1] for representing an N-by-N (complex) unitary Hessenberg
%   matrix with positive subdiagonal elements in terms of 2N-1 real
%   parameters (the Schur parametrization). This M-file handles the
%   real case only and is intended simply as a convenient way to
%   generate random or non-random orthogonal Hessenberg matrices.
%
%   Reference:
%   [1] W. B. Gragg, The QR algorithm for unitary Hessenberg matrices,
%       J. Comp. Appl. Math., 16 (1986), pp. 1-8.
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.12.4.1 $  $Date: 2003/05/19 11:16:14 $

if ~isreal(x) 
  error('MATLAB:randhess:ComplexParam','Parameter must be real.') 
end

n = length(x);

if n == 1
%  Handle scalar x.
   n = x;
   x = rand(n-1,1)*2*pi;
   H = eye(n);
   H(n,n) = mysign(randn);
else
   H = eye(n);
   H(n,n) = mysign(x(n));
end

for i=n:-1:2
    % Apply Givens rotation through angle x(i-1).
    theta = x(i-1);
    c = cos(theta);
    s = sin(theta);
    H([i-1 i],:) = [c s; -s c] * H([i-1 i],:);
end
