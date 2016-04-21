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
## @deftypefn {Function File} {@var{points} = } intersectLineCircle (@var{line}, @var{circle})
## Intersection point(s) of a line and a circle
##
##   INTERS = intersectLineCircle(LINE, CIRCLE);
##   Returns a 2-by-2 array, containing on each row the coordinates of an
##   intersection point. If the line and circle do not intersect, the result
##   is filled with NaN.
##
##   Example
##   # base point
##   center = [10 0];
##   # create vertical line
##   l1 = [center 0 1];
##   # circle
##   c1 = [center 5];
##   pts = intersectLineCircle(l1, c1)
##   pts = 
##       10   -5
##       10    5
##   # draw the result
##   figure; clf; hold on;
##   axis([0 20 -10 10]);
##   drawLine(l1);
##   drawCircle(c1);
##   drawPoint(pts, 'rx');
##   axis equal;
##
##   @seealso{lines2d, circles2d, intersectLines, intersectCircles}
## @end deftypefn

function points = intersectLineCircle(line, circle)

  # local precision
  eps = 1e-14;

  # center parameters
  center = circle(:, 1:2);
  radius = circle(:, 3);

  # line parameters
  dp = line(:, 1:2) - center;
  vl = line(:, 3:4);

  # coefficient of second order equation
  a = sum(line(:, 3:4).^2, 2);
  b = 2*sum(dp .* vl, 2);
  c =  sum(dp.^2, 2) - radius.^2;

  # discriminant
  delta = b .^ 2 - 4 * a .* c;

  if delta > eps
      # find two roots of second order equation
      u1 = (-b - sqrt(delta)) / 2 ./ a;
      u2 = (-b + sqrt(delta)) / 2 ./ a;
      
      # convert into 2D coordinate
      points = [line(1:2) + u1 * line(3:4) ; line(1:2) + u2 * line(3:4)];

  elseif abs(delta) < eps
      # find unique root, and convert to 2D coord.
      u = -b / 2 ./ a;    
      points = line(1:2) + u*line(3:4);
      
  else
      # fill with NaN
      points = NaN * ones(2, 2);
      return;
  end

endfunction

