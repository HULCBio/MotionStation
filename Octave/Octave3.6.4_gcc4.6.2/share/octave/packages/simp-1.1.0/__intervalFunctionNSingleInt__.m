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

## __intervalFunctionNSingleInt__ given a function and a set of intervals does the following ....f(f(f(1st arg, 2nd arg), 3rd arg), 4th arg)...

## Author: simone pernice
## Created: 2008-08-18

function ret = __intervalFunctionNSingleInt__ (varargin) 
  if (columns(varargin) < 3)
    error ("At list three arguments are required: the function plus two arguments");
  endif
  ret = feval (varargin{1}, varargin{2}, varargin{3});
  for i = 4:length(varargin)
    ret = feval(varargin{1}, ret, varargin{i});
  endfor  
endfunction
