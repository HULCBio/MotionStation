## Copyright (C) 2004-2011 David Legland <david.legland@grignon.inra.fr>
## Copyright (C) 2004-2011 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas)
## Copyright (C) 2012 Adapted to Octave by Juan Pablo Carbajal <carbajal@ifi.uzh.ch>
## All rights reserved.
## 
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
## 
##     1 Redistributions of source code must retain the above copyright notice,
##       this list of conditions and the following disclaimer.
##     2 Redistributions in binary form must reproduce the above copyright
##       notice, this list of conditions and the following disclaimer in the
##       documentation and/or other materials provided with the distribution.
## 
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS''
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
## ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
## DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
## SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
## CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
## OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

## -*- texinfo -*-
## @deftypefn {Function File} {@var{pp} =} cbezier2poly (@var{points})
## @deftypefnx {Function File} {[@var{x} @var{y}] =} cbezier2poly (@var{points},@var{t})
## Returns the polynomial representation of the cubic Bezier defined by the control points @var{points}.
##
## With only one input argument, calculates the polynomial @var{pp} of the cubic
## Bezier curve defined by the 4 control points stored in @var{points}. The first
## point is the inital point of the curve. The segment joining the first point
## with the second point (first center) defines the tangent of the curve at the initial point.
## The segment that joints the third point (second center) with the fourth defines the tanget at
## the end-point of the curve, which is defined in the fourth point.
## @var{points} is either a 4-by-2 array (vertical concatenation of point
## coordinates), or a 1-by-8 array (horizotnal concatenation of point
## coordinates). @var{pp} is a 2-by-3 array, 1st row is the polynomial for the
## x-coordinate and the 2nd row for the y-coordinate. Each row can be evaluated
## with @code{polyval}. The polynomial @var{pp}(t) is defined for t in [0,1].
##
## When called with a second input argument @var{t}, it returns the coordinates
## @var{x} and @var{y} corresponding to the polynomial evaluated at @var{t} in
## [0,1].
##
## @seealso{drawBezierCurve, polyval}
## @end deftypefn

function varargout = cbezier2poly (points, ti=[])


  # rename points
  if size(points, 2)==2
      # case of points given as a 4-by-2 array
      p1 = points(1,:);
      c1 = points(2,:);
      c2 = points(3,:);
      p2 = points(4,:);
  elseif size(points,2) == 8
      # case of points given as a 1-by-8 array, [X1 Y1 CX1 CX2..]
      p1 = points(1:2);
      c1 = points(3:4);
      c2 = points(5:6);
      p2 = points(7:8);
  else
    print_usage ;
  end

  # compute coefficients of Bezier Polynomial
  pp = zeros(2,4);

  pp(:,4) = [p1(1); ...
             p1(2)];
  pp(:,3) = [3 * c1(1) - 3 * p1(1); ...
             3 * c1(2) - 3 * p1(2)];
  pp(:,2) = [3 * p1(1) - 6 * c1(1) + 3 * c2(1); ...
             3 * p1(2) - 6 * c1(2) + 3 * c2(2)];
  pp(:,1) = [p2(1) - 3 * c2(1) + 3 * c1(1) - p1(1); ...
             p2(2) - 3 * c2(2) + 3 * c1(2) - p1(2)];

  if isempty (ti)
    varargout{1} = pp;
  else
    varargout{1} = polyval (pp(1,:), ti);
    varargout{2} = polyval (pp(2,:), ti);
  end

endfunction

%!demo
%! points = [45.714286 483.79075; ...
%!           241.65656 110.40445; ...
%!           80.185847 741.77381; ...
%!           537.14286 480.93361];
%!
%! pp = cbezier2poly(points);
%! t = linspace(0,1,64);
%! x = polyval(pp(1,:),t);
%! y = polyval(pp(2,:),t);
%! plot (x,y,'b-',points([1 4],1),points([1 4],2),'s',...
%!       points([2 3],1),points([2 3],2),'o');
%! line(points([2 1],1),points([2 1],2),'color','r');
%! line(points([3 4],1),points([3 4],2),'color','r');

%!demo
%! points = [0 0; ...
%!           1 1; ...
%!           1 1; ...
%!           2 0];
%!
%! t = linspace(0,1,64);
%! [x y] = cbezier2poly(points,t);
%! plot (x,y,'b-',points([1 4],1),points([1 4],2),'s',...
%!       points([2 3],1),points([2 3],2),'o');
%! line(points([2 1],1),points([2 1],2),'color','r');
%! line(points([3 4],1),points([3 4],2),'color','r');

%!test
%! points = [0 0; ...
%!           1 1; ...
%!           1 1; ...
%!           2 0];
%! t = linspace(0,1,64);
%!
%! [x y] = cbezier2poly(points,t);
%! pp = cbezier2poly(points);
%! x2 = polyval(pp(1,:),t);
%! y2 = polyval(pp(2,:),t);
%! assert(x,x2);
%! assert(y,y2);

%!test
%! points = [0 0; ...
%!           1 1; ...
%!           1 1; ...
%!           2 0];
%! t = linspace(0,1,64);
%!
%! p = reshape(points,1,8);
%! [x y] = cbezier2poly(p,t);
%! pp = cbezier2poly(p);
%! x2 = polyval(pp(1,:),t);
%! y2 = polyval(pp(2,:),t);
%! assert(x,x2);
%! assert(y,y2);
