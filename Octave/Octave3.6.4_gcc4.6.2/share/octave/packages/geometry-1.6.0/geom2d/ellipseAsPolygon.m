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
## @deftypefn {Function File} {@var{p} = } ellipseAsPolygon (@var{ell}, @var{n})
## Convert an ellipse into a series of points
##
##   P = ellipseAsPolygon(ELL, N);
##   converts ELL given as [x0 y0 a b] or [x0 y0 a b theta] into a polygon
##   with N edges. The result P is (N+1)-by-2 array containing coordinates
##   of the N+1 vertices of the polygon.
##   The resulting polygon is closed, i.e. the last point is the same as the
##   first one.
##
##   P = ellipseAsPolygon(ELL);
##   Use a default number of edges equal to 72. This result in one piont for
##   each 5 degrees.
##   
##   [X Y] = ellipseAsPolygon(...);
##   Return the coordinates o fvertices in two separate arrays.
##
##   @seealso{ellipses2d, circleAsPolygon, rectAsPolygon, drawEllipse}
## @end deftypefn

function varargout = ellipseAsPolygon(ellipse, N)

  # default value for N
  if nargin < 2
      N = 72;
  end

  # angle of ellipse
  theta = 0;
  if size(ellipse, 2) > 4
      theta = ellipse(:,5);
  end

  # get ellipse parameters
  xc = ellipse(:,1);
  yc = ellipse(:,2);
  a  = ellipse(:,3);
  b  = ellipse(:,4);

  # create time basis
  t = linspace(0, 2*pi, N+1)';

  # pre-compute trig functions (angles is in degrees)
  cot = cosd(theta);
  sit = sind(theta);

  # position of points
  x = xc + a * cos(t) * cot - b * sin(t) * sit;
  y = yc + a * cos(t) * sit + b * sin(t) * cot;

  # format output depending on number of a param.
  if nargout == 1
      varargout = {[x y]};
  elseif nargout == 2
      varargout = {x, y};
  end

endfunction

