## Copyright (C) 2012 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## 
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
## 
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
## 
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{h} = } plot ()
## Plots and SVG object.
##
## @end deftypefn

function h = plot(obj, varargin)

  # Get path ids
  ids = fieldnames(obj.Path);
  npath = numel(ids);

  t = linspace (0, 1, 64);
  
  args={};
  if !isempty (varargin)
    args = varargin;
  end
  for i = 1:npath
    x = []; y = [];
    data = obj.Path.(ids(i)).data;

    for j = 1:numel(data)
      x = cat (2, x, polyval (data{j}(1,:),t));
      y = cat (2, y, polyval (data{j}(2,:),t));
    end

    h = plot(x,y,args{:});
    if i == 1
      hold on
    end
 end
 hold off
 axis tight
 axis equal
endfunction

