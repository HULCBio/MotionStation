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
## @deftypefn {Function File} {@var{plane2} =} normalizePlane (@var{plane1})
## Normalize parametric representation of a plane
##
##   PLANE2 = normalizePlane(PLANE1);
##   Transforms the plane PLANE1 in the following format:
##   [X0 Y0 Z0  DX1 DY1 DZ1  DX2 DY2 DZ2], where:
##   - (X0, Y0, Z0) is a point belonging to the plane
##   - (DX1, DY1, DZ1) is a first direction vector
##   - (DX2, DY2, DZ2) is a second direction vector
##   into another plane, with the same format, but with:
##   - (x0 y0 z0) is the closest point of plane to the origin
##   - (DX1 DY1 DZ1) has norm equal to 1
##   - (DX2 DY2 DZ2) has norm equal to 1 and is orthogonal to (DX1 DY1 DZ1)
##   
## @seealso{planes3d, createPlane}
## @end deftypefn

function plane2 = normalizePlane (plane1)

  # compute first direction vector
  d1  = normalizeVector (plane1(:,4:6));

  # compute second direction vector
  n   = normalizeVector (planeNormal (plane1));
  d2  = -normalizeVector (cross (d1, n));

  # compute origin point of the plane
  origins = repmat ([0 0 0], [size(plane1, 1) 1]);
  p0 = projPointOnPlane (origins, [plane1(:,1:3) d1 d2]);

  # create the resulting plane
  plane2 = [p0 d1 d2];

endfunction
