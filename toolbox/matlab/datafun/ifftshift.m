function y = ifftshift(x,dim)
%IFFTSHIFT Inverse FFT shift.
%   For vectors, IFFTSHIFT(X) swaps the left and right halves of
%   X.  For matrices, IFFTSHIFT(X) swaps the first and third
%   quadrants and the second and fourth quadrants.  For N-D
%   arrays, IFFTSHIFT(X) swaps "half-spaces" of X along each
%   dimension.
%
%   IFFTSHIFT(X,DIM) applies the IFFTSHIFT operation along the 
%   dimension DIM.
%
%   IFFTSHIFT undoes the effects of FFTSHIFT.
%
%   Class support for input X: 
%      float: double, single
%
%   See also FFTSHIFT, FFT, FFT2, FFTN.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.6.4.3 $  $Date: 2004/03/09 16:16:25 $

if nargin > 1
    if (~isscalar(dim)) || floor(dim) ~= dim || dim < 1
        error('MATLAB:ifftshift:DimNotPosInt','DIM must be a positive integer.')
    end
    idx = repmat({':'}, 1, max(ndims(x),dim));
    m = size(x, dim);
    p = floor(m/2);
    idx{dim} = [p+1:m 1:p];
else
    numDims = ndims(x);
    idx = cell(1, numDims);
    for k = 1:numDims
        m = size(x, k);
        p = floor(m/2);
        idx{k} = [p+1:m 1:p];
    end
end

% Use comma-separated list syntax for N-D indexing.
y = x(idx{:});
