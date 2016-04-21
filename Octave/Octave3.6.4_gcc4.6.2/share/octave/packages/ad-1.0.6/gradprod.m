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
## @deftypefn {Function File} {@var{y} =} gradprod (@var{x})
## @deftypefnx {Function File} {@var{y} =} gradprod (@var{x}, @var{dim})
## overloads built-in function @code{prod} for a gradient @var{x}
## @end deftypefn
## @seealso{prod}

## PKG_ADD: dispatch ("prod", "gradprod", "gradient")

function retval = gradprod (g, dim)
  s = size (g);
  
  if nargin < 2 || dim == 0
    if max (s) == prod (s)
      t = prod (g.x);
      g.dx = g.dx * (t ./ g.x(:));
      g.x = t;
      retval = g;
      return
    else
      dim = 1;
    endif
  endif
  
  if size (g, dim) > 1
    d = size (g.dx, 1);
    v = prod (g.x, dim);
    p = prod (s(1 : dim -1));
    q = p * s(dim);  
    u = 0 : s(dim) -1;
    
    if dim > 1
      u = u * p;
    endif
    if issparse (g.dx)
      w = sparse (d, numel (v));
    else
      w = zeros (d, numel (v));
    endif
    
    c = 1;
    for l = 0 : prod (s(dim +1 : end)) -1
      for k = 1 : p
        ix = k + l*q + u;
        w(:, c) = g.dx(:, ix) * (v(c) ./ g.x(ix))(:);
        c = c + 1;
      endfor
    endfor
    
    g.x = v;
    g.dx = w;
  endif
  retval = g;
endfunction
