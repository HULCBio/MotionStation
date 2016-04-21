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
## @deftypefn {Function File} {@var{h} = } drawCircleArc (@var{xc}, @var{yc}, @var{r}, @var{start}, @var{end})
## @deftypefnx {Function File} {@var{h} = } drawCircleArc (@var{arc})
## @deftypefnx {Function File} {@var{h} = } drawCircleArc (@dots{}, @var{param}, @var{value})
## Draw a circle arc on the current axis
##
##   drawCircleArc(XC, YC, R, START, EXTENT);
##   Draws circle with center (XC, YC), with radius R, starting from angle
##   START, and with angular extent given by EXTENT. START and EXTENT angles
##   are given in degrees.
##
##   drawCircleArc(ARC);
##   Puts all parameters into one single array.
##
##   drawCircleArc(..., PARAM, VALUE);
##   specifies plot properties by using one or several parameter name-value
##   pairs.
##
##   H = drawCircleArc(...);
##   Returns a handle to the created line object.
##
##   @example
##     # Draw a red thick circle arc
##     arc = [10 20 30 -120 240];
##     figure;
##     axis([-50 100 -50 100]);
##     hold on
##     drawCircleArc(arc, 'LineWidth', 3, 'Color', 'r')
## @end example
##
##   @seealso{circles2d, drawCircle, drawEllipse}
## @end deftypefn

function varargout = drawCircleArc(varargin)

  if nargin == 0
      error('Need to specify circle arc');
  end

  circle = varargin{1};
  if size(circle, 2) == 5
      x0  = circle(:,1);
      y0  = circle(:,2);
      r   = circle(:,3);
      start   = circle(:,4);
      extent  = circle(:,5);
      varargin(1) = [];
      
  elseif length(varargin) >= 5
      x0  = varargin{1};
      y0  = varargin{2};
      r   = varargin{3};
      start   = varargin{4};
      extent  = varargin{5};
      varargin(1:5) = [];
      
  else
      error('drawCircleArc: please specify center, radius and angles of circle arc');
  end

  # convert angles in radians
  t0  = deg2rad(start);
  t1  = t0 + deg2rad(extent);

  # number of line segments
  N = 60;

  # initialize handles vector
  h   = zeros(length(x0), 1);

  # draw each circle arc individually
  for i = 1:length(x0)
      # compute basis
      t = linspace(t0(i), t1(i), N+1)';

      # compute vertices coordinates
      xt = x0(i) + r(i)*cos(t);
      yt = y0(i) + r(i)*sin(t);
      
      # draw the circle arc
      h(i) = plot(xt, yt, varargin{:});
  end

  if nargout > 0
      varargout = {h};
  end


endfunction

