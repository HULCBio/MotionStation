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
## @deftypefn {Function File} drawBezierCurve (@var{points})
## @deftypefnx {Function File} drawBezierCurve (@var{pp})
## @deftypefnx {Function File} drawBezierCurve (@dots{}, @var{param}, @var{value}, @dots{})
## @deftypefnx {Function File} {@var{h} =}drawBezierCurve (@dots{})
## Draw a cubic bezier curve defined by the control points @var{points}.
##
## With only one input argument, draws the Bezier curve defined by the 4 control
## points stored in @var{points}. @var{points} is either a 4-by-2 array
## (vertical concatenation of point coordinates), or a 1-by-8 array (horizotnal
## concatenation of point coordinates). The curve could be described by its
## polynomial (output of @code{cbezier2poly}) @var{pp}, which should be a 2-by-4
## array.
##
## The optional @var{param}, @var{value} pairs specify additional drawing
## parameters, see the @code{plot} function for details. The specific parameter
## 'discretization' with an integer associated value defines the amount of
## points used to plot the curve. If the output is requiered, the function
## returns the handle to the created graphic object.
##
## @seealso{cbezier2poly, plot}
## @end deftypefn

function varargout = drawBezierCurve(points, varargin)

  # default number of discretization steps
  N = 64;

  # check if discretization step is specified
  if ~isempty(varargin)
      [tf idx] = ismember ({'discretization'},{varargin{1:2:end}});
      if ~isempty(idx)
        N = varargin{idx+1};
        varargin(idx:idx+1) = [];
      end
  end

  # parametrization variable for bezier (use N+1 points to have N edges)
  t = linspace(0, 1, N+1);
  
  if any(size(points) ~= [2 4])
    [x y] = cbezier2poly(points,t);
  else
    # Got a polynomial description
    x = polyval(points(1,:),t);
    y = polyval(points(2,:),t);
  end
  
  # draw the curve
  h = plot(x, y, varargin{:});

  # eventually return a handle to the created object
  if nargout > 0
      varargout = {h};
  end
endfunction

%!demo
%! points = [0 0; 3 1; -2 1; 1 0];
%! drawBezierCurve(points);
%! hold on
%! plot(points([1 4],1),points([1 4],2),'go');
%! plot(points([2 3],1),points([2 3],2),'rs');
%! line(points([1 2],1),points([1 2],2),'color','k');
%! line(points([3 4],1),points([3 4],2),'color','k');
%! h = drawBezierCurve(points, 'discretization', 6, 'color','r');
%! hold off

%!shared p
%! p = [0 0; 3 1; -2 1; 1 0];
%!error(drawBezier())
%!error(drawBezier ('discretization'))
%!error(drawBezier (p, 'discretization', 'a'))
%!error(drawBezier (p(:)))
