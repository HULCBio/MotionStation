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
## @deftypefn {Function File} {@var{circle} = } createDirectedCircle (@var{p1}, @var{p2}, @var{p3})
## @deftypefnx {Function File} {@var{circle} = } createDirectedCircle (@var{p1}, @var{p2})
## Create a circle from 2 or 3 points.
##
##   Creates the circle passing through the 3 given points. 
##   C is a 1x4 array of the form: [XC YX R INV].
##
## When two points are given, creates the circle whith center @var{p1} and passing
## throuh the point @var{p2}.
##
##   Works also when input are point arrays the same size, in this case the
##   result has as many lines as the point arrays.
##
##   Example
## 
##
##   @seealso{circles2d, createCircle}
## @end deftypefn

function circle = createDirectedCircle(varargin)

  if nargin == 2
      # inputs are the center and a point on the circle
      p1 = varargin{1};
      p2 = varargin{2};
      x0 = (p1(:,1) + p2(:,1))/2;
      y0 = (p1(:,2) + p2(:,2))/2;
      r = hypot((p2(:,1)-p1(:,1)), (p2(:,2)-p1(:,2)))/2;
      
      # circle is direct by default
      d = 0;
      
  elseif nargin == 3
      # inputs are three points on the circle
      p1 = varargin{1};
      p2 = varargin{2};
      p3 = varargin{3};

      # compute circle center
      line1 = medianLine(p1, p2);
      line2 = medianLine(p1, p3);
      center = intersectLines(line1, line2);
      x0 = center(:, 1); 
      y0 = center(:, 2);
      
      # circle radius
      r = hypot((p1(:,1)-x0), (p1(:,2)-y0));
      
      # compute circle orientation
      angle = angle3Points(p1, center, p2) + angle3Points(p2, center, p3);
      d = angle>2*pi;
  end
      
          
  circle = [x0 y0 r d];

endfunction

