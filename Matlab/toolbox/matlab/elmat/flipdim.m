function y = flipdim(x,dim)
%FLIPDIM Flip matrix along specified dimension.
%   FLIPDIM(X,DIM) returns X with dimension DIM flipped.  
%   For example, FLIPDIM(X,1) where
%   
%       X = 1 4  produces  3 6
%           2 5            2 5
%           3 6            1 4
%
%   See also FLIPLR, FLIPUD, ROT90, PERMUTE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.17.4.1 $  $Date: 2003/05/01 20:41:31 $

% Argument parsing
if (nargin ~= 2)
    error('MATLAB:flipdim:nargin', 'Requires two arguments.');
end
dim = floor(dim);
if (dim <= 0) 
    error('MATLAB:flipdim:DimNotPos', 'DIM must be a positive integer.');
end

dimsize = size(x,dim);
if (dimsize <= 1)
    % No-op.
    y = x;
else
    % Create the index that will transform x.
    v(1:ndims(x)) = {':'};
    % Flip dimension dim.
    v{dim} = dimsize:-1:1;
    % Index with v.
    y = x(v{:});
end
