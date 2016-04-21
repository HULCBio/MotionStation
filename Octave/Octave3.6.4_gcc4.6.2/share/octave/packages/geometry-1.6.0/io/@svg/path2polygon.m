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
## @deftypefn {Function File} @var{P} = path2polygon (@var{id})
## Converts the SVG path to an array of polygons.
##
## @end deftypefn

function P = path2polygon (obj,varargin)

    narg = numel(varargin);

    if narg == 1

     id = varargin{1};
     n = 32;

    elseif narg == 2

     id = varargin{1};
     n = varargin{2};

    else

      error("svg:path2polygon:InvalidArgument", "Wrong number of arguments.");

    end

    P = shape2polygon(getpath(obj, id));

endfunction

#{
    pd = obj.Path.(id).data;
    P = cellfun(@(x)convertpath(x,n),pd,'UniformOutput',false);
    P = cell2mat(P);

end

function p = convertpath(x,np)
  n = size(x,2);

  switch n
    case 2
      p = zeros(2,2);
    # Straight segment
      p(:,1) = polyval (x(1,:), [0; 1]);
      p(:,2) = polyval (x(2,:), [0; 1]);
    case 4
      p = zeros(np,2);
    # Cubic bezier
      t = linspace (0, 1, np).';
      p(:,1) = polyval (x(1,:),t);
      p(:,2) = polyval (x(2,:),t);
  end

end
#}
