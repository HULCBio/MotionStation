## Copyright (C) 2010, 2012   Lukas F. Reichlin
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
## Matrix multiplication of two quaternions. Used by Octave for "q1 * q2".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.2

function q = mtimes (a, b)

  if (nargin != 2)
    error ("quaternion: mtimes: this is a binary operator");
  endif

  a = quaternion (a);
  b = quaternion (b);

  w = a.w*b.w - a.x*b.x - a.y*b.y - a.z*b.z;
  x = a.y*b.z - a.z*b.y + a.w*b.x + a.x*b.w;
  y = a.z*b.x - a.x*b.z + a.w*b.y + a.y*b.w;
  z = a.x*b.y - a.y*b.x + a.w*b.z + a.z*b.w;

  q = quaternion (w, x, y, z);

endfunction
