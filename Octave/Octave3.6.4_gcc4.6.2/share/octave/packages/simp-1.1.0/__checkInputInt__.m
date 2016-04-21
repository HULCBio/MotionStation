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

## __checkInputInt__ checks the row consistency of a set of intervals expanding the single rows 

## Author: simone pernice
## Created: 2008-08-18

function int = __checkInputInt__ (varargin) 
  varargin = varargin {:};
  for i=1:length(varargin)
    if (len(i)=rows(varargin{i})) == 0
      error ("One set of intervals is empty");
    endif
  endfor
  m = max (len);
  
  for i=1:length(varargin)    
    if (len(i) ~= 1 && len(i) ~= m)
       error ("The set of intervals do not match");
    endif
  endfor     
  
  for i=1:length(varargin)
    if (len(i) == 1)
       int = varargin{i}(1,:);
       j = 1;
       while j < m
         varargin{i} = [varargin{i} ; int];
         ++j;
       endwhile       
    endif
  endfor   
      
  int = varargin;
endfunction
