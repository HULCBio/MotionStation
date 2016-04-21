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
## @deftypefn {Function File} {@var{h} = } drawParabola (@var{parabola})
## @deftypefnx {Function File} {@var{h} = } drawParabola (@var{parabola}, @var{t})
## @deftypefnx {Function File} {@var{h} = } drawParabola (@dots{}, @var{param}, @var{value})
## Draw a parabola on the current axis.
##
##   drawParabola(PARABOLA);
##   Draws a vertical parabola, defined by its vertex and its parameter.
##   Such a parabola admits a vertical axis of symetry.
##
##   The algebraic equation of parabola is given by:
##      (Y - YV) = A * (X - VX)^2
##   Where XV and YV are vertex coordinates and A is parabola parameter.
##
##   A parametric equation of parabola is given by:
##      x(t) = t + VX;
##      y(t) = A * t^2 + VY;
##
##   PARABOLA can also be defined by [XV YV A THETA], with theta being the
##   angle of rotation of the parabola (in degrees and Counter-Clockwise).
##
##   drawParabola(PARABOLA, T);
##   Specifies which range of 't' are used for drawing parabola. If T is an
##   array with only two values, the first and the last values are used as
##   interval bounds, and several values are distributed within this
##   interval.
##
##   drawParabola(..., NAME, VALUE);
##   Can specify one or several graphical options using parameter name-value
##   pairs.
##
##   H = drawParabola(...);
##   Returns an handle to the created graphical object.
##
##
##   Example:
##   @example
##   figure(1); clf; hold on;
##   drawParabola([50 50 .2 30]);
##   drawParabola([50 50 .2 30], [-1 1], 'color', 'r', 'linewidth', 2);
##   axis equal;
## @end example
##
##   @seealso{drawCircle, drawEllipse}
## @end deftypefn

function varargout = drawParabola(varargin)

  # Extract parabola
  if nargin<1
      error('geom2d:IllegalArgument', ...
          'Please specify parabola representation');
  end

  # input parabola is given as a packed array
  parabola = varargin{1};
  varargin(1) = [];
  x0 = parabola(:,1);
  y0 = parabola(:,2);
  a  = parabola(:,3);

  if size(parabola, 2)>3
      theta = parabola(:, 4);
  else
      theta = zeros(length(a), 1);
  end

  # extract parametrisation bounds
  bounds = [-100 100];
  if ~isempty(varargin)
      var = varargin{1};
      if isnumeric(var)
          bounds = var;
          varargin(1) = [];
      end
  end

  # create parametrisation
  if length(bounds)>2
      t = bounds;
  else
      t = linspace(bounds(1), bounds(end), 100);
  end

  # create handle array (in the case of several parabola)
  h = zeros(size(x0));

  # draw each parabola
  for i=1:length(x0)
      # compute transformation
      trans = ...
          createTranslation(x0(i), y0(i)) * ...
          createRotation(deg2rad(theta(i))) * ...
          createScaling(1, a);
      
	  # compute points on the parabola
      [xt yt] = transformPoint(t(:), t(:).^2, trans);

      # draw it
      h(i) = plot(xt, yt, varargin{:});
  end

  # process output arguments
  if nargout>0
      varargout{1}=h;
  end

endfunction

