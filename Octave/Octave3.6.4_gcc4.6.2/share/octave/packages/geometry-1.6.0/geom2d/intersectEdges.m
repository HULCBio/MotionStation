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
## @deftypefn {Function File} {@var{point} = } intersectEdges (@var{edge1}, @var{edge2})
## Return all intersections between two set of edges
##
##   P = intersectEdges(E1, E2);
##   returns the intersection point of lines L1 and L2. E1 and E2 are 1-by-4
##   arrays, containing parametric representation of each edge (in the form
##   [x1 y1 x2 y2], see 'createEdge' for details).
##   
##   In case of colinear edges, returns [Inf Inf].
##   In case of parallel but not colinear edges, returns [NaN NaN].
##
##   If each input is [N*4] array, the result is a [N*2] array containing
##   intersections of each couple of edges.
##   If one of the input has N rows and the other 1 row, the result is a
##   [N*2] array.
##
##   @seealso{edges2d, intersectLines}
## @end deftypefn

function point = intersectEdges(edge1, edge2)
  ## Initialisations

  # ensure input arrays are same size
  N1  = size(edge1, 1);
  N2  = size(edge2, 1);

  # ensure input have same size
  if N1~=N2
      if N1==1
          edge1 = repmat(edge1, [N2 1]);
          N1 = N2;
      elseif N2==1
          edge2 = repmat(edge2, [N1 1]);
      end
  end

  # tolerance for precision
  tol = 1e-14;

  # initialize result array
  x0  = zeros(N1, 1);
  y0  = zeros(N1, 1);


  ## Detect parallel and colinear cases

  # indices of parallel edges
  #par = abs(dx1.*dy2 - dx1.*dy2)<tol;
  par = isParallel(edge1(:,3:4)-edge1(:,1:2), edge2(:,3:4)-edge2(:,1:2));

  # indices of colinear edges
  # equivalent to: |(x2-x1)*dy1 - (y2-y1)*dx1| < eps
  col = abs(  (edge2(:,1)-edge1(:,1)).*(edge1(:,4)-edge1(:,2)) - ...
              (edge2(:,2)-edge1(:,2)).*(edge1(:,3)-edge1(:,1)) )<tol & par;

  # Parallel edges have no intersection -> return [NaN NaN]
  x0(par & ~col) = NaN;
  y0(par & ~col) = NaN;


  ## Process colinear edges

  # colinear edges may have 0, 1 or infinite intersection
  # Discrimnation based on position of edge2 vertices on edge1
  if sum(col)>0
      # array for storing results of colinear edges
      resCol = Inf*ones(size(col));

      # compute position of edge2 vertices wrt edge1
      t1 = edgePosition(edge2(col, 1:2), edge1(col, :));
      t2 = edgePosition(edge2(col, 3:4), edge1(col, :));
      
      # control location of vertices: we want t1<t2
      if t1>t2
          tmp = t1;
          t1  = t2;
          t2  = tmp;
      end
      
      # edge totally before first vertex or totally after last vertex
      resCol(col(t2<-eps))  = NaN;
      resCol(col(t1>1+eps)) = NaN;
          
      # set up result into point coordinate
      x0(col) = resCol;
      y0(col) = resCol;
      
      # touches on first point of first edge
      touch = col(abs(t2)<1e-14);
      x0(touch) = edge1(touch, 1);
      y0(touch) = edge1(touch, 2);

      # touches on second point of first edge
      touch = col(abs(t1-1)<1e-14);
      x0(touch) = edge1(touch, 3);
      y0(touch) = edge1(touch, 4);
  end


  ## Process non parallel cases

  # process intersecting edges whose interecting lines intersect
  i = find(~par);

  # use a test to avoid process empty arrays
  if sum(i)>0
      # extract base parameters of supporting lines for non-parallel edges
      x1  = edge1(i,1);
      y1  = edge1(i,2);
      dx1 = edge1(i,3)-x1;
      dy1 = edge1(i,4)-y1;
      x2  = edge2(i,1);
      y2  = edge2(i,2);
      dx2 = edge2(i,3)-x2;
      dy2 = edge2(i,4)-y2;

      # compute intersection points of supporting lines
      delta = (dx2.*dy1-dx1.*dy2);
      x0(i) = ((y2-y1).*dx1.*dx2 + x1.*dy1.*dx2 - x2.*dy2.*dx1) ./ delta;
      y0(i) = ((x2-x1).*dy1.*dy2 + y1.*dx1.*dy2 - y2.*dx2.*dy1) ./ -delta;
          
      # compute position of intersection points on each edge
      # t1 is position on edge1, t2 is position on edge2
      t1  = ((y0(i)-y1).*dy1 + (x0(i)-x1).*dx1) ./ (dx1.*dx1+dy1.*dy1);
      t2  = ((y0(i)-y2).*dy2 + (x0(i)-x2).*dx2) ./ (dx2.*dx2+dy2.*dy2);

      # check position of points on edges.
      # it should be comprised between 0 and 1 for both t1 and t2.
      # if not, the edges do not intersect
      out = t1<-tol | t1>1+tol | t2<-tol | t2>1+tol;
      x0(i(out)) = NaN;
      y0(i(out)) = NaN;
  end


  ## format output arguments

  point = [x0 y0];

endfunction

