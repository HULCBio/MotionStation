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
## @deftypefn {Function File} {@var{b} = } isPointOnEdge (@var{point}, @var{edge})
## @deftypefnx {Function File} {@var{b} = } isPointOnEdge (@var{point}, @var{edge}, @var{tol})
## @deftypefnx {Function File} {@var{b} = } isPointOnEdge (@var{point}, @var{edgearray})
## @deftypefnx {Function File} {@var{b} = } isPointOnEdge (@var{pointarray}, @var{edgearray})
## Test if a point belongs to an edge.
#
#   with @var{point} being [xp yp], and @var{edge} being [x1 y1 x2 y2], returns TRUE if
#   the point is located on the edge, and FALSE otherwise.
#
#   Specify an optilonal tolerance value @var{tol}. The tolerance is given as a
#   fraction of the norm of the edge direction vector. Default is 1e-14. 
#
#   When one of the inputs has several rows, return the result of the test
#   for each element of the array tested against the single parameter.
#
#   When both @var{pointarray} and @var{edgearray} have the same number of rows,
#   returns a column vector with the same number of rows.
#   When the number of rows are different and both greater than 1, returns
#   a Np-by-Ne matrix of booleans, containing the result for each couple of
#   point and edge.
#
#   @seealso{edges2d, points2d, isPointOnLine}
## @end deftypefn

function b = isPointOnEdge(point, edge, varargin)

  # extract computation tolerance
  tol = 1e-14;
  if ~isempty(varargin)
      tol = varargin{1};
  end

  # number of edges and of points
  Np = size(point, 1);
  Ne = size(edge, 1);

  # adapt size of inputs if needed, and extract elements for computation
  if Np == Ne
      # When the number of points and edges is the same, the one-to-one test
      # will be computed, so there is no need to repeat matrices
      dx = edge(:,3) - edge(:,1);
      dy = edge(:,4) - edge(:,2);
      lx = point(:,1) - edge(:,1);
      ly = point(:,2) - edge(:,2);
      
  elseif Np == 1
      # one point, several edges
      dx = edge(:, 3) - edge(:, 1);
      dy = edge(:, 4) - edge(:, 2);
      lx = point(ones(Ne, 1), 1) - edge(:, 1);
      ly = point(ones(Ne, 1), 2) - edge(:, 2);
      
  elseif Ne == 1
      # several points, one edge
      dx = (edge(3) - edge(1)) * ones(Np, 1);
      dy = (edge(4) - edge(2)) * ones(Np, 1);
      lx = point(:, 1) - edge(1);
      ly = point(:, 2) - edge(2);

  else
      # Np points and Ne edges:
      # Create an array for each parameter, so that the result will be a
      # Np-by-Ne matrix of booleans (requires more memory, and uses repmat)

      x0 = repmat(edge(:, 1)', Np, 1);
      y0 = repmat(edge(:, 2)', Np, 1);
      dx = repmat(edge(:,3)', Np,  1) - x0;
      dy = repmat(edge(:,4)', Np,  1) - y0;
      
      lx = repmat(point(:, 1), 1, Ne) - x0;
      ly = repmat(point(:, 2), 1, Ne) - y0;
  end

  # test if point is located on supporting line
  b1 = (abs(lx.*dy - ly.*dx) ./ hypot(dx, dy)) < tol;

  # compute position of point with respect to edge bounds
  # use different tests depending on line angle
  ind     = abs(dx) > abs(dy);
  t       = zeros(size(dx));
  t(ind)  = lx( ind) ./ dx( ind);
  t(~ind) = ly(~ind) ./ dy(~ind);

  # check if point is located between edge bounds
  b = t >- tol & t-1 < tol & b1;

endfunction

%!shared points, vertices, edges

%!demo
%!   # create a point array
%!   points = [10 10;15 10; 30 10];
%!   # create an edge array
%!   vertices = [10 10;20 10;20 20;10 20];
%!   edges = [vertices vertices([2:end 1], :)];
%!
%!   # Test one point and one edge
%!   isPointOnEdge(points(1,:), edges(1,:))
%!   isPointOnEdge(points(3,:), edges(1,:))

%!demo
%!   # create a point array
%!   points = [10 10;15 10; 30 10];
%!   # create an edge array
%!   vertices = [10 10;20 10;20 20;10 20];
%!   edges = [vertices vertices([2:end 1], :)];
%!
%!   # Test one point and several edges
%!   isPointOnEdge(points(1,:), edges)'

%!demo
%!   # create a point array
%!   points = [10 10;15 10; 30 10];
%!   # create an edge array
%!   vertices = [10 10;20 10;20 20;10 20];
%!   edges = [vertices vertices([2:end 1], :)];
%!
%!   # Test several points and one edge
%!   isPointOnEdge(points, edges(1,:))'

%!demo
%!   # create a point array
%!   points = [10 10;15 10; 30 10];
%!   # create an edge array
%!   vertices = [10 10;20 10;20 20;10 20];
%!   edges = [vertices vertices([2:end 1], :)];
%!
%!   # Test N points and N edges
%!   isPointOnEdge(points, edges(1:3,:))'

%!demo
%!   # create a point array
%!   points = [10 10;15 10; 30 10];
%!   # create an edge array
%!   vertices = [10 10;20 10;20 20;10 20];
%!   edges = [vertices vertices([2:end 1], :)];
%!
%!   # Test NP points and NE edges
%!   isPointOnEdge(points, edges)

%!test
%!  p1 = [10 20];
%!  p2 = [80 20];
%!  edge = [p1 p2];
%!  p0 = [10 20];
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [80 20];
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [50 20];
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [9.99 20];
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [80.01 20];
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [50 21];
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [79 19];
%!  assert (!isPointOnEdge(p0, edge));

%!test
%!  p1 = [20 10];
%!  p2 = [20 80];
%!  edge = [p1 p2];
%!  p0 = [20 10];
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [20 80];
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [20 50];
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [20 9.99];
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [20 80.01];
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [21 50];
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [19 79];
%!  assert (!isPointOnEdge(p0, edge));

%!test
%!  p1 = [10 20];
%!  p2 = [60 70];
%!  edge = [p1 p2];
%!  assert (isPointOnEdge(p1, edge));
%!  assert (isPointOnEdge(p2, edge));
%!  p0 = [11 21];
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [59 69];
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [9.99 19.99];
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [60.01 70.01];
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [30 50.01];
%!  assert (!isPointOnEdge(p0, edge));

%!test
%!  edge = [10 20 80 20; 20 10 20 80; 20 10 60 70];
%!  p0 = [20 20];
%!  assert ([true ; true ; false], isPointOnEdge(p0, edge));

%!test
%!  k = 1e15;
%!  p1 = [10 20]*k;
%!  p2 = [60 70]*k;
%!  edge = [p1 p2];
%!  assert (isPointOnEdge(p1, edge));
%!  assert (isPointOnEdge(p2, edge));
%!  p0 = [11 21]*k;
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [59 69]*k;
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [9.99 19.99]*k;
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [60.01 70.01]*k;
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [30 50.01]*k;
%!  assert (!isPointOnEdge(p0, edge));

%!test
%!  k = 1e-10;
%!  p1 = [10 20]*k;
%!  p2 = [60 70]*k;
%!  edge = [p1 p2];
%!  assert (isPointOnEdge(p1, edge));
%!  assert (isPointOnEdge(p2, edge));
%!  p0 = [11 21]*k;
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [59 69]*k;
%!  assert (isPointOnEdge(p0, edge));
%!  p0 = [9.99 19.99]*k;
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [60.01 70.01]*k;
%!  assert (!isPointOnEdge(p0, edge));
%!  p0 = [30 50.01]*k;
%!  assert (!isPointOnEdge(p0, edge));

%!test
%!  p1 = [10 20];
%!  p2 = [80 20];
%!  edge = [p1 p2];
%!  p0 = [10 20; 80 20; 50 20;50 21];
%!  exp = [true;true;true;false];
%!  assert (exp, isPointOnEdge(p0, edge));

%!test
%!  p1 = [10 20];
%!  p2 = [80 20];
%!  edge = [p1 p2];
%!  p0 = [40 20];
%!  exp = [true;true;true;true];
%!  assert (exp, isPointOnEdge(p0, [edge;edge;edge;edge]));

%!test
%!  edge1 = [10 20 80 20];
%!  edge2 = [30 10 30 80];
%!  edges = [edge1; edge2];
%!  p0 = [40 20;30 90];
%!  exp = [true;false];
%!  assert (exp, isPointOnEdge(p0, edges));
