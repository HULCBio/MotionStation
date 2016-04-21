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
## @deftypefn {Function File} {@var{nshape} = } shapetransform (@var{shape}, @var{T})
## Applies transformation to a shape defined by piecewise smooth polynomials.
##
## @var{shape} is a cell where each elements is a 2-by-(poly_degree+1) matrix
## containing a pair of polynomials.
##
## Format of @var{T} can be one of :
## @example
## @group
##  [c] , [a b] , [a b c] or [a b c]
##  [f]   [d e]   [d e f]    [d e f]
##                           [0 0 1]
## @end group
## @end example
##
## @seealso{shape2polygon, shapeplot}
## @end deftypefn

function nshape = shapetransform (shape, Trans)

  if size(Trans,1) < 2
    error("geometry:shapetransform:InvalidArgument", ...
                       "Transformation can be 2x1, 2x2, 2x3 or 3x3. See help.");
  end

  if ~iscell(shape)
    error("geometry:shapetransform:InvalidArgument", "Shape must be a cell of 2D polynomials.");
  end

  A =[];
  v = [];

  switch size(Trans,2)
    case 1
    # Just translation
      v = Trans;

    case 2
    # Just linear transformation
      A = Trans;

    case 3
    # Affine transform
      A = Trans(1:2,1:2);
      v = Trans(1:2,3);
  end

  nshape = cellfun (@(x)polytransform (x,A,v), shape, 'UniformOutput',false);

endfunction

function np = polytransform(p,A,v)

  np = p;
  if ~isempty (A)
    np = A*np;
  end
  if ~isempty (v)
    np(:,end) = np(:,end) + v;
  end

endfunction

%!demo
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
%!
%! A = shapearea (shape);
%! T = eye(2)/sqrt(A);
%! shape = shapetransform (shape,T);
%! T = shapecentroid (shape)(:);
%! shape = shapetransform (shape,-T + [2; 0]);
%!
%! close
%! shapeplot (shape,'-r','linewidth',2);
%! hold on
%! for i = 1:9
%!   T = createRotation (i*pi/5)(1:2,1:2)/exp(0.3*i);
%!   shapeplot (shapetransform(shape, T), 'color',rand(1,3),'linewidth',2);
%! end
%! hold off
%! axis tight
%! axis square
