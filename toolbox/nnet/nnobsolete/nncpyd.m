function y = nncpyd(x)
%NNCPYD Copy vectors in a matrix onto diagonals.
%  
%  This function is obselete.

nntobsf('nncpyd','')
  
%  *WARNING*: This function is undocumented as it may be altered
%  at any time in the future without warning.

% NNCPYD(X)
%   X - NxM Matrix of column vectors.
% Returns Nx(N*M) matrix of M NxN diagonal matrices
%   with the columns of X on each diagonal.
%
% EXAMPLE: X = [1 2; 3 4; 5 6];
%          Y = nncpyd(X)
%
% SEE ALSO: nncpy, nncpyi

% Mark Beale, 12-15-93
% Copyright 1992-2002 The MathWorks, Inc.
% $Revision: 1.11 $  $Date: 2002/04/14 21:14:59 $

[xr,xc] = size(x);

y = zeros(xr,xr*xc);

i = 1:xr;
for j=0:xr:((xc-1)*xr)
  y(i+(i+j-1)*xr) = x(i+j);
end
