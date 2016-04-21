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
## Vertical concatenation of quaternions.  Used by Octave for "[q1; q2]".

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: May 2010
## Version: 0.1

function q = vertcat (varargin)

  tmp = cellfun (@quaternion, varargin);  # uniformoutput = true !

  w = vertcat (tmp.w);
  x = vertcat (tmp.x);
  y = vertcat (tmp.y);
  z = vertcat (tmp.z);

  q = quaternion (w, x, y, z);

endfunction
