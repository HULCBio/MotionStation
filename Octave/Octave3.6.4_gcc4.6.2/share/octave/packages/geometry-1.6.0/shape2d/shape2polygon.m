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
## @deftypefn {Function File} {@var{polygon} = } shape2polygon (@var{shape})
## @deftypefnx {Function File} {@var{polygon} = } shape2polygon (@dots{},@var{property},@var{value},@dots{})
## Transforms a 2D shape described by piecewise smooth polynomials into a polygon.
##
## @var{shape} is a n-by-1 cell where each element is a pair of polynomials
## compatible with polyval.
## @var{polygon} is a k-by-2 matrix, where each row represents a vertex.
## The property-value pairs are passed to @code{curve2polyline}.
##
## @seealso{polygon2shape, curve2poyline}
## @end deftypefn

function polygon = shape2polygon (shape, varargin)

  polygon = cell2mat ( ...
             cellfun (@(x) curve2polyline(x,varargin{:}), shape,'UniformOutput',false) );
  polygon = simplifypolygon(polygon);

  if size (polygon, 1) == 1
    polygon(2,1) = polyval (shape{1}(1,:), 1);
    polygon(2,2) = polyval (shape{1}(2,:), 1);
  end

endfunction

%!demo
%! shape = {[-93.172   606.368  -476.054   291.429; ...
%!           -431.196   637.253    11.085   163.791]; ...
%!          [-75.3626  -253.2337   457.1678   328.5714; ...
%!            438.7659  -653.6278    -7.9953   380.9336]; ...
%!          [-89.5841   344.9716  -275.3876   457.1429; ...
%!           -170.3613   237.8858     1.0469   158.0765];...
%!          [32.900  -298.704   145.804   437.143; ...
%!          -243.903   369.597   -34.265   226.648]; ...
%!          [-99.081   409.127  -352.903   317.143; ...
%!            55.289  -114.223   -26.781   318.076]; ...
%!          [-342.231   191.266   168.108   274.286; ...
%!            58.870   -38.083   -89.358   232.362]};
%!
%! # Estimate a good tolerance
%! n  = cell2mat(cellfun(@(x)curveval(x,rand(1,10)), shape, 'uniformoutput',false));
%! dr = (max(n(:,1))-min(n(:,1)))*(max(n(:,2))-min(n(:,2)))*40;
%! p  = shape2polygon (shape,'tol',dr);
%!
%! figure(1)
%! shapeplot(shape,'-b');
%! hold on;
%! drawPolygon (p,'-or');
%! hold off
