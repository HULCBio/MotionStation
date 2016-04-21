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
## @deftypefn {Loadable Function} {} diag (@var{v}, @var{k})
## Return a diagonal matrix with Galois vector @var{v} on diagonal @var{k}.
## The second argument is optional.  If it is positive, the vector is placed on
## the @var{k}-th super-diagonal.  If it is negative, it is placed on the
## @var{-k}-th sub-diagonal.  The default value of @var{k} is 0, and the
## vector is placed on the main diagonal.  For example,
## 
## @example
## diag (gf([1, 2, 3],2), 1)
## ans =
## GF(2^2) array. Primitive Polynomial = D^2+D+1 (decimal 7)
## 
## Array elements = 
## 
##   0  1  0  0
##   0  0  2  0
##   0  0  0  3
##   0  0  0  0
## @end example
## @end deftypefn

function varargout = diag (varargin)
  varargout = cell (1, max(1, nargout));
  [varargout{:}] = gdiag (varargin{:});
endfunction

