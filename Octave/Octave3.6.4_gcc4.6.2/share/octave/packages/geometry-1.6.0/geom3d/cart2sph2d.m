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
## @deftypefn {Function File} {[@var{theta} @var{phi} @var{rho}] =} cart2sph2d (@var{coord})
## @deftypefnx {Function File} {[@dots{}] =} cart2sph2d (@var{x},@var{y},@var{z})
## Convert cartesian coordinates to spherical coordinates in degrees
##
##   The following convention is used:
##   THETA is the colatitude, in degrees, 0 for north pole, 180 degrees for
##   south pole, 90 degrees for points with z=0.
##   PHI is the azimuth, in degrees, defined as matlab cart2sph: angle from
##   Ox axis, counted counter-clockwise.
##   RHO is the distance of the point to the origin.
##   Discussion on choice for convention can be found at:
##   @url{http://www.physics.oregonstate.edu/bridge/papers/spherical.pdf}
##
##   Example:
## @example
##     cart2sph2d([1 0 0])
##     ans =
##       90   0   1
##
##     cart2sph2d([1 1 0])
##     ans =
##       90   45   1.4142
##
##     cart2sph2d([0 0 1])
##     ans =
##       0    0    1
## @end example
##
## @seealso{angles3d, sph2cart2d, cart2sph, cart2sph2}
## @end deftypefn

function varargout = cart2sph2d(x, y, z)
  # if data are grouped, extract each coordinate
  if nargin == 1
      y = x(:, 2);
      z = x(:, 3);
      x = x(:, 1);
  end

  # cartesian to spherical conversion
  hxy     = hypot(x, y);
  rho     = hypot(hxy, z);
  theta   = 90 - atan2(z, hxy) * 180 / pi;
  phi     = atan2(y, x) * 180 / pi;

  # # convert to degrees and theta to colatitude
  # theta   = 90 - rad2deg(theta);
  # phi     = rad2deg(phi);

  # format output
  if nargout <= 1
      varargout{1} = [theta phi rho];
      
  elseif nargout == 2
      varargout{1} = theta;
      varargout{2} = phi;
      
  else
      varargout{1} = theta;
      varargout{2} = phi;
      varargout{3} = rho;
  end

endfunction
