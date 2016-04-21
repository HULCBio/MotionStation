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
## @deftypefn {Function File} {@var{} =} localToGlobal3d (@var{center}, @var{theta},@var{phi},@var{psi})
## Transformation matrix from local to global coordinate system
##
##   TRANS = localToGlobal3d(CENTER, THETA, PHI, PSI)
##   Compute the transformation matrix from a local (or modelling)
##   coordinate system to the global (or world) coordinate system.
##   This is a low-level function, used by several drawing functions.
##
##   The transform is defined by:
##   - CENTER: the position of the local origin into the World coordinate
##       system
##   - THETA: colatitude, defined as the angle with the Oz axis (between 0
##       and 180 degrees), positive in the direction of the of Oy axis.
##   - PHI: azimut, defined as the angle of the normal with the Ox axis,
##       between 0 and 360 degrees
##   - PSI: intrinsic rotation, corresponding to the rotation of the object
##       around the direction vector, between 0 and 360 degrees
##
##   The resulting transform is obtained by applying (in that order):
##   - Rotation by PSI   around he Z-axis
##   - Rotation by THETA around the Y-axis
##   - Rotation by PHI   around the Z-axis
##   - Translation by vector CENTER
##   This corresponds to Euler ZYZ rotation, using angles PHI, THETA and
##   PSI.
##
##   The 'createEulerAnglesRotation' function may better suit your needs as
##   it is more 'natural'.
##
## @seealso{transforms3d, createEulerAnglesRotation}
## @end deftypefn

function trans = localToGlobal3d(varargin)
  ## extract the components of the transform
  if nargin == 1
      ## all components are bundled in  the first argument
      var     = varargin{1};
      center  = var(1:3);
      theta   = var(4);
      phi     = var(5);
      psi     = 0;
      if length(var) > 5
          psi = var(6);
      end
      
  elseif nargin == 4
      ## arguments = center, then the 3 angles
      center  = varargin{1};
      theta   = varargin{2};
      phi     = varargin{3};
      psi     = varargin{4};    
      
  elseif nargin > 4
      ## center is given in 3 arguments, then 3 angles
      center  = [varargin{1} varargin{2} varargin{3}];
      theta   = varargin{4};
      phi     = varargin{5};
      psi     = 0;
      if nargin > 5
          psi = varargin{6};    
      end
  end
      
  ## conversion from degrees to radians
  k = pi / 180;

  ## rotation around normal vector axis
  rot1    = createRotationOz(psi * k);

  ## colatitude
  rot2    = createRotationOy(theta * k);

  ## longitude
  rot3    = createRotationOz(phi * k);

  ## shift center
  tr      = createTranslation3d(center);

  ## create final transform by concatenating transforms
  trans   = tr * rot3 * rot2 * rot1;

endfunction
