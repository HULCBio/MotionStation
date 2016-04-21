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
## @deftypefn {Function File} {@var{dist} = } distancePointEdge (@var{point}, @var{edge})
## @deftypefnx {Function File} {@var{dist} = } distancePointEdge (@dots{}, @var{opt})
## @deftypefnx {Function File} {[@var{dist} @var{pos}]= } distancePointEdge (@dots{})
## Minimum distance between a point and an edge
##
## Return the euclidean distance between edge @var{edge} and point @var{point}.
## @var{edge} has the form: [x1 y1 x2 y2], and @var{point} is [x y].
## If @var{edge} is Ne-by-4 and @var{point} is Np-by-2, then @var{dist} is
## Np-by-Ne, where each row contains the distance of each point to all the edges.
##
## If @var{opt} is true (or equivalent), the optput is cmpatible with the original function:
## @table @samp
## @item 1
## If @var{point} is 1-by-2 array, the result is Ne-by-1 array computed for each edge.
## @item 2
## If @var{edge} is a 1-by-4 array, the result is Np-by-1 computed for each point.
## @item 3
## If both @var{point} and @var{edge} are array, they must have the same number of
## rows, and the result is computed for each couple @code{@var{point}(i,:),@var{edge}(i,:)}.
## @end table
##
## If the the second output argument @var{pos} is requested, the function also
## returns the position of closest point on the edge. @var{pos} is comprised
## between 0 (first point) and 1 (last point).
##
## @seealso{edges2d, points2d, distancePoints, distancePointLine}
## @end deftypefn

## Rewritten to accept different numbers of points and edges.
## 2012 - Juan Pablo Carbajal

function [dist, tp] = distancePointEdge(point, edge, opt=[])

  Np = size (point,1);
  Ne = size (edge,1);
  edge = edge.';

  # direction vector of each edge
  dx = edge(3,:) - edge(1,:);
  dy = edge(4,:) - edge(2,:);

  # compute position of points projected on the supporting line
  # (Size of tp is the max number of edges or points)

  delta = dx .* dx + dy .* dy;
  mask = delta < eps;
  delta(mask) = 1;
  warning ('off', 'Octave:broadcast');
  tp = ((point(:, 1) - edge(1, :)) .* dx + (point(:, 2) - edge(2, :)) .* dy) ./ delta;
  tp(:,mask) = 0;

  # change position to ensure projected point is located on the edge
  tp(tp < 0) = 0;
  tp(tp > 1) = 1;

  # coordinates of projected point
  p0x = (edge(1,:) + tp .* dx);
  p0y = (edge(2,:) + tp .* dy);

  # compute distance between point and its projection on the edge
  dist = sqrt((point(:,1) - p0x) .^ 2 + (point(:,2) - p0y) .^ 2);

  warning ('on', 'Octave:broadcast');

  ## backwards compatibility
  if opt
    if  Np != Ne && (Ne != 1 && Np !=1)
      error ("geometry:InvalidArgument", ...
      "Sizes must be equal or one of the inputs must be 1-by-N array.");
    end
    if Np == Ne
      dist = diag(dist)(:);
      tp = diag(tp)(:);
    elseif Np == 1
      dist = dist.';
      tp = tp.';
    end
  end

endfunction

## Original code
##tp = ((point(:, 1) - edge(:, 1)) .* dx + (point(:, 2) - edge(:, 2)) .* dy) ./ delta;
### ensure degenerated edges are correclty processed (consider the first
### vertex is the closest)
##if Ne > 1
##  tp(delta < eps) = 0;
##elseif delta < eps
##  tp(:) = 0;
##end

### change position to ensure projected point is located on the edge
##tp(tp < 0) = 0;
##tp(tp > 1) = 1;

### coordinates of projected point
##p0 = [edge(:,1) + tp .* dx, edge(:,2) + tp .* dy];

### compute distance between point and its projection on the edge
##dist = sqrt((point(:,1) - p0(:,1)) .^ 2 + (point(:,2) - p0(:,2)) .^ 2);
