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
## @deftypefn {Function File} {@var{pos} =} circle3dPosition(@var{point}, @var{circle})
## Return the angular position of a point on a 3D circle
##
##   Returns angular position of point on the circle, in degrees, between 0
##   and 360.
##   with @var{point}: [xp yp zp]
##   and @var{circle}: [X0 Y0 Z0 R THETA PHI] or [X0 Y0 Z0 R THETA PHI PSI]
##   (THETA being the colatitude, and PHI the azimut)
##
## @seealso{circles3d, circle3dOrigin, circle3dPoint}
## @end deftypefn

function theta = circle3dPosition(point, circle)

  # get center and radius
  xc = circle(:,1);
  yc = circle(:,2);
  zc = circle(:,3);

  # get angle of normal
  theta   = circle(:,5);
  phi     = circle(:,6);

  # find origin of the circle
  ori     = circle3dOrigin(circle);

  # normal vector of the supporting plane (cartesian coords)
  vn      = sph2cart2d([theta phi]);

  # create plane containing the circle
  plane   = createPlane([xc yc zc], vn);

  # find position of point on the circle plane
  pp0     = planePosition(ori,    plane);
  pp      = planePosition(point,  plane);

  # compute angles in the planes
  theta0  = mod(atan2(pp0(:,2), pp0(:,1)) + 2*pi, 2*pi);
  theta   = mod(atan2(pp(:,2), pp(:,1)) + 2*pi - theta0, 2*pi);

  # convert to degrees
  theta = theta * 180 / pi;

endfunction
