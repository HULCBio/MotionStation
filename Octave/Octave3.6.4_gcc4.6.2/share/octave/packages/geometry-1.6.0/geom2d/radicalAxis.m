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
## @deftypefn {Function File} {@var{line} = } radicalAxis (@var{circle1}, @var{circle2})
## Compute the radical axis (or radical line) of 2 circles
##
##   L = radicalAxis(C1, C2)
##   Computes the radical axis of 2 circles.
##
##   Example
##   C1 = [10 10 5];
##   C2 = [60 50 30];
##   L = radicalAxis(C1, C2);
##   hold on; axis equal;axis([0 100 0 100]); 
##   drawCircle(C1);drawCircle(C2);drawLine(L);
##
##   Ref:
##   http://mathworld.wolfram.com/RadicalLine.html
##   http://en.wikipedia.org/wiki/Radical_axis
##
##   @seealso{lines2d, circles2d, createCircle}
##
## @end deftypefn

function line = radicalAxis(circle1, circle2)

  # extract circles parameters
  x1 = circle1(:,1);
  x2 = circle2(:,1);
  y1 = circle1(:,2);
  y2 = circle2(:,2);
  r1 = circle1(:,3);
  r2 = circle2(:,3);

  # distance between each couple of centers
  dist  = sqrt((x2-x1).^2 + (y2-y1).^2);

  # relative position of intersection point of 
  # the radical line with the line joining circle centers
  d = (dist.^2 + r1.^2 - r2.^2) * .5 ./ dist;

  # compute angle of radical axis
  angle = lineAngle(createLine([x1 y1], [x2 y2]));
  cot = cos(angle);
  sit = sin(angle);

  # parameters of the line
  x0 = x1 + d*cot;
  y0 = y1 + d*sit;
  dx = -sit;
  dy = cot;

  # concatenate into one structure
  line = [x0 y0 dx dy];

endfunction

