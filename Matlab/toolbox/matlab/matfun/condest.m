function [c, v] = condest(A,t)
%CONDEST 1-norm condition number estimate.
%   C = CONDEST(A) computes a lower bound C for the 1-norm condition
%   number of a square matrix A.
%
%   C = CONDEST(A,T) changes T, a positive integer parameter equal to
%   the number of columns in an underlying iteration matrix.  Increasing the
%   number of columns usually gives a better condition estimate but increases
%   the cost.  The default is T = 2, which almost always gives an estimate
%   correct to within a factor 2.
%
%   [C,V] = CONDEST(A) also computes a vector V which is an approximate null
%   vector if C is large.  V satisfies NORM(A*V,1) = NORM(A,1)*NORM(V,1)/C.
%
%   Note: CONDEST invokes RAND.  If repeatable results are required then
%   invoke RAND('STATE',J), for some J, before calling this function.
%
%   Uses block 1-norm power method of Higham and Tisseur.
%
%   See also NORMEST1, COND, NORM.

%   Nicholas J. Higham, 9-8-99
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.18.4.1 $  $Date: 2003/05/01 20:42:31 $

if size(A,1) ~= size(A,2)
   error('MATLAB:condest:NonSquareMatrix', 'Matrix must be square.')
end
if isempty(A), c = 0; v = []; return, end
if nargin < 2, t = []; end
warns = warning('query','all');
warning('off','all');
[L,U] = lu(A);
k = find(abs(diag(U))==0);
if ~isempty(k)
   c = Inf;
   n = max(size(A));
   v = zeros(n,1);
   k = min(k);
   v(k) = 1;
   if k > 1
      v(1:k-1) = U(1:k-1,1:k-1)\(-U(1:k-1,k));
   end
else
   [Ainv_norm, temp, v] = normest1(@condestf,t,[],L,U);
   A_norm = norm(A,1);
   c = Ainv_norm*A_norm;
end
v = v/norm(v,1);
warning(warns)

function f = condestf(flag, X, L, U)
%CONDESTF   Function used by CONDEST.

if isequal(flag,'dim')
   f = max(size(L));
elseif isequal(flag,'real')
   f = isreal(L) & isreal(U);
elseif isequal(flag,'notransp')
   f = U\(L\X);
elseif isequal(flag,'transp')
   f = L'\(U'\X);
end
