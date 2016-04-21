function r = roots(c)
%ROOTS  Find polynomial roots.
%   ROOTS(C) computes the roots of the polynomial whose coefficients
%   are the elements of the vector C. If C has N+1 components,
%   the polynomial is C(1)*X^N + ... + C(N)*X + C(N+1).
%
%   Class support for input c: 
%      float: double, single
%
%   See also POLY, RESIDUE, FZERO.

%   J.N. Little 3-17-86
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.12.4.2 $  $Date: 2004/03/02 21:48:05 $

% ROOTS finds the eigenvalues of the associated companion matrix.

if size(c,1)>1 && size(c,2)>1
    error('MATLAB:roots:NonVectorInput', 'Input must be a vector.')
end
c = c(:).';
n = size(c,2);
r = zeros(0,1,class(c));  

inz = find(c);
if isempty(inz),
    % All elements are zero
    return
end

% Strip leading zeros and throw away.  
% Strip trailing zeros, but remember them as roots at zero.
nnz = length(inz);
c = c(inz(1):inz(nnz));
r = zeros(n-inz(nnz),1,class(c));  

% Polynomial roots via a companion matrix
n = length(c);
if n > 1
    a = diag(ones(1,n-2,class(c)),-1);
    a(1,:) = -c(2:n) ./ c(1);
    r = [r;eig(a)];
end
