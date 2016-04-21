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

## functionInt applies the given function f the required interval, it checks for monotonicitic. The user may set the minimum number of point to check on each interval

## Author: simone pernice
## Created: 2008-08-18

function int = functionInt (f, interval, minPoints = 10) 
  if (nargin() != 2 && nargin() != 3)
     error ("Wrong number of argument passed to the function.");
  endif
  
  if (rows(interval) == 0) 
    error ("The set of interval is empty");
  endif
  
  n = 100 / rows(inteval);
  if (n<minPoints) 
    n = minPoints; 
    if (n < 3)
      n = 3;
    endif    
  endif
  
  r=1;
  mono = 1;
  [ret, int] = __checkMonotonicity__ (f, interval(r, :), n);  
  mono = mono && ret;
  while r <= rows (interval)
    ++r;
    [ret, int1] = __checkMonotonicity__ (f, interval(r, :), n);  
    int = [int; int1];
    mono = mono && ret;
  endwhile
  
  if (~ mono)
    warning ("Warning the given function does not seem monotonic, the solution may be not accurate");
  endif
endfunction
