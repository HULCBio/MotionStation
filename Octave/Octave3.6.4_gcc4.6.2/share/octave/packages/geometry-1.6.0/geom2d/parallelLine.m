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
## @deftypefn {Function File} {@var{res} = } parallelLine (@var{line}, @var{point})
## @deftypefnx {Function File} {@var{res} = } parallelLine (@var{line}, @var{dist})
## Create a line parallel to another one.
##
##   Returns the line with same direction vector than @var{line} and going through
##   the point given by @var{point}. 
##   @var{line} is given as [x0 y0 dx dy] and @var{point} is [xp yp].
##
##   Uses relative distance to specify position. The new line will be
##   located at distance @var{dist}, counted positive in the right side of @var{line}
##   and negative in the left side.
##
##   @seealso{lines2d, orthogonalLine, distancePointLine}
## @end deftypefn

function res = parallelLine(line, point)

  if size(point, 1)==1
      # use a distance. Compute position of point located at distance DIST on
      # the line orthogonal to the first one.
      point = pointOnLine([line(:,1) line(:,2) line(:,4) -line(:,3)], point);
  end

  # normal case: compute line through a point with given direction
  res = zeros(1, 4);
  res(1:2) = point;
  res(3:4) = line(3:4);

endfunction
