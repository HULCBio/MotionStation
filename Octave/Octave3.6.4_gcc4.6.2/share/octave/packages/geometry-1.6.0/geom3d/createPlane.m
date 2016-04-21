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
## @deftypefn {Function File} {@var{PLANE} =} createPlane (@var{pts})
## @deftypefnx {Function File} {@var{PLANE} =} createPlane (@var{p0}, @var{n})
## @deftypefnx {Function File} {@var{PLANE} =} createPlane (@var{p1}, @var{p2}, @var{p3})
## Create a plane in parametrized form
##
##   PLANE = createPlane(PTS)
##   The 3 points are packed into a single 3x3 array.
##
##   PLANE = createPlane(P0, N);
##   Creates a plane from a point and from a normal to the plane. The
##   parameter N is given either as a 3D vector (1-by-3 row vector), or as
##   [THETA PHI], where THETA is the colatitute (angle with the vertical
##   axis) and PHI is angle with Ox axis, counted counter-clockwise (both
##   given in radians).
##
##   PLANE = createPlane(P1, P2, P3)
##   creates a plane containing the 3 points
##
##   The created plane data has the following format:
##   PLANE = [X0 Y0 Z0  DX1 DY1 DZ1  DX2 DY2 DZ2], with
##   - (X0, Y0, Z0) is a point belonging to the plane
##   - (DX1, DY1, DZ1) is a first direction vector
##   - (DX2, DY2, DZ2) is a second direction vector
##   The 2 direction vectors are normalized and orthogonal.
##
## @seealso{planes3d, medianPlane}
## @end deftypefn

## TODO: return closet plane when dim(PTS,1) > 3
function plane = createPlane(varargin)

  if length (varargin) == 1
      var = varargin{1};

      if iscell (var)
          plane = zeros ([length (var) 9]);
          for i=1:length (var)
              plane(i,:) = createPlane (var{i});
          end
      elseif size (var, 1) >= 3
          # 3 points in a single array
          p1 = var(1,:);
          p2 = var(2,:);
          p3 = var(3,:);

          # create direction vectors
          v1 = p2 - p1;
          v2 = p3 - p1;

          # create plane
          plane = normalizePlane ([p1 v1 v2]);
          return;
      end

  elseif length (varargin) == 2
      # plane origin
      p0 = varargin{1};

      # second parameter is either a 3D vector or a 3D angle (2 params)
      var = varargin{2};
      if size (var, 2) == 2
          # normal is given in spherical coordinates
          n = sph2cart2 ([var ones(size(var, 1))]);
      elseif size (var, 2)==3
          # normal is given by a 3D vector
          n = normalizeVector (var);
      else
          error ('wrong number of parameters in createPlane');
      end

      # ensure same dimension for parameters
      if size (p0, 1)==1
          p0 = repmat (p0, [size(n, 1) 1]);
      end
      if size(n, 1)==1
          n = repmat (n, [size(p0, 1) 1]);
      end

      # find a vector not colinear to the normal
      v0 = repmat ([1 0 0], [size(p0, 1) 1]);
      inds = vectorNorm (cross (n, v0, 2)) < 1e-14;
      v0(inds, :) = repmat ([0 1 0], [sum(inds) 1]);

  #     if abs(cross(n, v0, 2))<1e-14
  #         v0 = repmat([0 1 0], [size(p0, 1) 1]);
  #     end

      # create direction vectors
      v1 = normalizeVector (cross (n, v0, 2));
      v2 = -normalizeVector (cross (v1, n, 2));

      # concatenate result in the array representing the plane
      plane = [p0 v1 v2];
      return;

  elseif length (varargin)==3
      p1 = varargin{1};
      p2 = varargin{2};
      p3 = varargin{3};

      # create direction vectors
      v1 = p2 - p1;
      v2 = p3 - p1;

      plane = normalizePlane ([p1 v1 v2]);
      return;

  else
      error ('Wrong number of arguments in "createPlane".');
  end

endfunction
