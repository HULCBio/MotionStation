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
## @deftypefn {Function File} {@var{box} =} boundingBox3d (@var{points})
## Bounding box of a set of 3D points
##
##   Returns the bounding box of the set of points POINTS. POINTS is a
##   N-by-3 array containing points coordinates. The result BOX is a 1-by-6 
##   array, containing:
##   [XMIN XMAX YMIN YMAX ZMIN ZMAX]
##
##   Example
## @group
##   # Draw bounding box of a cubeoctehedron
##     [v e f] = createCubeOctahedron;
##     box3d = boundingBox3d(v);
##     figure; hold on;
##     drawMesh(v, f);
##     drawBox3d(box3d);
##     axis([-2 2 -2 2 -2 2]);
##     view(3)
## @end group
##
## @seealso{boxes3d, drawBox3d}
## @end deftypefn

function box = boundingBox3d(points)

  # compute extreme x and y values
  xmin = min(points(:,1));
  xmax = max(points(:,1));
  ymin = min(points(:,2));
  ymax = max(points(:,2));
  box = [xmin xmax ymin ymax];

  # process case of 3D points
  if size(points, 2) > 2
      zmin = min(points(:,3));
      zmax = max(points(:,3));
      box = [xmin xmax ymin ymax zmin zmax];
  end

endfunction

%!demo
%!  # Draw bounding box of a cubeoctehedron
%!   [v e f] = createCubeOctahedron;
%!   box3d = boundingBox3d(v);
%!   figure; hold on;
%!   drawMesh(v, f);
%!   drawBox3d(box3d);
%!   axis([-2 2 -2 2 -2 2]);
%!   view(3)

