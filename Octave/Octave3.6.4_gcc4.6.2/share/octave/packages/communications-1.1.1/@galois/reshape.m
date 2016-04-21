## Copyright (C) 2011 David Bateman
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Loadable Function} {} reshape (@var{a}, @var{m}, @var{n})
## Return a matrix with @var{m} rows and @var{n} columns whose elements are
## taken from the Galois array @var{a}.  To decide how to order the elements,
## Octave pretends that the elements of a matrix are stored in column-major
## order (like Fortran arrays are stored).
## 
## For example,
## 
## @example
## reshape (gf([1, 2, 3, 4],3), 2, 2)
## ans =
## GF(2^3) array. Primitive Polynomial = D^3+D+1 (decimal 11)
## 
## Array elements = 
## 
##   1  3
##   2  4
## @end example
## 
## The @code{reshape} function is equivalent to
## 
## @example
## @group
## retval = gf(zeros (m, n), a.m, a.prim_poly);
## retval (:) = a;
## @end group
## @end example
## 
## @noindent
## but it is somewhat less cryptic to use @code{reshape} instead of the
## colon operator. Note that the total number of elements in the original
## matrix must match the total number of elements in the new matrix.
## @end deftypefn
## @seealso{`:'}

function varargout = reshape (varargin)
  varargout = cell (1, max(1, nargout));
  [varargout{:}] = greshape (varargin{:});
endfunction

