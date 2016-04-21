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
## @deftypefn {Function File} {} gradfind (@var{x})
## overloads built-in function @code{find} for a gradient @var{x}
## @end deftypefn
## @seealso{find}

## PKG_ADD: dispatch ("find", "gradfind", "gradient")

function [x, y, z] = gradfind (g)

  if nargin != 1
    usage ("gradfind (g)");
  endif

  if (nargout < 2)
    x = find (g.x);
  elseif (nargout == 2)
    [x, y] = find (g.x);
  else
    [x, y, z] = find (g.x);
  endif
endfunction
