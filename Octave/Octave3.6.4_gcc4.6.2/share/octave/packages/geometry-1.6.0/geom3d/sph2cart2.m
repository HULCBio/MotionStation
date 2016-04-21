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
## @deftypefn {Function File} {@var{c} =} sph2cart2 (@var{s})
## @deftypefnx {Function File} {@var{c} =} sph2cart2 (@var{theta}, @var{phi})
## @deftypefnx {Function File} {@var{c} =} sph2cart2 (@var{theta}, @var{phi}, @var{rho})
## @deftypefnx {Function File} {[@var{x} @var{y} @var{z}]=} sph2cart2 (@dots{})
## Convert spherical coordinates to cartesian coordinates
##
##   C = SPH2CART2(S)
##   C = SPH2CART2(THETA, PHI)       (assume rho = 1)
##   C = SPH2CART2(THETA, PHI, RHO)
##   [X, Y, Z] = SPH2CART2(THETA, PHI, RHO);
##
##   S = [phi theta rho] (spherical coordinate).
##   C = [X Y Z]  (cartesian coordinate)
##
##   The following convention is used:
##   THETA is the colatitude, in radians, 0 for north pole, +pi for south
##   pole, pi/2 for points with z=0.
##   PHI is the azimuth, in radians, defined as matlab cart2sph: angle from
##   Ox axis, counted counter-clockwise.
##   RHO is the distance of the point to the origin.
##   Discussion on choice for convention can be found at:
##   http://www.physics.oregonstate.edu/bridge/papers/spherical.pdf
##
## @seealso{angles3d, cart2sph2, sph2cart, sph2cart2d}
## @end deftypefn

function varargout = sph2cart2(theta, phi, rho)
  # Process input arguments
  if nargin == 1

    phi = theta(:, 2);
    if size (theta, 2) > 2
      rho = theta(:, 3);
    else
      rho = ones (size (phi));
    end
    theta = theta(:, 1);

  elseif nargin == 2
      rho = ones (size (theta));
  end

  # conversion
  rz = rho .* sin(theta);
  x  = rz  .* cos(phi);
  y  = rz  .* sin(phi);
  z  = rho .* cos(theta);

  if nargout <= 1
    varargout{1} = [x, y, z];
  else
    varargout{1} = x;
    varargout{2} = y;
    varargout{3} = z;
  end

endfunction
