function A = compan(c)
%COMPAN Companion matrix.
%   COMPAN(P) is a companion matrix of the polynomial
%   with coefficients P.

%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.7.4.1 $  $Date: 2003/05/01 20:41:29 $

if min(size(c)) > 1
    error('MATLAB:compan:NeedVectorInput', 'Input argument must be a vector.')
end
n = length(c);
if n <= 1
   A = [];
elseif n == 2
   A = -c(2)/c(1);
else
   c = c(:).';     % make sure it's a row vector
   A = diag(ones(1,n-2),-1);
   A(1,:) = -c(2:n) ./ c(1);
end
