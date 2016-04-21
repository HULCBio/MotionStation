## Copyright (C) 2010   Lukas F. Reichlin
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
## @deftypefn {Function File} {} qj
## Create y-component of a quaternion's vector part.
##
## @example
## q = w + x*qi + y*qj + z*qk
## @end example
##
## @strong{Example}
## @example
## @group
## octave:1> q1 = quaternion (1, 2, 3, 4)
## q1 = 1 + 2i + 3j + 4k
## octave:2> q2 = 1 + 2*qi + 3*qj + 4*qk
## q2 = 1 + 2i + 3j + 4k
## octave:3> 
## @end group
## @end example
##
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1

function q = qj

  if (nargin != 0)
    print_usage ();
  endif

  q = quaternion (0, 0, 1, 0);

endfunction