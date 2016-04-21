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

## __engSingleFormInt__ print an interval in engineear format

## Author: simone pernice
## Created: 2008-08-18

function ret = __engSingleFormInt__ (interval)
  tol = intToTol100 (interval);
  val = intToVal (interval);
  coeff = 0;
  while abs(val) < 1 && coeff > -8
    val *= 1000;
    coeff -= 1;
  endwhile
  while abs(val) >= 1000 && coeff < 8
    val /= 1000;
    coeff += 1;
  endwhile
  units = "yzafpnum KMGTPEZY";
  ret = sprintf ("%g%c+-%g%%", val, units(coeff+9), tol);
endfunction
