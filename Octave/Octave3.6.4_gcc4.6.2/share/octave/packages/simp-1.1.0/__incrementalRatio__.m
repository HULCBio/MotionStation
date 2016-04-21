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

## __incrementalRatio__ compute the incremental ratio of f(x) in x0 with dx2/2 delta

## Author: simone pernice
## Created: 2008-08-18

function ret = __incrementalRatio__ (f, x0, dx2)
  ret = (feval(f, x0+dx2)-feval(f, x0-dx2))/2/dx2;
endfunction
