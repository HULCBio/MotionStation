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
## @deftypefn {Function File} {@var{pt2} =} planePosition (@var{point}, @var{plane})
## Compute position of a point on a plane
##
##   PT2 = planePosition(POINT, PLANE)
##   POINT has format [X Y Z], and plane has format
##   [X0 Y0 Z0  DX1 DY1 DZ1  DX2 DY2 DZ2], where :
##   - (X0, Y0, Z0) is a point belonging to the plane
##   - (DX1, DY1, DZ1) is a first direction vector
##   - (DX2, DY2, DZ2) is a second direction vector
##
##   Result PT2 has the form [XP YP], with [XP YP] coordinate of the point
##   in the coordinate system of the plane.
##
##
##   CAUTION:
##   WORKS ONLY FOR PLANES WITH ORTHOGONAL DIRECTION VECTORS
##
## @seealso{planes3d, points3d, planePoint}
## @end deftypefn
function pos = planePosition(point, plane)
  # unify size of data
  if size (point, 1) ~= size (plane, 1)
      if size (point, 1) == 1
          point = repmat (point, [size(plane, 1) 1]);
      elseif size (plane, 1) == 1
          plane = repmat (plane, [size(point, 1) 1]);
      else
          error ('point and plane do not have the same dimension');
      end
  end

  p0 = plane(:, 1:3);
  d1 = plane(:, 4:6);
  d2 = plane(:, 7:9);

  s = dot (point-p0, d1, 2) ./ vectorNorm (d1);
  t = dot (point-p0, d2, 2) ./ vectorNorm (d2);

  pos = [s t];

endfunction
