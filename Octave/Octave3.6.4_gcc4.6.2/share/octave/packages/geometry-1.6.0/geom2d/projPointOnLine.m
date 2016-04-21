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
## @deftypefn {Function File} {@var{point} = } projPointOnLine (@var{pt1}, @var{line})
##  Project of a point orthogonally onto a line
##
##   Computes the (orthogonal) projection of point @var{pt1} onto the line @var{line}.
##   
##   Function works also for multiple points and lines. In this case, it
##   returns multiple points.
##   Point @var{pt1} is a [N*2] array, and @var{line} is a [N*4] array (see createLine
##   for details). Result @var{point} is a [N*2] array, containing coordinates of
##   orthogonal projections of @var{pt1} onto lines @var{line}.
##
##   @seealso{lines2d, points2d, isPointOnLine, linePosition}
## @end deftypefn

function point = projPointOnLine(point, line)

  # ensure input arguments have same size
  if size(line, 1)==1 && size(point, 1)>1
      line = repmat(line, [size(point, 1) 1]);
  end
  if size(point, 1)==1 && size(line, 1)>1
      point = repmat(point, [size(line, 1) 1]);
  end

  # slope of line
  dx = line(:, 3);
  dy = line(:, 4);

  # first find relative position of projection on the line,
  tp = ((point(:, 2) - line(:, 2)).*dy + (point(:, 1) - line(:, 1)).*dx) ./ (dx.*dx+dy.*dy);

  # convert position on line to cartesian coordinate
  point = line(:,1:2) + [tp tp].*[dx dy];

endfunction
