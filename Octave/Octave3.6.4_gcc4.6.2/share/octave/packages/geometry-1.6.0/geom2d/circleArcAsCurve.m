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
## @deftypefn {Function File} {@var{p} = } circleArcAsCurve (@var{arc}, @var{N})
## Convert a circle arc into a series of points
##
##   P = circleArcAsCurve(ARC, N);
##   convert the circle ARC into a series of N points. 
##   ARC is given in the format: [XC YC R THETA1 DTHETA]
##   where XC and YC define the center of the circle, R its radius, THETA1
##   is the start of the arc and DTHETA is the angle extent of the arc. Both
##   angles are given in degrees. 
##   N is the number of vertices of the resulting polyline, default is 65.
##
##   The result is a N-by-2 array containing coordinates of the N points. 
##
##   [X Y] = circleArcAsCurve(ARC, N);
##   Return the result in two separate arrays with N lines and 1 column.
##
##
##   @seealso{circles2d, circleAsPolygon, drawCircle, drawPolygon}
## @end deftypefn

function varargout = circleArcAsCurve(arc, N)

  # default value for N
  if nargin < 2
      N = 65;
  end

  # vector of positions
  t0 = deg2rad(arc(4));
  t1 = t0 + deg2rad(arc(5));
  t = linspace(t0, t1, N)';

  # compute coordinates of vertices
  x = arc(1) + arc(3) * cos(t);
  y = arc(2) + arc(3) * sin(t);

  # format output
  if nargout <= 1
      varargout = {[x y]};
  else
      varargout = {x, y};
  end

endfunction

