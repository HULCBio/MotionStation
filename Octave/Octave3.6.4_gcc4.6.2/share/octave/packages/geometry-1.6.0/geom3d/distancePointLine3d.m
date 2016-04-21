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
## @deftypefn {Function File} {@var{d} =} distancePointLine3d (@var{point}, @var{line})
## Euclidean distance between 3D point and line
##
##   Returns the distance between point POINT and the line LINE, given as:
##   POINT : [x0 y0 z0]
##   LINE  : [x0 y0 z0 dx dy dz]
##   D     : (positive) scalar
##
##   Run @command{demo distancePointLine3d} to see examples.
##
##   References
##   http://mathworld.wolfram.com/Point-LineDistance3-Dimensional.html
##
## @seealso{lines3d, distancePointLine, distancePointEdge3d, projPointOnLine3d}
## @end deftypefn

function d = distancePointLine3d(point, lin)

  [np nd]  = size (point);
  [nl ndl] = size (lin);

  if ndl < 4
    error("geometry:InvalidInput","second argument must be a line. See lines3d.");
  end

  # Compare everything to everything
  if np != nl
    # Order the lines such that all points are compared against 1st line, then
    # secoind and so on. --JPi
    idx = reshape (1:np*nl,nl,np)'(:);
    lin   = repmat (lin, np, 1)(idx,:);
    point = repmat (point, nl, 1);
  end

  d = vectorNorm ( cross ( lin(:,4:6), lin(:,1:3)-point, 2)) ./ ...
                                                       vectorNorm (lin(:,4:6));

endfunction

%!demo
%! point = [0 0 1];
%! lin   = [0 0 0 1 1 1];
%! d     = distancePointLine3d (point,lin);
%!
%! # Orthogonal and Parallel projectors
%! dl = normalizeVector (lin(4:end))';
%! V  = dl*dl';
%! P  = eye(3)  - dl*dl';
%! pv = P*point';
%! vv = V*point';
%!
%! # Compare
%! disp([d vectorNorm(pv)])
%!
%! figure(1);
%! clf
%! plot3 (point(1),point(2),point(3),'.k');
%! line ([0 point(1)],[0 point(2)],[0 point(3)],'color','k');
%! line (dl(1)*[-2 2],dl(2)*[-2 2],dl(3)*[-2 2],'color','r');
%! line ([0 vv(1)],[0 vv(2)],[0 vv(3)],'color','g');
%! line (vv(1)+[0 pv(1)],vv(2)+[0 pv(2)],vv(3)+[0 pv(3)],'color','b');
%! axis square equal
%!
%! # -------------------------------------------------------------------------
%! # Distance between a line and a point, the distance is verified against the
%! # vector form the point to the line, orthogonal to the line.

%!demo
%! point = 2*rand(4,3)-1;
%! lin   = [0 0 0 1 1 1; 0 0 0 1 1 0];
%! d     = distancePointLine3d (point,lin)
%!
%! # Organize as matrix point vs lines
%! reshape (d,4,2)
%!
%! # -------------------------------------------------------------------------
%! # Distance between 4 points and two lines. The result can be arrange as a
%! # distance matrix.
