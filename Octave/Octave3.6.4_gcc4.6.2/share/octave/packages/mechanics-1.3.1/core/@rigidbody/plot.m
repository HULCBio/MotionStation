## Copyright (c) 2011 Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{obj} =} plot ()
## Plots the rigid body.
##
## @end deftypefn

function h = plot(obj, varargin)

  ax = [];
  if !isempty (varargin)
    ax = varargin{1};
  end
  
  ## Center of mass
  c  = obj.CoM;
  ## Shape
  has_shape = !isinf (obj.InertiaMoment);
  if has_shape
    shapedata = obj.Shape.Data;
    if iscell (shapedata)
      shapedata = shape2polygon (shapedata);
    end

    # Rotate
    R = cos(obj.Angle)*eye(2) + sin(obj.Angle)*[0 1; -1 0];
    shapedata = shapedata * R;
    
    ## Baricenter
    b = c + obj.Shape.Offset * R;;

    # Translate
    shapedata = bsxfun(@plus, shapedata, b);
    xs = shapedata(:,1);
    ys = shapedata(:,2);
  end
  
  ## Plot
  if isempty (ax)
    cla
    if has_shape
      h(3,1) = patch(xs,ys,'r','edgecolor','k');
      hold on
      h(2,1) = plot(b(1),b(2),'sk');
    end
    h(1,1) = plot(c(1),c(2),'ok','markerfacecolor','k');
    hold off
  else
    if has_shape
      h(3,1) = patch(xs,ys,'r','edgecolor','k');
      hold on
      h(2,1) = plot(ax,b(1),b(2),'sk');
    end
    h(1,1) = plot(ax,c(1),c(2),'ok','markerfacecolor','k');
    hold off
  end

  axis equal
  ## Velocity
  #TODO

endfunction
