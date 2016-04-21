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
## @deftypefn {Mapping Function} {} gradsinh (@var{x})
## overloads built-in mapper @code{sinh} for a gradient @var{x}
## @end deftypefn
## @seealso{sinh}

## PKG_ADD: dispatch ("sinh", "gradsinh", "gradient")

function retval = gradsinh (g)

  if nargin != 1
    usage ("gradsinh (g)");
  endif

  x = g.x(:).';
  r = size (g.dx, 1);
  g.x = sinh (g.x);
  g.dx = g.dx .* cosh (x)(ones (1, r), :);
  retval = g;
endfunction
