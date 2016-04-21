function c = cond(A, p)
%COND   Condition number with respect to inversion.
%   COND(X) returns the 2-norm condition number (the ratio of the
%   largest singular value of X to the smallest).  Large condition
%   numbers indicate a nearly singular matrix.
%
%   COND(X,P) returns the condition number of X in P-norm:
%
%      NORM(X,P) * NORM(INV(X),P). 
%
%   where P = 1, 2, inf, or 'fro'. 
%
%   Class support for input X:
%      float: double, single
%
%   See also RCOND, CONDEST, CONDEIG, NORM, NORMEST.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.15.4.2 $  $Date: 2004/04/10 23:29:57 $

if nargin == 1, p = 2; end

if isempty(A)
    c = zeros(class(A));
    return
end
if issparse(A)
    warning('MATLAB:cond:SparseNotSupported', ...
        'Using CONDEST instead of COND for sparse matrix.')
    c = condest(A);
    return
end

[m, n] = size(A);
if m ~= n && p ~= 2
   error('MATLAB:cond:normMismatchSizeA', 'A is rectangular.  Use the 2 norm.')
end

if p == 2
   s = svd(A);
   if any(s == 0)   % Handle singular matrix
       c = Inf(class(A));
   else
       c = max(s)./min(s);
   end
else
%  We'll let NORM pick up any invalid p argument.
   c = norm(A, p) * norm(inv(A), p);
end
