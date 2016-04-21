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
## @deftypefn {Function File} {@var{area} = } polygonArea (@var{points})
## @deftypefnx {Function File} {@var{area} = } polygonArea (@var{px},@var{py})
## Compute the signed area of a polygon.
##
## Compute area of a polygon defined by @var{points}. @var{points} is a N-by-2
## matrix containing coordinates of vertices.
##
## Vertices of the polygon are supposed to be oriented Counter-Clockwise
## (CCW). In this case, the signed area is positive.
## If vertices are oriented Clockwise (CW), the signed area is negative.
##
## If polygon is self-crossing, the result is undefined.
##
## If @var{points} is a cell, each element is considered a polygon and the area
## of each one is returned in the matrix @var{area}. The matrix has the same shape
## as the cell.
##
## References:
## Algorithm adapted from P. Bourke web page
## http://local.wasp.uwa.edu.au/~pbourke/geometry/polyarea/
##
## @seealso{polygons2d, polygonCentroid, drawPolygon}
## @end deftypefn

function area = polygonArea(varargin)

  var = varargin{1};

  # in case of polygon sets, computes several areas
  if iscell (var)
     area = cellfun (@func, var);

#     area = zeros(length(var), 1);
#          for i = 1:length(var)
#              area(i) = polygonArea(var{i}, varargin{2:end});
#          end
#          return;
#      end
  else
    # extract coordinates
    if nargin == 1

      area = func(var)

    elseif nargin == 2

      px = varargin{1};
      py = varargin{2};

      # indices of next vertices
      N = length(px);
      iNext = [2:N 1];

      # compute area (vectorized version)
      area = sum(px .* py(iNext) - px(iNext) .* py) / 2;

    end

  end

endfunction

function a = func (c)

  N = length (c);
  iNext = [2:N 1];
  a = sum (c(:,1) .* c(iNext,2) - c(iNext,1) .* c(:,2)) / 2;

endfunction
