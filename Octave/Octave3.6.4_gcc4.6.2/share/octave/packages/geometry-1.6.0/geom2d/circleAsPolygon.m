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
## @deftypefn {Function File} {@var{P} = } circleAsPolygon (@var{circle}, @var{N})
## Convert a circle into a series of points
##
##   P = circleAsPolygon(CIRCLE, N);
##   convert circle given as [x0 y0 r], where x0 and y0 are coordinate of
##   center, and r is the radius, into an array of  [(N+1)x2] double, 
##   containing x and y values of points. 
##   The polygon is closed
##
##   P = circleAsPolygon(CIRCLE);
##   uses a default value of N=64 points
##
##   Example
##   circle = circleAsPolygon([10 0 5], 16);
##   figure;
##   drawPolygon(circle);
##
##   @seealso{circles2d, polygons2d, createCircle}
## @end deftypefn

function varargout = circleAsPolygon(circle, varargin)
  # determines number of points
  N = 64;
  if ~isempty(varargin)
      N = varargin{1};
  end

  # create circle
  t = linspace(0, 2*pi, N+1)';
  x = circle(1) + circle(3)*cos(t);
  y = circle(2) + circle(3)*sin(t);

  if nargout==1
      varargout{1}=[x y];
  elseif nargout==2
      varargout{1}=x;
      varargout{2}=y;    
  end

endfunction
