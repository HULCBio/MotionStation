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
## @deftypefn {Function File} {@var{d} = } edgePosition (@var{point}, @var{edge})
## Return position of a point on an edge
##
##   POS = edgePosition(POINT, EDGE);
##   Computes position of point POINT on the edge EDGE, relative to the
##   position of edge vertices.
##   EDGE has the form [x1 y1 x2 y2],
##   POINT has the form [x y], and is assumed to belong to edge.
##   The position POS has meaning:
##     POS<0:    POINT is located before the first vertex
##     POS=0:    POINT is located on the first vertex
##     0<POS<1:  POINT is located between the 2 vertices (on the edge)
##     POS=1:    POINT is located on the second vertex
##     POS<0:    POINT is located after the second vertex
##
##   POS = edgePosition(POINT, EDGES);
##   If EDGES is an array of NL edges, return NL positions, corresponding to
##   each edge.
##
##   POS = edgePosition(POINTS, EDGE);
##   If POINTS is an array of NP points, return NP positions, corresponding
##   to each point.
##
##   POS = edgePosition(POINTS, EDGES);
##   If POINTS is an array of NP points and edgeS is an array of NL edges,
##   return an array of [NP NL] position, corresponding to each couple
##   point-edge.
##
##   @seealso{edges2d, createEdge, onEdge}
## @end deftypefn

function d = edgePosition(point, edge)

  # number of points and of edges
  Nl = size(edge, 1);
  Np = size(point, 1);

  if Np==Nl
      dxl = edge(:, 3)-edge(:,1);
      dyl = edge(:, 4)-edge(:,2);
      dxp = point(:, 1) - edge(:, 1);
      dyp = point(:, 2) - edge(:, 2);

      d = (dxp.*dxl + dyp.*dyl)./(dxl.*dxl+dyl.*dyl);

  else
      # expand one of the array to have the same size
      dxl = repmat((edge(:,3)-edge(:,1))', Np, 1);
      dyl = repmat((edge(:,4)-edge(:,2))', Np, 1);
      dxp = repmat(point(:,1), 1, Nl) - repmat(edge(:,1)', Np, 1);
      dyp = repmat(point(:,2), 1, Nl) - repmat(edge(:,2)', Np, 1);

      d = (dxp.*dxl + dyp.*dyl)./(dxl.*dxl+dyl.*dyl);
  end

endfunction

