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

## findRootInt compute the incremental ration of f(x) in x0 with dx2/2 delta

## Author: simone pernice
## Created: 2008-08-18

function x1 = findRootInt (f, x0)
  if (nargin() != 2)
     error ("Wrong number of argument passed to the function.");
  endif
  
  #x1 = subInt (x0, divInt (monotonicFunctionInt('f', x0), monotonicFunctionInt(@(x) __incrementalRatio__('f', x, intToTol(x0)/20), x0)));
  #x1 = __intersectSingleInt__ (x1, x0);
  x1 = subInt (intToVal(x0), divInt (feval('f', intToVal(x0)), monotonicFunctionInt(@(x) __incrementalRatio__('f', x, intToTol(x0)/20), x0)));
endfunction
