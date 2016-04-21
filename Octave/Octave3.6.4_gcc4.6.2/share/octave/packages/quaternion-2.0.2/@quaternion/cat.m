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
## @deftypefn {Function File} {@var{q} =} cat (@var{dim}, @var{q1}, @var{q2}, @dots{})
## Concatenation of quaternions along dimension @var{dim}.
## @end deftypefn

## Author: Lukas Reichlin <lukas.reichlin@gmail.com>
## Created: November 2011
## Version: 0.1

function q = cat (dim, varargin)

  tmp = cellfun (@quaternion, varargin);  # uniformoutput = true !

  w = cat (dim, tmp.w);
  x = cat (dim, tmp.x);
  y = cat (dim, tmp.y);
  z = cat (dim, tmp.z);

  q = quaternion (w, x, y, z);

endfunction
