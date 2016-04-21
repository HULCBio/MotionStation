function b = magn (a, varargin)
%MAGN   Magnitude (or Euclidian norm) of vectors.
%   If A is a vector (e.g. Nx1, 1xN, 1x1xN, ...):
%
%      B = MAGN(A) is a scalar (1x1), equal to the magnitude of vector A.
%
%      B = MAGN(A, DIM) is eqivalent to MAGN(A) if DIM is the non-singleton
%      dimension of A; it is equal to A if DIM is a singleton dimension.
%
%   If A is an N-D array containing more than one vector (i.e. with two
%   or more non-singleton dimensions):
%
%      B = MAGN(A) is an N-D array containing the magnitudes of the
%      vectors constructed along the first non-singleton dimension of A.
%
%      B = MAGN(A, DIM) is an N-D array containing the magnitudes of the
%      vectors constructed along the dimension DIM of A.
%
%   Examples:
%   If A is a 3x10 matrix, then B = MAGN (A) is a 1x10 row vector listing
%   the magnitudes of the ten column vectors (3x1) contained in A, and 
%   B = MAGN (A, 2) is a column vector (3x1) listing the magnitudes of the
%   three row vectors (1x10) contained in A.
%
%   If A is a 4x5x25 3-D array, then B = MAGN (A, 2) is a 4x1x25 3-D array
%   containing the magnitudes of the 100 row vectors (1x5x1) constructed
%   along the second dimension of A.
%   
%   See also SUM, UNIT, DOT, OUTER, CROSS, CROSSDIV, PROJECTION, REJECTION.

% $ Version: 1.1 $
% CODE      by:                 Paolo de Leva (IUSM, Rome, IT) 2005 Aug 1
% COMMENTS  by:                 Code author                    2005 Sep 27
% OUTPUT    tested by:          Code author                    2005 Aug 1
% -------------------------------------------------------------------------

b0 = dot(a, a, varargin{:}); % Equivalent to SUM(A.^2, VARARGIN{:})
b  = sqrt (b0);