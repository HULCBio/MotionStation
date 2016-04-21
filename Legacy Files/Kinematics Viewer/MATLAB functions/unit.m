function u = unit(a, dim)
%UNIT   Normalizing vectors with respect to their magnitude.
%   If A is a vector (e.g. Nx1, 1xN, 1x1xN...):
%
%      U = UNIT(A) returns A normalized for magnitude (see function MAGN).
%      If A represents a vectorial quantity, such as the position of a
%      point, U = UNIT(A) can be described as a unit vector aligned with A.
%
%      U = UNIT(A, DIM) is equivalent to UNIT (A) if DIM is the
%      non-singleton dimension of vector A; it returns a vector of ones
%      if DIM is a singleton dimension.
%
%   If A is an N-D array containing more than one vector:
%
%      U = UNIT(A) contains the elements, normalized for magnitude, of the
%      vectors constructed along the first non-singleton dimension of A.
%
%      U = UNIT(A, DIM) contains the elements, normalized for magnitude, 
%      of the vectors constructed along the dimension DIM of A.
%
%   Example:
%   A 5-by-3-by-2 array may be considered to be a block array containing
%   ten 3-element vectors along dimension 2. In this case, its size is so
%   indicated:  5-by-(3)-by-2 or 5x(3)x2. If A is a 5x(3)x2 array,
%   U = UNIT(A, 2) is an array of the same size containing unit vectors. 
%   
%   See also MAGN, DOT, OUTER, CROSS, CROSSDIV, PROJECTION, REJECTION.

% $ Version: 1.3 $
% CODE      by:                 Paolo de Leva (IUSM, Rome, IT) 2005 Sep 9
%           optimized by:       Code author                    2006 Mar 29
% COMMENTS  by:                 Code author                    2006 Mar 29
% OUTPUT    tested by:          Code author                    2005 Sep 9
% -------------------------------------------------------------------------

% Coping with empty input arrays
if isempty(a), u = a; return, end

% Setting DIM if not supplied.
if nargin == 1
   firstNS = find(size(a)>1, 1, 'first'); % First non-singleton dimension
                                          % (empty matrix if A is a scalar)
   dim = max([firstNS, 1]);               % DIM = 1 if A is a scalar
end

% 1 - Computing magnitude of A
mag = magn(a, dim);

% 2 - Cloning MAG N times along its singleton dimension DIM.
N = size(a, dim);
basize = [ones(1,dim-1), N, 1]; % Size of block array
mag2 = repmat(mag, basize);     % MAG2 has same size as A

% 3 - Normalizing A.
u = a ./ mag2;

% NOTE: For vectors with null magnitude, the latter divison (by zero) will
% cause MATLAB to issue a warning. The respective normalized vector will be
% composed of NaNs.
