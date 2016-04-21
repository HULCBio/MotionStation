## Copyright (C) 2010, 2011   Lukas F. Reichlin
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
## @deftypefn {Function File} {@var{q} =} quaternion (@var{w})
## @deftypefnx {Function File} {@var{q} =} quaternion (@var{x}, @var{y}, @var{z})
## @deftypefnx {Function File} {@var{q} =} quaternion (@var{w}, @var{x}, @var{y}, @var{z})
## Constructor for quaternions - create or convert to quaternion.
##
## @example
## q = w + x*i + y*j + z*k
## @end example
##
## Arguments @var{w}, @var{x}, @var{y} and @var{z} can be scalars,
## matrices or n-dimensional arrays, but they must be real-valued
## and of equal size.
## If scalar part @var{w} or components @var{x}, @var{y} and @var{z}
## of the vector part are not specified, zero matrices of appropriate
## size are assumed.
##
## @strong{Example}
## @example
## @group
## octave:1> q = quaternion (2)
## q = 2 + 0i + 0j + 0k
## 
## octave:2> q = quaternion (3, 4, 5)
## q = 0 + 3i + 4j + 5k
## 
## octave:3> q = quaternion (2, 3, 4, 5)
## q = 2 + 3i + 4j + 5k
## @end group
## @end example
## @example
## @group
## octave:4> w = [2, 6, 10; 14, 18, 22];
## octave:5> x = [3, 7, 11; 15, 19, 23];
## octave:6> y = [4, 8, 12; 16, 20, 24];
## octave:7> z = [5, 9, 13; 17, 21, 25];
## octave:8> q = quaternion (w, x, y, z)
## q.w =
##     2    6   10
##    14   18   22
## 
## q.x =
##     3    7   11
##    15   19   23
## 
## q.y =
##     4    8   12
##    16   20   24
## 
## q.z =
##     5    9   13
##    17   21   25
## 
## octave:9> 
## @end group
## @end example
##
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.2

function q = quaternion (a, b, c, d)

  switch (nargin)
    case 1
      if (isa (a, "quaternion"))        # quaternion (q)
        q = a;
        return;
      elseif (is_real_array (a))        # quaternion (w)
        b = c = d = zeros (size (a));
      else
        print_usage ();
      endif
    case 3                              # quaternion (x, y, z)
      d = c;
      c = b;
      b = a;
      a = zeros (size (a));
    case 4                              # quaternion (w, x, y, z)
      ## nothing to do here, just prevent case "otherwise"
    otherwise
      print_usage ();
  endswitch

  if (! is_real_array (a, b, c, d))
    error ("quaternion: arguments must be real matrices");
  endif

  if (! size_equal (a, b, c, d));
    error ("quaternion: arguments must have identical sizes");
  endif

  q = class (struct ("w", a, "x", b, "y", c, "z", d), "quaternion");

endfunction
