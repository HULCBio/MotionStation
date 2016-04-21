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

## intFormInt create an interval from a string or vector of strings in engineear format

## Author: simone pernice
## Created: 2008-12-31

function ret = intFormInt (interval)
  if (nargin() != 1)
     error ("Wrong number of argument passed to the function.");
  endif
		
  ret = __intervalFunctionMultiInt__('__intSingleFormInt__', interval);

endfunction
