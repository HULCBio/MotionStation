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
## @deftypefn {Function File} {@var{pts} = } squaregrid (@var{bounds}, @var{origin}, @var{size})
## Generate equally spaces points in plane.
##
##   usage
##   PTS = squareGrid(BOUNDS, ORIGIN, SIZE)
##   generate points, lying in the window defined by BOUNDS (=[xmin ymin
##   xmax ymax]), starting from origin with a constant step equal to size.
##   
##   Example
##   PTS = squareGrid([0 0 10 10], [3 3], [4 2])
##   will return points : 
##   [3 1;7 1;3 3;7 3;3 5;7 5;3 7;7 7;3 9;7 9];
##
##   TODO: add possibility to use rotated grid
##
## @end deftypefn

function varargout = squareGrid(bounds, origin, size)

  # find all x coordinate
  x1 = bounds(1) + mod(origin(1)-bounds(1), size(1));
  x2 = bounds(3) - mod(bounds(3)-origin(1), size(1));
  lx = (x1:size(1):x2)';

  # find all y coordinate
  y1 = bounds(2) + mod(origin(2)-bounds(2), size(2));
  y2 = bounds(4) - mod(bounds(4)-origin(2), size(2));
  ly = (y1:size(2):y2)';

  # number of points in each coord, and total number of points
  ny = length(ly);
  nx = length(lx);
  np = nx*ny;

  # create points
  pts = zeros(np, 2);
  for i=1:ny
      pts( (1:nx)'+(i-1)*nx, 1) = lx;
      pts( (1:nx)'+(i-1)*nx, 2) = ly(i);
  end    

  # process output
  if nargout>0
      varargout{1} = pts;
  end

endfunction

