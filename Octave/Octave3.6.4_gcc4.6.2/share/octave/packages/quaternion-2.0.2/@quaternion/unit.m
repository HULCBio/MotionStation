## Copyright (C) 2011   Lukas F. Reichlin
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{qn} =} unit (@var{q})
## Normalize quaternion to length 1 (unit quaternion).
##
## @example
## q = w + x*i + y*j + z*k
## unit (q) = q ./ sqrt (w.^2 + x.^2 + y.^2 + z.^2)
## @end example
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.1

function q = unit (a)

  if (nargin != 1)
    print_usage ();
  endif

  q = a ./ abs (a);

endfunction
