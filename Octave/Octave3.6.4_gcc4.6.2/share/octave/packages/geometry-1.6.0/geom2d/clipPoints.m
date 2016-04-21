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
## @deftypefn {Function File} {@var{points2} =} clipPoints (@var{points}, @var{box})
## Clip a set of points by a box.
## 
## Returns the set @var{points2} which are located inside of the box @var{box}.
##
## @seealso{points2d, boxes2d, clipLine, drawPoint}
## @end deftypefn

function points = clipPoints(points, bb)

  # get bounding box limits
  xmin = bb(1);
  xmax = bb(2);
  ymin = bb(3);
  ymax = bb(4);

  # compute indices of points inside visible area
  xOk = points(:,1)>=xmin & points(:,1)<=xmax;
  yOk = points(:,2)>=ymin & points(:,2)<=ymax;

  # keep only points inside box
  points = points(xOk & yOk, :);

endfunction

%!demo
%! points = 2*rand(100,2)-1;
%! bb = [-0.5 0.5 -0.25 0.25];
%! cpo = clipPoints (points, bb);
%! 
%! plot(points(:,1),points(:,2),'xr')
%! hold on
%! drawBox(bb,'color','k')
%! plot(cpo(:,1),cpo(:,2),'*g')
%! hold off

%!shared bb
%!  bb = [0 10 0 20];

%!test
%!  corners = [0 0;10 0;0 20;10 20];
%!  cornersClipped = clipPoints(corners, bb);
%!  assert (4, size(cornersClipped, 1));
%!  assert (corners, cornersClipped, 1e-6);

%!test
%!  borders = [0 5;10 5;5 0;5 20];
%!  bordersClipped = clipPoints(borders, bb);
%!  assert (4, size(bordersClipped, 1));
%!  assert (borders, bordersClipped, 1e-6);

%!test
%!  inside = [5 5;5 10;5 15];
%!  insideClipped = clipPoints(inside, bb);
%!  assert (size(inside, 1), size(insideClipped, 1));
%!  assert (inside, insideClipped);

%!test
%!  points = [-1 0;11 0;-1 20;11 20;0 -1;0 21;10 -1;10 21];
%!  pointsClipped = clipPoints(points, bb);
%!  assert (0, size(pointsClipped, 1));

%!test
%!  points = [-5 10;0 10;5 10;10 10; 15 10];
%!  pointsClipped = clipPoints(points, bb);
%!  assert (3, size(pointsClipped, 1));
%!  assert (points(2:4,:), pointsClipped, 1e-6);
