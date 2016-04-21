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
## @deftypefn {Function File} {@var{line} = } medianLine (@var{p1}, @var{p2})
## @deftypefnx {Function File} {@var{line} = } medianLine (@var{pts})
## @deftypefnx {Function File} {@var{line} = } medianLine (@var{edge})
## Create a median line between two points.
##
##   Create the median line of points @var{p1} and @var{p2}, that is the line containing
##   all points located at equal distance of @var{p1} and @var{p2}.
##
##   Creates the median line of 2 points, given as a 2*2 array @var{pts}. Array has
##   the form:
##   [ [ x1 y1 ] ; [ x2 y2 ] ]
##
##   Creates the median of the @var{edge}. @var{edge} is a 1*4 array, containing [X1 Y1]
##   coordinates of first point, and [X2 Y2], the coordinates of the second
##   point.
##
##   Example
##
##  @example
##   # Draw the median line of two points
##     P1 = [10 20];
##     P2 = [30 50];
##     med = medianLine(P1, P2);
##     figure; axis square; axis([0 100 0 100]);
##     drawEdge([P1 P2], 'linewidth', 2, 'color', 'k');
##     drawLine(med)
##
##   # Draw the median line of an edge
##     P1 = [50 60];
##     P2 = [80 30];
##     edge = createEdge(P1, P2);
##     figure; axis square; axis([0 100 0 100]);
##     drawEdge(edge, 'linewidth', 2)
##     med = medianLine(edge);
##     drawLine(med)
## @end example
##
##   @seealso{lines2d, createLine, orthogonalLine}
## @end deftypefn

function lin = medianLine(varargin)

  nargs = length(varargin);
  x0 = 0;
  y0 = 0;
  dx = 0;
  dy = 0;

  if nargs == 1
      tab = varargin{1};
      if size(tab, 2)==2
          # input is an array of two points
          x0 = tab(1,1);
          y0 = tab(1,2);
          dx = tab(2,1)-x0;
          dy = tab(2,2)-y0;
      else
          # input is an edge
          x0 = tab(:, 1);
          y0 = tab(:, 2);
          dx = tab(:, 3) - tab(:, 1);
          dy = tab(:, 4) - tab(:, 2);
      end

  elseif nargs==2
      # input is given as two points, or two point arrays
      p1 = varargin{1};
      p2 = varargin{2};
      x0 = p1(:, 1);
      y0 = p1(:, 2);
      dx = bsxfun(@minus, p2(:, 1), x0);
      dy = bsxfun(@minus, p2(:, 2), y0);

  else
      error('Too many input arguments');
  end

  # compute median using middle point of the edge, and the direction vector
  # rotated by 90 degrees counter-clockwise
  lin = [bsxfun(@plus, x0, dx/2), bsxfun(@plus, y0, dy/2), -dy, dx];

endfunction

%!shared privpath
%! privpath = [fileparts(which('geom2d_Contents')) filesep() 'private'];

%!test
%!  addpath (privpath,'-end')
%!  p1 = [0 0];
%!  p2 = [10 0];
%!  exp = [5 0 0 10];
%!  lin = medianLine(p1, p2);
%!  assertElementsAlmostEqual(exp, lin);
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  p1 = [0 0];
%!  p2 = [10 0];
%!  exp = [5 0 0 10];
%!  lin = medianLine([p1 p2]);
%!  assertElementsAlmostEqual(exp, lin);
%!  rmpath (privpath);

%!test
%!  addpath (privpath,'-end')
%!  p1 = [0 0; 10 10];
%!  p2 = [10 0;10 20];
%!  exp = [5 0 0 10; 10 15 -10 0];
%!  lin = medianLine(p1, p2);
%!  assertElementsAlmostEqual(exp, lin);
%!  rmpath (privpath);
