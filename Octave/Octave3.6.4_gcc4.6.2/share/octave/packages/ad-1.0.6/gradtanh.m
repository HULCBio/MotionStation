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
## @deftypefn {Mapping Function} {} gradtanh (@var{x})
## overloads built-in mapper @code{tanh} for a gradient @var{x}
## @end deftypefn
## @seealso{tanh}

## PKG_ADD: dispatch ("tanh", "gradtanh", "gradient")

function retval = gradtanh (g)

  if nargin != 1
    usage ("gradtanh (g)");
  endif

  g.x = tanh (g.x);
  tmp = 1 - (g.x(:) .^ 2).';
  r = size (g.dx, 1);
  g.dx = g.dx .* tmp(ones (1, r), :);
  retval = g;
endfunction
