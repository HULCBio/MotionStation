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
## @deftypefn {Function File} {@var{dist} = } distancePointPolyline (@var{point},@var{poly})
##  Compute shortest distance between a point and a polyline
##   Example:
## @example
##       pt1 = [30 20];
##       pt2 = [30 5];
##       poly = [10 10;50 10;50 50;10 50];
##       distancePointPolyline([pt1;pt2], poly)
##       ans =
##           10
##            5
## @end example
##
## @seealso{polygons2d, points2d,distancePointEdge, projPointOnPolyline}
## @end deftypefn

function varargout = distancePointPolyline(point, poly, varargin)

  # number of points
  Np = size(point, 1);

  # allocate memory for result
  minDist = inf * ones(Np, 1);

  ## construct the set of edges
  edges = [poly(1:end-1, :) poly(2:end, :)];

  ## compute distance between current each point and all edges
  dist = distancePointEdge(point, edges);
  ## get the minimum distance
  minDist = min(dist, [], 2);

  ## original loopy verion:
  # process each point
  # for p = 1:Np
  #     # construct the set of edges
  #     edges = [poly(1:end-1, :) poly(2:end, :)];      
  #     # compute distance between current each point and all edges
  #     dist = distancePointEdge(point(p, :), edges);
  #     # update distance if necessary
  #     minDist(p) = min(dist);
  # end

  # process output arguments
  if nargout<=1
      varargout{1} = minDist;
  end

endfunction
