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

## __sqrSingleInt__ returns the square of a given interval

## Author: simone pernice
## Created: 2008-08-18

function ret = __sqrSingleInt__ (interval)
  ret = __checkInt__ (interval .^ 2);
  if interval(1) < 0 && interval(2) > 0
    ret = [0, max(ret)];
  endif  
endfunction
