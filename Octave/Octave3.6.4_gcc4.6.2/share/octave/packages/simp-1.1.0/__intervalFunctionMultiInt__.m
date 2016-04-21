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

## __intervalFunctionMultiInt__ applies the given n-arg interval-function to the set of given intervals

## Author: simone pernice
## Created: 2008-08-18

function int = __intervalFunctionMultiInt__ (varargin) 
  f = varargin{1};
  varargin = __checkInputInt__ ({varargin{2:length(varargin)}});
  
  for i=1:rows(varargin{1})
    for j=1:length(varargin)
      if j==1
        arg= {(varargin{j})(i,:)};
      else
        arg={arg{:}, (varargin{j})(i,:)};
      endif      
    endfor
    sol = feval ({f, arg{:}}{:});
    if i == 1      
      int = sol;
    else
      int = [int ; sol ];
    endif
  endfor  
endfunction
