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
## @deftypefn {Function File} {@var{loops} = } expandPolygon (@var{poly}, @var{dist})
##  Expand a polygon by a given (signed) distance
##
##   Associates to each edge of the polygon @var{poly} the parallel line located
##   at distance @var{dist} from the current edge, and compute intersections with
##   neighbor parallel lines. The resulting polygon is simplified to remove
##   inner "loops", and can be disconnected.
##   The result is a cell array, each cell containing a simple linear ring.
##
##   This is a kind of dilation, but behaviour on corners is different.
##   This function keeps angles of polygons, but there is no direct relation
##   between length of 2 polygons.
##
##   It is also possible to specify negative distance, and get all points
##   inside the polygon. If the polygon is convex, the result equals
##   morphological erosion of polygon by a ball with radius equal to the
##   given distance.
##
## @seealso{polygons2d}
## @end deftypefn

function loops = expandPolygon(poly, dist)

  # eventually copy first point at the end to ensure closed polygon
  if sum(poly(end, :)==poly(1,:))~=2
      poly = [poly; poly(1,:)];
  end

  # number of vertices of the polygon
  N = size(poly, 1)-1;

  # find lines parallel to polygon edges located at distance DIST
  lines = zeros(N, 4);
  for i=1:N
      side = createLine(poly(i,:), poly(i+1,:));
      lines(i, 1:4) = parallelLine(side, dist);
  end

  # compute intersection points of consecutive lines
  lines = [lines;lines(1,:)];
  poly2 = zeros(N, 2);
  for i=1:N
      poly2(i,1:2) = intersectLines(lines(i,:), lines(i+1,:));
  end

  # split result polygon into set of loops (simple polygons)
  loops = polygonLoops(poly2);

  # keep only loops whose distance to original polygon is correct
  distLoop = zeros(length(loops), 1);
  for i=1:length(loops)
      distLoop(i) = distancePolygons(loops{i}, poly);
  end
  loops = loops(abs(distLoop-abs(dist))<abs(dist)/1000);

endfunction
