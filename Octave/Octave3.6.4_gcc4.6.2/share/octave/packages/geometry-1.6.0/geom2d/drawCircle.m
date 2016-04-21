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
## @deftypefn {Function File} {@var{h} = } drawCircle (@var{x0}, @var{y0}, @var{r})
## @deftypefnx {Function File} {@var{h} = } drawCircle (@var{circle})
## @deftypefnx {Function File} {@var{h} = } drawCircle (@var{center}, @var{radius})
## @deftypefnx {Function File} {@var{h} = } drawCircle (@dots{}, @var{nstep})
## @deftypefnx {Function File} {@var{h} = } drawCircle (@dots{}, @var{name}, @var{value})
## Draw a circle on the current axis
##
##   drawCircle(X0, Y0, R);
##   Draw the circle with center (X0,Y0) and the radius R. If X0, Y0 and R
##   are column vectors of the same length, draw each circle successively.
##
##   drawCircle(CIRCLE);
##   Concatenate all parameters in a Nx3 array, where N is the number of
##   circles to draw.
##
##   drawCircle(CENTER, RADIUS);
##   Specify CENTER as Nx2 array, and radius as a Nx1 array.
##
##   drawCircle(..., NSTEP);
##   Specify the number of edges that will be used to draw the circle.
##   Default value is 72, creating an approximation of one point for each 5
##   degrees.
##
##   drawCircle(..., NAME, VALUE);
##   Specifies plotting options as pair of parameters name/value. See plot
##   documentation for details.
##
##
##   H = drawCircle(...);
##   return handles to each created curve.
##
##   @seealso{circles2d, drawCircleArc, drawEllipse}
## @end deftypefn

function varargout = drawCircle(varargin)

  # process input parameters
  var = varargin{1};
  if size(var, 2) == 1
      x0 = varargin{1};
      y0 = varargin{2};
      r  = varargin{3};
      varargin(1:3) = [];
      
  elseif size(var, 2) == 2
      x0 = var(:,1);
      y0 = var(:,2);
      r  = varargin{2};
      varargin(1:2) = [];
      
  elseif size(var, 2) == 3
      x0 = var(:,1);
      y0 = var(:,2);
      r  = var(:,3);
      varargin(1) = [];
  else
      error('bad format for input in drawCircle');
  end

  # ensure each parameter is column vector
  x0 = x0(:);
  y0 = y0(:);
  r = r(:);

  # default number of discretization steps
  N = 72;

  # check if discretization step is specified
  if ~isempty(varargin)
      var = varargin{1};
      if length(var)==1 && isnumeric(var)
          N = round(var);
          varargin(1) = [];
      end
  end

  # parametrization variable for circle (use N+1 as first point counts twice)
  t = linspace(0, 2*pi, N+1);
  cot = cos(t);
  sit = sin(t);

  # empty array for graphic handles
  h = zeros(size(x0));

  # compute discretization of each circle
  for i = 1:length(x0)
      xt = x0(i) + r(i) * cot;
      yt = y0(i) + r(i) * sit;

      h(i) = plot(xt, yt, varargin{:});
  end

  if nargout > 0
      varargout = {h};
  end

endfunction

