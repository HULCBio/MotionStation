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
## @deftypefn {Function File} { @var{cm} =} shapecentroid (@var{pp})
##  Centroid of a simple plane shape defined with piecewise smooth polynomials.
##
## The shape is defined with piecewise smooth polynomials. @var{pp} is a
## cell where each elements is a 2-by-(poly_degree+1) matrix containing a pair
## of polynomials.
## @code{px(i,:) = pp@{i@}(1,:)} and @code{py(i,:) = pp@{i@}(2,:)}.
##
## The edges of the shape should not self-intersect. This function does not check for the
## sanity of the shape.
##
## @seealso{shapearea, shape2polygon}
## @end deftypefn

function cm = shapecentroid (shape)

  cm = sum( cell2mat ( cellfun (@CMint, shape, 'UniformOutput', false)), 1);
  A = shapearea(shape);
  cm = cm / A;

  [~,id] = lastwarn ('','');
  if strcmp (id ,'geom2d:shapearea:InvalidResult')
    lastwarn('Inverting centroid','geom2d:shapecentroid:InvalidResult');
    cm = -cm;
  end

endfunction

function dcm = CMint (x)

    px = x(1,:);
    py = x(2,:);
    Px = polyint (conv(conv (-px , py) , polyder (px)));
    Py = polyint (conv(conv (px , py) , polyder (py)));

    dcm = zeros (1,2);
    dcm(1) = diff(polyval(Px,[0 1]));
    dcm(2) = diff(polyval(Py,[0 1]));

endfunction

%!demo # non-convex bezier shape
%! boomerang = {[ 0 -2 1; ...
%!               -4  4 0]; ...
%!              [0.25 -1; ...
%!               0     0]; ...
%!              [ 0 1.5 -0.75; ...
%!               -3 3    0];
%!              [0.25 0.75; ...
%!               0 0]};
%! CoM = shapecentroid (boomerang)
%! Gcentroid = centroid(shape2polygon(boomerang))
%! figure(1); clf;
%! shapeplot(boomerang,'-o');
%! hold on
%! drawPoint(CoM,'xk;shape centroid;');
%! drawPoint(Gcentroid,'xr;point centroid;');
%! hold off
%! axis equal

%!demo
%! Lshape = {[0.00000   0.76635; -0.67579  -0.24067]; ...
%!             [0.77976   0.76635; 0.00000  -0.91646]; ...
%!             [0.00000   1.54611; 0.38614  -0.91646]; ...
%!             [-0.43813   1.54611; 0.00000  -0.53032]; ...
%!             [0.00000   1.10798; 0.28965  -0.53032]; ...
%!             [-0.34163   1.10798; 0.00000  -0.24067]};...
%! CoM = shapecentroid (Lshape)
%! Gcentroid = centroid (shape2polygon (Lshape))
%!
%! shapeplot(Lshape,'-o');
%! hold on
%! drawPoint(CoM,'xk;shape centroid;');
%! drawPoint(Gcentroid,'xr;point centroid;');
%! hold off
%! axis equal

%!test
%! square = {[1 -0.5; 0 -0.5]; [0 0.5; 1 -0.5]; [-1 0.5; 0 0.5]; [0 -0.5; -1 0.5]};
%! CoM = shapecentroid (square);
%! assert (CoM, [0 0], sqrt(eps));

%!test
%! square = {[1 -0.5; 0 -0.5]; [0 0.5; 1 -0.5]; [-1 0.5; 0 0.5]; [0 -0.5; -1 0.5]};
%! square_t = shapetransform (square,[1;1]);
%! CoM = shapecentroid (square_t);
%! assert (CoM, [1 1], sqrt(eps));

%!test
%! circle = {[1.715729  -6.715729    0   5; ...
%!            -1.715729  -1.568542   8.284271    0]; ...
%!            [1.715729   1.568542  -8.284271    0; ...
%!             1.715729  -6.715729    0   5]; ...
%!            [-1.715729   6.715729    0  -5; ...
%!             1.715729   1.568542  -8.284271    0]; ...
%!            [-1.715729  -1.568542   8.284271    0; ...
%!            -1.715729   6.715729    0  -5]};
%! CoM = shapecentroid (circle);
%! assert (CoM , [0 0], 5e-3);

%!shared shape
%! shape = {[-93.172   606.368  -476.054   291.429; ...
%!          -431.196   637.253    11.085   163.791]; ...
%!         [-75.3626  -253.2337   457.1678   328.5714; ...
%!           438.7659  -653.6278    -7.9953   380.9336]; ...
%!         [-89.5841   344.9716  -275.3876   457.1429; ...
%!          -170.3613   237.8858     1.0469   158.0765];...
%!         [32.900  -298.704   145.804   437.143; ...
%!         -243.903   369.597   -34.265   226.648]; ...
%!         [-99.081   409.127  -352.903   317.143; ...
%!           55.289  -114.223   -26.781   318.076]; ...
%!         [-342.231   191.266   168.108   274.286; ...
%!           58.870   -38.083   -89.358   232.362]};

%!test # x-Reflection
%! v = shapecentroid (shape)(:);
%! T = createLineReflection([0 0 1 0]);
%! nshape = shapetransform (shape, T);
%! vn = shapecentroid (nshape)(:);
%! assert(vn,T(1:2,1:2)*v);

%!test # Rotation
%! v = shapecentroid (shape)(:);
%! T = createRotation(v.',pi/2);
%! nshape = shapetransform (shape, T);
%! vn = shapecentroid (nshape)(:);
%! assert(vn,v,1e-2);

%!test # Translation
%! v = shapecentroid (shape)(:);
%! nshape = shapetransform (shape, -v);
%! vn = shapecentroid (nshape)(:);
%! assert(vn,[0; 0],1e-2);
