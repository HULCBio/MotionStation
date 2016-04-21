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

## __checkMonotonicity__ of a given function in a given interval

## Author: simone pernice
## Created: 2008-08-18

function [ret, inter] = __checkMonotonicity__ (f, interval, pointsToCheck)
  if (pointsToCheck < 3) 
    error ("At least 3 points are required for monotonicity test");
  endif  
  interval = __checkInt__ (interval);
  x = linspace (interval(1), interval (2), pointsToCheck);
  y = feval (f, x);
  inter = [min(y), max(y)];
  
  ret = 0;
  s = sign(y(2)-y(1));
  for i = 3:pointsToCheck
    if sign(y(i)-y(i-1)) ~= s
      ret = 0 ;
      return;
    endif
  endfor
  ret = 1;
endfunction
