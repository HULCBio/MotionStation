function C = cauchy(x, y)
%CAUCHY Cauchy matrix.
%   C = GALLERY('CAUCHY',X,Y), where X and Y are N-vectors, is the
%   N-by-N matrix with C(i,j) = 1/(X(i)+Y(j)). By default, Y = X.
%   If X is a scalar, GALLERY('CAUCHY',X) is the same as
%   GALLERY('CAUCHY',1:X).
%
%   Explicit formulas are known for the elements of INV(C) and DET(C).
%   DET(C) is nonzero if X and Y both have distinct elements.
%   C is totally positive if 0 < X(1) < ... < X(N) and
%                            0 < Y(1) < ... < Y(N).

%   References:
%   [1] D. E. Knuth, The Art of Computer Programming, Volume 1,
%       Fundamental Algorithms, third edition, Addison-Wesley, Reading,
%       Massachusetts, 1997.
%   [2] E. E. Tyrtyshnikov, Cauchy-Toeplitz matrices and some applications,
%       Linear Algebra and Appl., 149 (1991), pp. 1-18.
%   [3] O. Taussky and M. Marcus, Eigenvalues of finite matrices, in
%       Survey of Numerical Analysis, J. Todd, ed., McGraw-Hill, New York,
%       1962, pp. 279-313. (The totally positive property is on p. 295.)
%
%   Nicholas J. Higham, Dec 1999.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.11.4.1 $  $Date: 2003/05/19 11:16:05 $

n = length(x);
%  Handle scalar x.
if n == 1
   n = x;
   x = 1:n;
end

if nargin == 1, y = x; end

x = x(:); y = y(:);   % Ensure x and y are column vectors.
if length(x) ~= length(y)
   error('MATLAB:cauchy:ParamLengthMismatch',...
         'Parameter vectors must be of same dimension.')
end

C = x*ones(1,n) + ones(n,1)*y.';
C = ones(n) ./ C;
