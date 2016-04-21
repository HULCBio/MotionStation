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
## @deftypefn {Function File} {@var{circ} =} intersectPlaneSphere(@var{plane}, @var{sphere})
## Return intersection circle between a plane and a sphere
##
##   Returns the circle which is the intersection of the given plane
##   and sphere.
##   @var{plane}  : [x0 y0 z0  dx1 dy1 dz1  dx2 dy2 dz2]
##   @var{sphere} : [XS YS ZS  RS]
##   @var{circ}   : [XC YC ZC  RC  THETA PHI PSI]
##   [x0 y0 z0] is the origin of the plane, [dx1 dy1 dz1] and [dx2 dy2 dz2]
##   are two direction vectors,
##   [XS YS ZS] are coordinates of the sphere center, RS is the sphere
##   radius,
##   [XC YC ZC] are coordinates of the circle center, RC is the radius of
##   the circle, [THETA PHI] is the normal of the plane containing the
##   circle (THETA being the colatitude, and PHI the azimut), and PSI is a
##   rotation angle around the normal (equal to zero in this function, but
##   kept for compatibility with other functions). All angles are given in
##   degrees.
##
## @seealso{planes3d, spheres, circles3d, intersectLinePlane, intersectLineSphere}
## @end deftypefn

function circle = intersectPlaneSphere(plane, sphere)

  # number of inputs of each type
  Ns = size(sphere, 1);
  Np = size(plane, 1);

  # unify data dimension
  if Ns ~= Np
      if Ns == 1
          sphere = sphere(ones(Np, 1), :);
      elseif Np == 1
          plane = plane(ones(Ns, 1), :);
      else
          error('data should have same length, or one data should have length 1');
      end
  end
  # center of the spheres
  center  = sphere(:,1:3);

  # radius of spheres
  if size(sphere, 2) == 4
      Rs  = sphere(:,4);
  else
      # assume default radius equal to 1
      Rs  = ones(size(sphere, 1), 1);
  end

  # projection of sphere center on plane -> gives circle center
  circle0 = projPointOnPlane(center, plane);

  # radius of circles
  d   = distancePoints (center, circle0);
  Rc  = sqrt(Rs.*Rs - d.*d);

  # normal of planes = normal of circles
  nor = planeNormal(plane);

  # convert to angles
  [theta phi] = cart2sph2(nor(:,1), nor(:,2), nor(:,3));
  psi = zeros(Np, 1);

  # create structure for circle
  k = 180 / pi;
  circle = [circle0 Rc [theta phi psi]*k];

endfunction
