## Copyright (C) 2006, 2007 Thomas Kasper, <thomaskasper@gmx.net>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {[@var{y}, @var{J}] =} D (@var{F}, @var{x}, @var{varargin})
## Evaluate @var{F} for a given input @var{x} and compute the jacobian, such that
## @example
##
##            d
## @var{J}(i,j) = ----- @var{y}(i) where @var{y} = @var{F}(@var{x}, @var{varargin}@{:@})
##          d@var{x}(j)
## 
## @end example
##
## If @var{x} is complex, the above holds for the directional derivatives 
## along the real axis
##
## Derivatives are computed analytically via Automatic Differentiation
## @end deftypefn
## @seealso{use_sparse_jacobians}

function [y, J] = D (F, x, varargin)
  if nargin > 1
    f = F (gradinit (x), varargin{:});
    if isgradient (f)
      y = f.x;
      J = f.J;
    else
      warning ("AD: function not differentiable or not dependent on input")
      y = f;
      m = numel (y);
      n = numel (x);
      if use_sparse_jacobians () != 0
        J = sparse (m, n);
      else
        J = zeros (m, n);
      endif
    endif
  else usage ("[y, J] = D (F, x, varargin)");
  endif
endfunction
