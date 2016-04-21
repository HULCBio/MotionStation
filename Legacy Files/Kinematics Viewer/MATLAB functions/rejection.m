function Anorm = rejection(a, b, varargin)
%REJECTION  Vector component of vector(s) A normal to vector(s) B.
%   Anorm = REJECTION(A, B) is equivalent to Anorm = REJECTION(A, B, DIM),
%   where DIM is the first non-singleton dimension of A and B.
%
%   Anorm = REJECTION(A, B, DIM) returns the rejection(s) of the vector(s)
%   contained in A from the axis (axes) along which the vector(s) in B lie. 
%   The rejection of a vector from an axis is its projection on a plane
%   normal to that axis. A and B are vectors (N-by-1 or 1-by-N) or arrays
%   containing vectors along dimension DIM. They must have the same size.
%
%   Example:
%   A 5-by-3-by-2 array may be considered to be a block array containing
%   ten 3-element vectors along dimension 2. In this case, its size is so
%   indicated:  5-by-(3)-by-2 or 5x(3)x2. If A and B are 5x(3)x2 arrays,
%   Anorm = REJECTION(A, B, 2) is an array of the same size.
%
%   See also PROJECTION.

% $ Version: 1.1 $
% CODE      by:                 Paolo de Leva (IUSM, Rome, IT) 2005 Oct 16
% COMMENTS  by:                 Code author                    2006 Mar 29
% -------------------------------------------------------------------------

Apar = projection(a, b, varargin{:});
Anorm = a - Apar;