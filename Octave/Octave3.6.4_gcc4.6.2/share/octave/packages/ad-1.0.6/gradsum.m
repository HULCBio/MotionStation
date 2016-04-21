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
## @deftypefn {Function File} {@var{y} =} gradsum (@var{x})
## @deftypefnx {Function File} {@var{y} =} gradsum (@var{x}, @var{dim})
## overloads built-in function @code{sum} for a gradient @var{x}
## @end deftypefn
## @seealso{sum}

## PKG_ADD: dispatch ("sum", "gradsum", "gradient")

function retval = gradsum (g, dim)
  s = size (g.x);
  
  if nargin < 2 || dim == 0
    if max (s) == prod (s)
      g.x = sum (g.x);
      g.dx = sum (g.dx, 2);
      retval = g;
      return
    else
      dim = 1;
    endif
  endif

  if size (g, dim) > 1
    g.x = sum (g.x, dim);
    d = size (g.dx, 1);
    n = numel (g);
    
    if issparse (g.dx)
      w = sparse (d, n);
      p = prod (s(1 : dim -1));
      q = p * s(dim);
      u = 0 : s(dim) -1; 
      
      if dim > 1
        u = u * p;
      endif
      
      c = 1;
      for l = 0 : prod (s(dim +1 : end)) -1
        for k = 1 : p
          ix = k + l*q + u;
          w(:, c) = sum (g.dx(:, ix), 2);
          c = c + 1;
        endfor
      endfor
      g.dx = w;
    else
      g.dx = reshape (sum (reshape (g.dx, [d, s]), dim +1), [d, n]);
    endif
  endif
  retval = g;
endfunction
