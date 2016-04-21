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
## @deftypefn {Function File} {@var{y} =} gradcumsum (@var{x})
## @deftypefnx {Function File} {@var{y} =} gradcumsum (@var{x}, @var{dim})
## overloads built-in function @code{cumsum} for a gradient @var{x}
## @end deftypefn
## @seealso{cumsum}

## PKG_ADD: dispatch ("cumsum", "gradcumsum", "gradient")

function retval = gradcumsum (g, dim)
  s = size (g.x);
  
  if nargin < 2 || dim == 0
    if max (s) == prod (s)
      g.x = cumsum (g.x);
      g.dx = cumsum (g.dx, 2);
      retval = g;
      return
    else
      dim = 1;
    endif
  endif

  if size (g, dim) > 1
    g.x = cumsum (g.x, dim);
    d = size (g.dx, 1);
    
    if issparse (g.dx)
      p = prod (s(1 : dim -1));
      q = p * s(dim);
      u = 0 : s(dim) -1; 
      
      if dim > 1
        u = u * p;
      endif
      
      for l = 0 : prod (s(dim +1 : end)) -1
        for k = 1 : p
          ix = k + l*q + u;
          g.dx(:, ix) = cumsum (g.dx(:, ix), 2);
        endfor
      endfor
    else
      g.dx = reshape (cumsum ( ...
        reshape (g.dx, [d, s]), dim +1), [d, prod(s)]);
    endif
  endif
  retval = g;
endfunction
