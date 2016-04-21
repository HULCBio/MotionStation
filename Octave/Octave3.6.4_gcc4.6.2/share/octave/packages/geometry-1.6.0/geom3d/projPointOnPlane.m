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
## @deftypefn {Function File} {@var{pt2} =} projPointOnPlane (@var{pt1}, @var{plane})
## Return the orthogonal projection of a point on a plane
##
##   PT2 = projPointOnPlane(PT1, PLANE);
##   Compute the (orthogonal) projection of point PT1 onto the line PLANE.
##   
##   Function works also for multiple points and planes. In this case, it
##   returns multiple points.
##   Point PT1 is a [N*3] array, and PLANE is a [N*9] array (see createPlane
##   for details). Result PT2 is a [N*3] array, containing coordinates of
##   orthogonal projections of PT1 onto planes PLANE.
##
## @seealso{planes3d, points3d, planePosition, intersectLinePlane}
## @end deftypefn

function point = projPointOnPlane (point, plane)

  if size (point, 1)==1
      point = repmat (point, [size(plane, 1) 1]);
  elseif size (plane, 1)==1
      plane = repmat (plane, [size(point, 1) 1]);
  elseif size (plane, 1) ~= size (point, 1)
      error ('projPointOnPlane: size of inputs differ');
  end

  n = planeNormal (plane);
  line = [point n];
  point = intersectLinePlane (line, plane);

endfunction
