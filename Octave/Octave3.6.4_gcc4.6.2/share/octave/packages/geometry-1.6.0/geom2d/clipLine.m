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
## @deftypefn {Function File} {@var{edge} =} clipLine (@var{line}, @var{box})
## Clip a line with a box.
## 
##   @var{line} is a straight line given as a 4 element row vector: [x0 y0 dx dy],
##   with (x0 y0) being a point of the line and (dx dy) a direction vector,
##   @var{box} is the clipping box, given by its extreme coordinates: 
##   [xmin xmax ymin ymax].
##   The result is given as an edge, defined by the coordinates of its 2
##   extreme points: [x1 y1 x2 y2].
##   If line does not intersect the box, [NaN NaN NaN NaN] is returned.
##   
##   Function works also if @var{line} is a Nx4 array, if @var{box} is a Nx4 array, or
##   if both @var{line} and @var{box} are Nx4 arrays. In these cases, @var{edge} is a Nx4
##   array.
##
##   Example:
##
## @example
##   line = [30 40 10 0];
##   box = [0 100 0 100];
##   res = clipLine(line, box)
##   res = 
##       0 40 100 40
## @end example
##
## @seealso{lines2d, boxes2d, edges2d, clipEdge, clipRay}
## @end deftypefn

function edge = clipLine(lin, bb, varargin)

  # adjust size of two input arguments
  if size(lin, 1)==1
      lin = repmat(lin, size(bb, 1), 1);
  elseif size(bb, 1)==1
      bb = repmat(bb, size(lin, 1), 1);
  elseif size(lin, 1) ~= size(bb, 1)
      error('bad sizes for input');
  end

  # allocate memory
  nbLines = size(lin, 1);
  edge    = zeros(nbLines, 4);

  # main loop on lines
  for i=1:nbLines
      # extract limits of the box
      xmin = bb(i, 1);
      xmax = bb(i, 2);
      ymin = bb(i, 3);
      ymax = bb(i, 4);
      
      # use direction vector for box edges similar to direction vector of the
      # line in order to reduce computation errors
      delta = hypot(lin(i,3), lin(i,4));
      
      
	  # compute intersection with each edge of the box
      
      # lower edge
	  px1 = intersectLines(lin(i,:), [xmin ymin delta 0]);
      # right edge
	  px2 = intersectLines(lin(i,:), [xmax ymin 0 delta]);
      # upper edge
	  py1 = intersectLines(lin(i,:), [xmax ymax -delta 0]);
      # left edge
	  py2 = intersectLines(lin(i,:), [xmin ymax 0 -delta]);
      
      # remove undefined intersections (case of lines parallel to box edges)
      points = [px1 ; px2 ; py1 ; py2];
      points = points(isfinite(points(:,1)), :);
	
      # sort points according to their position on the line
      pos = linePosition(points, lin(i,:));
      [pos inds] = sort(pos); ##ok<ASGLU>
      points = points(inds, :);
      
      # create clipped edge by using the two points in the middle
      ind = size(points, 1)/2;
      inter1 = points(ind,:);
      inter2 = points(ind+1,:);
      edge(i, 1:4) = [inter1 inter2];
      
      # check that middle point of the edge is contained in the box
      midX = mean(edge(i, [1 3]));
      xOk = xmin <= midX && midX <= xmax;
      midY = mean(edge(i, [2 4]));
      yOk = ymin <= midY && midY <= ymax;
      
      # if one of the bounding condition is not met, set edge to NaN
      if ~(xOk && yOk)
          edge (i,:) = NaN;
      end
  end
endfunction

%!demo
%!   lin = [30 40 10 0];
%!   bb = [0 100 0 100];
%!   res = clipLine(lin, bb)
%!
%! drawBox(bb,'color','k');
%! line(lin([1 3]),lin([2 4]),'color','b');
%! line(res([1 3]),res([2 4]),'color','r','linewidth',2);
%! axis tight
%! v = axis ();
%! axis(v+[0 10 -10 0])

%!test # inside, to the right # inside, to the left# outside
%! bb = [0 100 0 100];
%! lin = [30 40 10 0];
%! edge = [0 40 100 40];
%! assert (edge, clipLine(lin, bb), 1e-6);
%! lin = [30 40 -10 0];
%! edge = [100 40 0 40];
%! assert (edge, clipLine(lin, bb), 1e-6);
%! lin = [30 140 10 0];
%! assert (sum(isnan(clipLine(lin, bb)))==4);

%!test # inside, upward # inside, downward # outside
%!  bb = [0 100 0 100];
%!  lin = [30 40 0 10];
%!  edge = [30 0 30 100];
%!  assert (edge, clipLine(lin, bb), 1e-6);
%!  lin = [30 40 0 -10];
%!  edge = [30 100 30 0];
%!  assert (edge, clipLine(lin, bb), 1e-6);
%!  lin = [140 30 0 10];
%!  assert (sum(isnan(clipLine(lin, bb)))==4);

%!test # inside, top right corner# inside, down right corner # outside
%!  bb = [0 100 0 100];
%!  lin = [80 30 10 10];
%!  edge = [50 0 100 50];
%!  assert (edge, clipLine(lin, bb), 1e-6);
%!  lin = [20 70 10 10];
%!  edge = [0 50 50 100];
%!  assert (edge, clipLine(lin, bb), 1e-6);
%!  lin = [140 -30 10 10];
%!  assert (sum(isnan(clipLine(lin, bb)))==4);
%!  lin = [-40 130 10 10];
%!  assert (sum(isnan(clipLine(lin, bb)))==4);

%!test #multilines # inside, top right corner
%!  bb = [0 100 0 100];
%!  lin = [...
%!      80 30 10 10; ...
%!      20 70 10 10; ...
%!      140 -30 10 10; ...
%!      -40 130 10 10];
%!  edge = [...
%!      50 0 100 50; ...
%!      0 50 50 100; ...
%!      NaN NaN NaN NaN; ...
%!      NaN NaN NaN NaN; ...
%!      ];
%!  clipped = clipLine(lin, bb);
%!  assert (4, size(clipped, 1));
%!  assert (edge(1:2, :), clipped(1:2, :), 1e-6);
%!  assert (sum(isnan(clipped(3,:)))==4);
%!  assert (sum(isnan(clipped(4,:)))==4);

%!test # test clipping of horizontal lines # inside, to the right
%!  bb = [-1 1 -1 1]*1e10;
%!  lin = [3 0 1 2];
%!  D = 1e10;
%!  edge = [3-D/2 -D 3+D/2 D];
%!  clipped = clipLine(lin, bb);
%!  assert (edge, clipped);

%!test # inside, to the right
%!  bb = [-1 1 -1 1]*100;
%!  lin = [3 0 1*1e10 2*1e10];
%!  D = 100;
%!  edge = [3-D/2 -D 3+D/2 D];
%!  clipped = clipLine(lin, bb);
%!  assert (edge, clipped, 1e-6);
