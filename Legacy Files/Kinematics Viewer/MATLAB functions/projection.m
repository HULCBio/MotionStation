function Apar = projection(a, b, dim)
%PROJECTION  Vector component of vector(s) A parallel to vector(s) B.
%   Apar = PROJECTION(A, B) is equivalent to Apar = PROJECTION(A, B, DIM),
%   where DIM is the first non-singleton dimension of A and B.
%
%   Apar = PROJECTION(A, B, DIM) returns the projection(s) of the vector(s)
%   contained in A on the axis (axes) along which the vector(s) in B lie. 
%   A and B are vectors (N-by-1 or 1-by-N) or arrays containing vectors
%   along dimension DIM. They must have the same size.
%
%   Example:
%   A 5-by-3-by-2 array may be considered to be a block array containing
%   ten 3-element vectors along dimension 2. In this case, its size is so
%   indicated:  5-by-(3)-by-2 or 5x(3)x2. If A and B are 5x(3)x2 arrays,
%   Apar = PROJECTION(A, B, 2) is an array of the same size. 
%
%   See also REJECTION.

% $ Version: 1.1 $
% CODE      by:                 Paolo de Leva (IUSM, Rome, IT) 2005 Oct 16
%           optimized by:       Code author                    2006 Mar 29
% COMMENTS  by:                 Code author                    2006 Mar 29
% -------------------------------------------------------------------------

% Setting DIM if not supplied.
if nargin == 2
   firstNS = find(size(a)>1, 1, 'first'); % First non-singleton dimension
                                          % (empty matrix if A is a scalar)
   dim = max([firstNS, 1]);               % DIM = 1 if A is a scalar
end

unitB = unit(b, dim);
scalarApar = dot(a, unitB, dim);
Apar = multiprod(unitB, scalarApar, dim);