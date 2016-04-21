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

## monotonicFunctionInt applies the given monotonic function f the required interval (if f is not monotonic the result may be wrong)

## Author: simone pernice
## Created: 2008-08-18

function int = monotonicFunctionInt (f, interval) 
  if (nargin() != 2)
     error ("Wrong number of argument passed to the function.");
  endif
  
  i = __checkInt__ (interval(1,:));
  int = [__checkInt__([feval(f, i(1)), feval(f, i(2))])];
  r = 2;
  while r <= rows (interval)
    i = __checkInt__ (interval(r,:));
    int = [int; __checkInt__([feval(f, i(1)), feval(f, i(2))])];
    ++ r;
  endwhile  
endfunction
