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
## @deftypefn {Function File} {@var{pts2} =} angleSort3d (@var{pts})
## @deftypefnx {Function File} {@var{pts2} =} angleSort3d (@var{pts},@var{pts0})
## @deftypefnx {Function File} {@var{pts2} =} angleSort3d (@var{pts},@var{pts0},@var{pts1})
## @deftypefnx {Function File} {[@var{pts2} @var{i}]=} angleSort3d (@dots{})
## Sort 3D coplanar points according to their angles in plane
##
##   @var{pts2} = angleSort3d(@var{pts});
##   Considers all points are located on the same plane, and sort them
##   according to the angle on plane. @var{pts} is a [Nx2] array. Note that the
##   result depend on plane orientation: points can be in reverse order
##   compared to expected. The reference plane is computed besed on the 3
##   first points.
##
##   @var{pts2} = angleSort3d(@var{pts}, @var{pts0});
##   Computes angles between each point of @var{pts} and PT0. By default, uses
##   centroid of points.
##
##   @var{pts2} = angleSort3d(@var{pts}, @var{pts0}, @var{pts1});
##   Specifies the point which will be used as a start.
##
##   [@var{pts2}, @var{i}] = angleSort3d(...);
##   Also return in @var{i} the indices of @var{pts}, such that @var{pts2} = @var{pts}(I, :);
##
## @seealso{points3d, angles3d, angleSort}
## @end deftypefn

function varargout = angleSort3d(pts, varargin)

  # default values
  pt0     = mean (pts, 1);
  pt1     = pts(1,:);

  if length (varargin)==1
      pt0 = varargin{1};
  elseif length (varargin)==2
      pt0 = varargin{1};
      pt1 = varargin{2};
  end

  # create support plane
  plane   = createPlane (pts(1:3, :));

  # project points onto the plane
  pts2d   = planePosition (pts, plane);
  pt0     = planePosition (pt0, plane);
  pt1     = planePosition (pt1, plane);

  # compute origin angle
  theta0  = atan2 (pt1(2)-pt0(2), pt1(1)-pt0(1));
  theta0  = mod (theta0 + 2*pi, 2*pi);

  # translate to reference point
  n       = size (pts, 1);
  pts2d   = pts2d - repmat (pt0, [n 1]);

  # compute angles
  angle   = atan2 (pts2d(:,2), pts2d(:,1));
  angle   = mod (angle - theta0 + 4*pi, 2*pi);

  # sort points according to angles
  [angle, I] = sort (angle); ##ok<ASGLU>

  # format output
  if nargout<2
      varargout{1} = pts(I, :);
  elseif nargout==2
      varargout{1} = pts(I, :);
      varargout{2} = I;
  end

endfunction
