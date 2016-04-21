function z = cumtrapz(x,y,dim)
%CUMTRAPZ Cumulative trapezoidal numerical integration.
%   Z = CUMTRAPZ(Y) computes an approximation of the cumulative
%   integral of Y via the trapezoidal method (with unit spacing).  To
%   compute the integral for spacing different from one, multiply Z by
%   the spacing increment.
%
%   For vectors, CUMTRAPZ(Y) is a vector containing the cumulative
%   integral of Y. For matrices, CUMTRAPZ(Y) is a matrix the same size as
%   X with the cumulative integral over each column. For N-D arrays,
%   CUMTRAPZ(Y) works along the first non-singleton dimension.
%
%   Z = CUMTRAPZ(X,Y) computes the cumulative integral of Y with respect
%   to X using trapezoidal integration.  X and Y must be vectors of the
%   same length, or X must be a column vector and Y an array whose first
%   non-singleton dimension is length(X).  CUMTRAPZ operates across this
%   dimension.
%
%   Z = CUMTRAPZ(X,Y,DIM) or CUMTRAPZ(Y,DIM) integrates along dimension
%   DIM of Y. The length of X must be the same as size(Y,DIM)).
%
%   Example: If Y = [0 1 2
%                    3 4 5]
%
%   then cumtrapz(Y,1) is [0   0   0    and cumtrapz(Y,2) is [0 0.5 2
%                          1.5 2.5 3.5]                       0 3.5 8];
%
%   Class support for inputs X,Y:
%      float: double, single
%
%   See also CUMSUM, TRAPZ.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.15.4.2 $  $Date: 2004/03/09 16:16:13 $

%   Make sure x and y are column vectors, or y is a matrix.

perm = []; nshifts = 0;
if nargin == 3, % cumtrapz(x,y,dim)
  perm = [dim:max(length(size(y)),dim) 1:dim-1];
  y = permute(y,perm);
  [m,n] = size(y);
elseif nargin==2 && isequal(size(y),[1 1]) % cumtrapz(y,dim)
  dim = y; y = x;
  perm = [dim:max(length(size(y)),dim) 1:dim-1];
  y = permute(y,perm);
  [m,n] = size(y);
  x = 1:m;
else
  if nargin < 2, y = x; end
  [y,nshifts] = shiftdim(y);
  [m,n] = size(y);
  if nargin < 2, x = 1:m; end
end
x = x(:);
if length(x) ~= m
    error('MATLAB:cumtrapz:LengthXMismatchY',...
          'length(x) must equal length of first non-singleton dim of y.');
end

dt = repmat(diff(x,1,1)/2,1,n);
z = [zeros(1,n,class(y)); cumsum(dt .* (y(1:m-1,:) + y(2:m,:)),1)];

siz = size(y); siz(1) = max(1,siz(1));
z = reshape(z,[ones(1,nshifts),siz]);
if ~isempty(perm), z = ipermute(z,perm); end
