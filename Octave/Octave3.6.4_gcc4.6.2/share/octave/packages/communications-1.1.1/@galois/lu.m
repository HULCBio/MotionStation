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
## @deftypefn {Loadable Function} {[@var{l}, @var{u}, @var{p}] =} lu (@var{a})
## @cindex LU decomposition of Galois matrix
## Compute the LU decomposition of @var{a} in a Galois Field. The result is
## returned in a permuted form, according to the optional return value
## @var{p}.  For example, given the matrix
## @code{a = gf([1, 2; 3, 4],3)},
## 
## @example
## [l, u, p] = lu (a)
## @end example
## 
## @noindent
## returns
## 
## @example
## l =
## GF(2^3) array. Primitive Polynomial = D^3+D+1 (decimal 11)
## 
## Array elements = 
## 
##   1  0
##   6  1
## 
## u =
## GF(2^3) array. Primitive Polynomial = D^3+D+1 (decimal 11)
## 
## Array elements = 
## 
##   3  4
##   0  7
## 
## p =
## 
##   0  1
##   1  0
## @end example
## 
## Such that @code{@var{p} * @var{a} = @var{l} * @var{u}}. If the argument
## @var{p} is not included then the permutations are applied to @var{l}
## so that @code{@var{a} = @var{l} * @var{u}}. @var{l} is then a pseudo-
## lower triangular matrix. The matrix @var{a} can be rectangular.
## @end deftypefn

function varargout = lu (varargin)
  varargout = cell (1, max(1, nargout));
  [varargout{:}] = glu (varargin{:});
endfunction
