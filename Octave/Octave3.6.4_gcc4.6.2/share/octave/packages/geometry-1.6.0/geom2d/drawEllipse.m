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
## @deftypefn {Function File} {@var{h} = } drawEllipse (@var{elli})
## @deftypefnx {Function File} {@var{h} = } drawEllipse (@var{xc}, @var{yc}, @var{ra}, @var{rb})
## @deftypefnx {Function File} {@var{h} = } drawEllipse (@var{xc}, @var{yc}, @var{ra}, @var{rb}, @var{theta})
## @deftypefnx {Function File} {@var{h} = } drawEllipse (@dots{}, @var{param}, @var{value})
## Draw an ellipse on the current axis.
##
##   drawEllipse(ELLI);
##   Draws the ellipse ELLI in the form [XC YC RA RB THETA], with center
##   (XC, YC), with main axis of half-length RA and RB, and orientation
##   THETA in degrees counted counter-clockwise.
##   Puts all parameters into one single array.
##
##   drawEllipse(XC, YC, RA, RB);
##   drawEllipse(XC, YC, RA, RB, THETA);
##   Specifies ellipse parameters as separate arguments (old syntax).
##
##   drawEllipse(..., NAME, VALUE);
##   Specifies drawing style of ellipse, see the help of plot function.
##
##   H = drawEllipse(...);
##   Also returns handles to the created line objects.
##
##   -> Parameters can also be arrays. In this case, all arrays are supposed 
##   to have the same size.
##
##   Example: 
##   @example
##   # Draw an ellipse centered in [50 50], with semi major axis length of
##   # 40, semi minor axis length of 20, and rotated by 30 degrees.
##     figure(1); clf; hold on;
##     drawEllipse([50 50 40 20 30]);
##     axis equal;
## @end example
##
##   @seealso{ellipses2d, drawCircle, drawEllipseArc, ellipseAsPolygon}
## @end deftypefn

function varargout = drawEllipse(varargin)

  # extract dawing style strings
  styles = {};
  for i = 1:length(varargin)
      if ischar(varargin{i})
          styles = varargin(i:end);
          varargin(i:end) = [];
          break;
      end
  end

  # extract ellipse parameters
  if length(varargin)==1
      # ellipse is given in a single array
      ellipse = varargin{1};
      x0 = ellipse(:, 1);
      y0 = ellipse(:, 2);
      a  = ellipse(:, 3);
      b  = ellipse(:, 4);
      if length(ellipse)>4
          theta = ellipse(:, 5);
      else
          theta = zeros(size(x0));
      end
      
  elseif length(varargin)>=4
      # ellipse parameters given as separate arrays
      x0 = varargin{1};
      y0 = varargin{2};
      a  = varargin{3};
      b  = varargin{4};
      if length(varargin)>4
          theta = varargin{5};
      else
          theta = zeros(size(x0));
      end
      
  else
      error('drawEllipse: incorrect input arguments');
  end


  ## Process drawing of a set of ellipses

  # angular positions of vertices
  t = linspace(0, 2*pi, 145);

  # compute position of points to draw each ellipse
  h = zeros(length(x0), 1);
  for i = 1:length(x0)
      # pre-compute rotation angles (given in degrees)
      cot = cosd(theta(i));
      sit = sind(theta(i));
      
      # compute position of points used to draw current ellipse
      xt = x0(i) + a(i) * cos(t) * cot - b(i) * sin(t) * sit;
      yt = y0(i) + a(i) * cos(t) * sit + b(i) * sin(t) * cot;
      
      # stores handle to graphic object
      h(i) = plot(xt, yt, styles{:});
  end

  # return handles if required
  if nargout > 0
      varargout = {h};
  end

endfunction

