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

## valtol100ToInt return an interval given a value with its tolerance expressed in percentage (optionally also a negative tolerance). I.E. 10+-5% is tolToInt (10, 5); 10+20%-5% is tolToInt (10,20,-5).

## Author: simone pernice
## Created: 2008-08-18

function interval = valtol100ToInt (val, ptol, mtol = - ptol)
  if (nargin() != 2 && nargin() != 3) 
	  error("Wrong number of argument passed to the function");
  endif
  interval = [val, val];
  interval(1) += val * mtol / 100;
  interval(2) += val * ptol / 100;
  interval = __checkInt__ (interval);
endfunction
