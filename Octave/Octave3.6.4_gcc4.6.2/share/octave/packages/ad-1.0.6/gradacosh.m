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
## @deftypefn {Mapping Function} {} gradacosh (@var{x})
## overloads built-in mapper @code{acosh} for a gradient @var{x}
## @end deftypefn
## @seealso{acosh}

## PKG_ADD: dispatch ("acosh", "gradacosh", "gradient")
function retval = gradacosh (g)

  if nargin != 1
    usage ("gradacosh (g)");
  endif

  tmp = (1 ./ sqrt ((g.x(:) .^ 2) - 1)).';
  r = size (g.dx, 1);
  g.x = acosh (g.x);
  g.dx = g.dx .* tmp(ones (1, r), :);
  retval = g;
endfunction
