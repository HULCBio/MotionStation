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
## @deftypefn {Function File} angles3d ()
##ANGLES3D Conventions for manipulating angles in 3D
##
##   Contrary to the plane, there are no oriented angles in 3D. Angles
##   between lines or between planes are comprised between 0 and PI.
##
##   Spherical angles
##   Spherical angles are defined by 2 angles:
##   * THETA, the colatitude, representing angle with Oz axis (between 0 and
##       PI)
##   * PHI, the azimut, representing angle with Ox axis of horizontal
##       projection of the direction (between 0 and 2*PI)
##
##   Spherical coordinates can be represented by THETA, PHI, and the
##   distance RHO to the origin.
##
##   Euler angles
##   Some functions for creating rotations use Euler angles. They follow the
##   ZYX convention in the global reference system, that is eqivalent to the
##   XYZ convention ine a local reference system. 
##   Euler angles are given by a triplet of angles [PHI THETA PSI] that
##   represents the succession of 3 rotations: 
##   * rotation around X by angle PSI    ("roll")
##   * rotation around Y by angle THETA  ("pitch")
##   * rotation around Z by angle PHI    ("yaw")
##
##   In this library, euler angles are given in degrees. The functions that
##   use euler angles use the keyword 'Euler' in their name.
##
##
## @seealso{cart2sph2, sph2cart2, cart2sph2d, sph2cart2d
##   anglePoints3d, angleSort3d, sphericalAngle, randomAngle3d
##   dihedralAngle, polygon3dNormalAngle, eulerAnglesToRotation3d
##   rotation3dAxisAndAngle, rotation3dToEulerAngles}
## @end deftypefn

function angles3d()

  help angles3d

endfunction
