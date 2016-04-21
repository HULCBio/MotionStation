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
## Display routine for quaternions.  Used by Octave internally.

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.2

function display (q)

  name = inputname(1);
  s = size (q);
  
  if (length (s) == 2 && all (s == 1))  # scalar quaternion
    w = num2str (q.w, 4);
    x = __num2str__ (q.x);
    y = __num2str__ (q.y);
    z = __num2str__ (q.z);
    disp ([name, " = ", w, x, "i" y, "j", z, "k"]);
    disp ("");
  else                                  # non-scalar quaternion
    disp ([name, ".w ="]);
    disp (q.w);
    disp ("");
    disp ([name, ".x ="]);
    disp (q.x);
    disp ("");
    disp ([name, ".y ="]);
    disp (q.y);
    disp ("");
    disp ([name, ".z ="]);
    disp (q.z);
    disp ("");
  endif

endfunction


function str = __num2str__ (num)

  if (sign (num) == -1)
    str = " - ";
  else
    str = " + ";
  endif
  
  str = [str, num2str(abs (num), 4)];

endfunction
