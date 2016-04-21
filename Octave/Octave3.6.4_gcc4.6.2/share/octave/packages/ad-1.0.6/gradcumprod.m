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
## @deftypefn {Function File} {@var{y} =} gradcumprod (@var{x})
## @deftypefnx {Function File} {@var{y} =} gradcumprod (@var{x}, @var{dim})
## overloads built-in function @code{cumprod} for a gradient @var{x}
## @end deftypefn
## @seealso{cumprod}

## PKG_ADD: dispatch ("cumprod", "gradcumprod", "gradient")

function retval = gradcumprod (g, dim)
  s = size (g.x);
  
  if nargin < 2 || dim == 0
    n = prod (s);
    if max (s) == n
      t = cumprod (g.x);
      g.dx = g.dx * triu ( ...
	    t(:).'(ones (1, n), :) ./ g.x(:)(:, ones (1, n)));
      g.x = t;
      retval = g;
      return
    else
      dim = 1;
    endif
  endif

  if size (g, dim) > 1
    d = size (g.dx, 1);
    n = s(dim);
    v = cumprod (g.x, dim);
    w = g.dx;
    p = prod (s(1 : dim -1));
    q = p * n;
      
    u = 0 : n-1; 
    if dim > 1
      u = u * p;
    endif
  
    for l = 0 : prod (s(dim +1 : end)) -1
      for k = 1 : p
        ix = k + l*q + u;
        w(:, ix) = g.dx(:, ix) * triu ( ...
          v(ix)(:).'(ones (1, n), :) ./ g.x(ix)(:)(:, ones (1, n)));
      endfor
    endfor
    g.x = v;
    g.dx = w;
  endif
  retval = g;
endfunction
