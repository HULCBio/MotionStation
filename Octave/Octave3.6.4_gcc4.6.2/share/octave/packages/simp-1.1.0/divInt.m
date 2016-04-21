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

## divSingleInt divides two set of intervals returning int1 / int2

## Author: simone pernice
## Created: 2008-08-18

function ret = divInt (varargin)
  if (nargin() < 2)
     error ("Wrong number of argument passed to the function.");
  endif
  varargin = (__checkInputInt__ (varargin));

  ret = __intervalFunctionNSingleInt__ ('__div1Int__', varargin{:});  
endfunction


