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
## @deftypefn {Function File} {@var{area} =} polygonArea3d(@var{poly})
## Area of a 3D polygon
##
## @var{poly} is given as a N-by-3 array of vertex coordinates. The resulting
## area is positive.
##
## Example
## @example
## poly = [10 30 20;20 30 20;20 40 20;10 40 20];
## polygonArea3d(poly)
## ans =
##    100
## @end example
##
## @seealso{polygons3d, triangleArea3d, polygonArea, polygonCentroid3d}
## @end deftypefn

function area = polygonArea3d(poly)

  # put the first vertex at origin (reducing computation errors for polygons
  # far from origin)
  v0    = poly (1, :);
  poly -= v0;

  # indices of next vertices
  N     = size (poly, 1);
  iNext = [2:N 1];

  # compute area (vectorized version)
  # need to compute the sign explicitely, as the norm of the cross product
  # does not keep orientation within supporting plane.
  cp     = cross (poly, poly(iNext,:), 2);
  sign_i = sign (cp*cp(2,:)');
  area_i = vectorNorm(cp) .* sign_i;

  # sum up individual triangles area
  area = sum(area_i) / 2;

endfunction

%!demo
%! poly = [10 30 20;20 30 20;20 40 20;10 40 20];
%! polygonArea3d(poly)

%!demo
%! l=0.25;
%! # Corner Triangle with a wedge
%! poly = [1 0 0; ...
%!        ([1 0 0]+l*[-1 1 0]); ...
%!        mean(eye(3)); ...
%!        ([1 0 0]+(1-l)*[-1 1 0]); ...
%!        0 1 0; ...
%!        0 0 1];
%!
%! polygonArea3d(poly)
%!
%! # Is the same as
%! p1 = [1 0 0; 0 1 0; 0 0 1]; # Corner
%! p2 = [([1 0 0]+l*[-1 1 0]); ([1 0 0]+(1-l)*[-1 1 0]); mean(eye(3))]; # Wedge
%!
%! polygonArea3d(p1)-polygonArea3d(p2)
