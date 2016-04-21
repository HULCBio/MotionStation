function y = fftshift(x,dim)
%FFTSHIFT Shift zero-frequency component to center of spectrum.
%   For vectors, FFTSHIFT(X) swaps the left and right halves of
%   X.  For matrices, FFTSHIFT(X) swaps the first and third
%   quadrants and the second and fourth quadrants.  For N-D
%   arrays, FFTSHIFT(X) swaps "half-spaces" of X along each
%   dimension.
%
%   FFTSHIFT(X,DIM) applies the FFTSHIFT operation along the 
%   dimension DIM.
%
%   FFTSHIFT is useful for visualizing the Fourier transform with
%   the zero-frequency component in the middle of the spectrum.
%
%   Class support for input X:
%      float: double, single
%
%   See also IFFTSHIFT, FFT, FFT2, FFTN, CIRCSHIFT.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 5.11.4.3 $  $Date: 2004/03/09 16:16:18 $

if nargin > 1
    if (~isscalar(dim)) || floor(dim) ~= dim || dim < 1
        error('MATLAB:fftshift:DimNotPosInt', 'DIM must be a positive integer.')
    end
    idx = repmat({':'}, 1, max(ndims(x),dim));
    m = size(x, dim);
    p = ceil(m/2);
    idx{dim} = [p+1:m 1:p];
else
    numDims = ndims(x);
    idx = cell(1, numDims);
    for k = 1:numDims
        m = size(x, k);
        p = ceil(m/2);
        idx{k} = [p+1:m 1:p];
    end
end

% Use comma-separated list syntax for N-D indexing.
y = x(idx{:});
