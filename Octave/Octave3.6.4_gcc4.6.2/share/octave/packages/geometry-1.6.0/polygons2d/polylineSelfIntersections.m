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
## @deftypefn {Function File} {@var{pts} = } polylineSelfIntersections (@var{poly})
##   Find self-intersections points of a polyline
##
##   Return the position of self intersection points
##
##   Also return the 2 positions of each intersection point (the position
##   when meeting point for first time, then position when meeting point
##   for the second time).
##
##   Example
## @example
##       # use a gamma-shaped polyline
##       poly = [0 0;0 10;20 10;20 20;10 20;10 0];
##       polylineSelfIntersections(poly)
##       ans = 
##           10 10
##
##       # use a 'S'-shaped polyline
##       poly = [10 0;0 0;0 10;20 10;20 20;10 20];
##       polylineSelfIntersections(poly)
##       ans = 
##           10 10
## @end example
##   
##  @seealso{polygons2d, intersectPolylines, polygonSelfIntersections}
## @end deftypefn

function varargout = polylineSelfIntersections(poly, varargin)

  ## Initialisations

  # determine whether the polyline is closed
  closed = false;
  if ~isempty(varargin)
      closed = varargin{1};
      if ischar(closed)
          if strcmp(closed, 'closed')
              closed = true;
          elseif strcmp(closed, 'open')
              closed = false;
          end
      end
  end

  # if polyline is closed, ensure the last point equals the first one
  if closed
      if sum(abs(poly(end, :)-poly(1,:))<1e-14)~=2
          poly = [poly; poly(1,:)];
      end
  end

  # arrays for storing results
  points  = zeros(0, 2);
  pos1    = zeros(0, 1);
  pos2    = zeros(0, 1);

  # number of vertices
  Nv = size(poly, 1);


  ## Main processing

  # index of current intersection
  ip = 0;

  # iterate over each couple of edge ( (N-1)*(N-2)/2 iterations)
  for i=1:Nv-2
      # create first edge
      edge1 = [poly(i, :) poly(i+1, :)];
      for j=i+2:Nv-1
          # create second edge
          edge2 = [poly(j, :) poly(j+1, :)];

          # check conditions on bounding boxes
          if min(edge1([1 3]))>max(edge2([1 3]))
              continue;
          end
          if max(edge1([1 3]))<min(edge2([1 3]))
              continue;
          end
          if min(edge1([2 4]))>max(edge2([2 4]))
              continue;
          end
          if max(edge1([2 4]))<min(edge2([2 4]))
              continue;
          end
          
          # compute intersection point
          inter = intersectEdges(edge1, edge2);
          
          if sum(isfinite(inter))==2
              # add point to the list
              ip = ip + 1;
              points(ip, :) = inter;
              
              # also compute positions on the polyline
              pos1(ip, 1) = i+edgePosition(inter, edge1)-1;
              pos2(ip, 1) = j+edgePosition(inter, edge2)-1;
          end
      end
  end

  # if polyline is closed, the first vertex was found as an intersection, so
  # we need to remove it
  if closed
      dist = distancePoints(points, poly(1,:));
      [minDist ind] = min(dist); ##ok<ASGLU>
      points(ind,:) = [];
      pos1(ind)   = [];
      pos2(ind)   = [];
  end

  ## Post-processing

  # process output arguments
  if nargout<=1
      varargout{1} = points;
  elseif nargout==3
      varargout{1} = points;
      varargout{2} = pos1;
      varargout{3} = pos2;
  end

endfunction
