## Copyright (C) 2008 simone pernice
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
## along with this program; if not, write to the Free Software
## Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

## __intersectSingleInt__ compute the intersection among two intervals

## Author: simone pernice
## Created: 2008-08-18

function ret = __intersectSingleInt__ (i1, i2)
  i1 = __checkInt__ (i1);
  i2 = __checkInt__ (i2);
  if (i1(1) > i2(2) || i1(2) < i2(2))
    ret = [0, 0];
    return;
  endif
  join = [i1, i2];
  ret = zeros (1, 2);
  ret (0) = min (join);
  ret (1) = max (join);
endfunction
