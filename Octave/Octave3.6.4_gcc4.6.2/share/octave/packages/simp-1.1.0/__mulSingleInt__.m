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

## __mulSingleInt__ multiplies two intervals returning int1 * int2

## Author: simone pernice
## Created: 2008-08-18

function ret = __mulSingleInt__ (int1, int2)
  int1 = __checkInt__ (int1);
  int2 = __checkInt__ (int2);
  if (int1(1) >= 0 && int2(1) >= 0)
    ret = int1 .* int2;
  elseif (int1(2) < 0 && int2(2) < 0)
    ret = __checkInt__ (int1 .* int2);
  else
    mul = int1' * int2;
    ret = [min(min(mul)), max(max(mul))];  
  endif  
endfunction
