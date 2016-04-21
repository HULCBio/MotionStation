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

## __checkInt__ checks if the given interval is proper (trying to fix it if it is given by a single point x0 becomes [x0, x0] or if it is inverted [max, min] becomes [min, max])

## Author: simone pernice
## Created: 2008-08-18

function ret = __checkInt__ (interval)
if rows (interval) > 1 
  error ("Interval not proper");
  return;
endif
col = columns (interval);
if col > 2
  error ("Interval not proper");
  return;
endif
if col == 1
  interval = [interval, interval];
endif
if interval(1)>interval(2)
  ret = [interval(2), interval(1)];
else
  ret = interval;
endif
endfunction
