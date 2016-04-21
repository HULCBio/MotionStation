function t = toeplitz(c,r)
%TOEPLITZ Toeplitz matrix.
%   TOEPLITZ(C,R) is a non-symmetric Toeplitz matrix having C as its
%   first column and R as its first row.   
%
%   TOEPLITZ(R) is a symmetric (or Hermitian) Toeplitz matrix.
%
%   See also HANKEL.

%   Revised 10-8-92, LS - code from A.K. Booer.
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.11 $  $Date: 2002/04/15 03:45:12 $

if nargin < 2,
  c(1) = conj(c(1)); r = c; c = conj(c); % set up for Hermitian Toeplitz
else
  if r(1) ~= c(1)
    warning('MATLAB:toeplitz:DiagonalConflict',['First element of ' ...
           'input column does not match first element of input row. ' ...
           '\n         Column wins diagonal conflict.'])
end
end
%
r = r(:);                               % force column structure
p = length(r);
m = length(c);
x = [r(p:-1:2) ; c(:)];                 % build vector of user data
%
cidx = (0:m-1)';
ridx = p:-1:1;
t = cidx(:,ones(p,1)) + ridx(ones(m,1),:);    % Toeplitz subscripts
t(:) = x(t);                            % actual data

