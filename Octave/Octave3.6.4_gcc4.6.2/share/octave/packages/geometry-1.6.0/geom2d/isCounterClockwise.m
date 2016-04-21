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
## @deftypefn {Function File} {@var{ccw} = } isCounterClockwise (@var{p1}, @var{p2}, @var{p3})
## @deftypefnx {Function File} {@var{ccw} = } isCounterClockwise (@var{p1}, @var{p2}, @var{p3},@var{tol})
## Compute relative orientation of 3 points
##
##   Computes the orientation of the 3 points. The returns is:
##   +1 if the path  @var{p1}-> @var{p2}-> @var{p3} turns Counter-Clockwise (i.e., the point  @var{p3}
##       is located "on the left" of the line  @var{p1}- @var{p2})
##   -1 if the path turns Clockwise (i.e., the point  @var{p3} lies "on the right"
##       of the line  @var{p1}- @var{p2}) 
##   0  if the point  @var{p3} is located on the line segment [ @var{p1}  @var{p2}].
##
##   This function can be used in more complicated algorithms: detection of
##   line segment intersections, convex hulls, point in triangle...
##
##    @var{ccw} = isCounterClockwise( @var{p1},  @var{p2},  @var{p3}, EPS);
##   Specifies the threshold used for detecting colinearity of the 3 points.
##   Default value is 1e-12 (absolute).
##
##   Example
##
## @example
##   isCounterClockwise([0 0], [10 0], [10 10])
##   ans = 
##       1
##   isCounterClockwise([0 0], [0 10], [10 10])
##   ans = 
##       -1
##   isCounterClockwise([0 0], [10 0], [5 0])
##   ans = 
##       0
## @end example
##
##   @seealso{points2d, isPointOnLine, isPointInTriangle}
## @end deftypefn

function res = isCounterClockwise(p1, p2, p3, varargin)

  # get threshold value
  eps = 1e-12;
  if ~isempty(varargin)
      eps = varargin{1};
  end

  # ensure all data have same size
  np = max([size(p1, 1) size(p2, 1) size(p3,1)]);
  if np > 1
      if size(p1,1) == 1
          p1 = repmat(p1, np, 1);
      end
      if size(p2,1) == 1
          p2 = repmat(p2, np, 1);
      end
      if size(p3,1) == 1
          p3 = repmat(p3, np, 1);
      end    
  end

  # init with 0
  res = zeros(np, 1);

  # extract vector coordinates
  x0  = p1(:, 1);
  y0  = p1(:, 2);
  dx1 = p2(:, 1) - x0;
  dy1 = p2(:, 2) - y0;
  dx2 = p3(:, 1) - x0;
  dy2 = p3(:, 2) - y0;

  # check non colinear cases
  res(dx1 .* dy2 > dy1 .* dx2) =  1;
  res(dx1 .* dy2 < dy1 .* dx2) = -1;

  # case of colinear points
  ind = abs(dx1 .* dy2 - dy1 .* dx2) < eps;
  res(ind( (dx1(ind) .* dx2(ind) < 0) | (dy1(ind) .* dy2(ind) < 0) )) = -1;
  res(ind(  hypot(dx1(ind), dy1(ind)) <  hypot(dx2(ind), dy2(ind)) )) =  1;

endfunction

%!shared p0,pu,pd,pl,pr
%!  p0 = [2, 3]; # center point
%!  pu = [2, 4]; # up point
%!  pd = [2, 2]; # down point
%!  pl = [1, 3]; # left point
%!  pr = [3, 3]; # right point

%!assert (+1, isCounterClockwise(pl, p0, pu));
%!assert (+1, isCounterClockwise(pd, p0, pl));
%!assert (+1, isCounterClockwise(pr, p0, pd));
%!assert (+1, isCounterClockwise(pu, p0, pr));

# turn 90° right => return -1
%!assert (-1, isCounterClockwise(pl, p0, pd));
%!assert (-1, isCounterClockwise(pd, p0, pr));
%!assert (-1, isCounterClockwise(pr, p0, pu));
%!assert (-1, isCounterClockwise(pu, p0, pl));

%!test  # turn 90° left => return +1
%!  pts1 = [pl;pd;pr;pu;pl;pd;pr;pu];
%!  pts2 = [p0;p0;p0;p0;p0;p0;p0;p0];
%!  pts3 = [pu;pl;pd;pr;pd;pr;pu;pl];
%!  expected = [1;1;1;1;-1;-1;-1;-1];
%!  result = isCounterClockwise(pts1, pts2, pts3);
%!  assert (result, expected, 1e-6);

# aligned with p0-p1-p2 => return +1
%!assert (+1, isCounterClockwise(pl, p0, pr));
%!assert (+1, isCounterClockwise(pu, p0, pd));
%!assert (+1, isCounterClockwise(pr, p0, pl));
%!assert (+1, isCounterClockwise(pd, p0, pu));

# aligned ]ith p0-p2-p1 => return 0
%!assert (0, isCounterClockwise(pl, pr, p0));
%!assert (0, isCounterClockwise(pu, pd, p0));
%!assert (0, isCounterClockwise(pr, pl, p0));
%!assert (0, isCounterClockwise(pd, pu, p0));

# aligned with p1-p0-p2 => return -1
%!assert (-1, isCounterClockwise(p0, pl, pr));
%!assert (-1, isCounterClockwise(p0, pu, pd));
%!assert (-1, isCounterClockwise(p0, pr, pl));
%!assert (-1, isCounterClockwise(p0, pr, pl));
