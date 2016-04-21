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
## @deftypefn {Function File} {[@var{theta} @var{phi} @var{rho}] =} cart2sph2([@var{x} @var{y} @var{z}])
## @deftypefnx {Function File} {[@var{theta} @var{phi} @var{rho}] =} cart2sph2(@var{x}, @var{y}, @var{z})
## Convert cartesian coordinates to spherical coordinates
##
##   The following convention is used:
##   @var{theta} is the colatitude, in radians, 0 for north pole, +pi for south
##   pole, pi/2 for points with z=0.
##   @var{phi} is the azimuth, in radians, defined as matlab cart2sph: angle from
##   Ox axis, counted counter-clockwise.
##   @var{rho} is the distance of the point to the origin.
##   Discussion on choice for convention can be found at:
##   @url{http://www.physics.oregonstate.edu/bridge/papers/spherical.pdf}
##
##   Example:
## @example
##   cart2sph2([1 0 0])  returns [pi/2 0 1];
##   cart2sph2([1 1 0])  returns [pi/2 pi/4 sqrt(2)];
##   cart2sph2([0 0 1])  returns [0 0 1];
## @end example
##
## @seealso{angles3d, sph2cart2, cart2sph, cart2sph2d}
## @end deftypefn

function varargout = cart2sph2(varargin)

  if length(varargin)==1
      var = varargin{1};
  elseif length(varargin)==3
      var = [varargin{1} varargin{2} varargin{3}];
  end

  if size(var, 2)==2
      var(:,3)=1;
  end

  [p t r] = cart2sph(var(:,1), var(:,2), var(:,3));

  if nargout == 1 || nargout == 0
      varargout{1} = [pi/2-t p r];
  elseif nargout==2
      varargout{1} = pi/2-t;
      varargout{2} = p;
  else
      varargout{1} = pi/2-t;
      varargout{2} = p;
      varargout{3} = r;
  end

endfunction
