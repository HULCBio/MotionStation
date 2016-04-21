function H = hankel(c,r)
%HANKEL Hankel matrix.
%   HANKEL(C) is a square Hankel matrix whose first column is C and
%   whose elements are zero below the first anti-diagonal.
%
%   HANKEL(C,R) is a Hankel matrix whose first column is C and whose
%   last row is R.
%
%   Hankel matrices are symmetric, constant across the anti-diagonals,
%   and have elements H(i,j) = P(i+j-1) where P = [C R(2:END)]
%   completely determines the Hankel matrix.
%
%   See also TOEPLITZ.

%   J.N. Little 4-22-87
%   Revised 1-28-88 JNL
%   Revised 2-25-95 Jim McClellan 
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.12 $  $Date: 2002/04/15 03:45:20 $

c = c(:);
nc = length(c);

if nargin < 2,
   r = zeros(size(c));   %-- will need zeros below main diagonal
elseif c(nc) ~= r(1)
   warning('MATLAB:hankel:AntiDiagonalConflict',['Last element of ' ...
           'input column does not match first element of input row. ' ...
           '\n         Column wins anti-diagonal conflict.'])
end

r = r(:);                       %-- force column structure
nr = length(r);

x = [ c; r((2:nr)') ];          %-- build vector of user data
%
cidx = (1:nc)';
ridx = 0:(nr-1);
H = cidx(:,ones(nr,1)) + ridx(ones(nc,1),:);  % Hankel subscripts
H(:) = x(H);                            % actual data

