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
## @deftypefn {Function File} {@var{alpha} =} anglePoints3d (@var{p1}, @var{p2})
## @deftypefnx {Function File} {@var{alpha} =} anglePoints3d (@var{p1}, @var{p2},@var{p3})
## @deftypefnx {Function File} {@var{alpha} =} anglePoints3d (@var{pts})
## Compute angle between three 3D points
##
##   @var{alpha} = anglePoints3d(P1, P2)
##   Computes angle (P1, O, P2), in radians, between 0 and PI.
##
##   @var{alpha} = anglePoints3d(P1, P2, P3)
##   Computes angle (P1, P2, P3), in radians, between 0 and PI.
##
##   @var{alpha} = anglePoints3d(PTS)
##   PTS is a 3x3 or 2x3 array containing coordinate of points.
##
## @seealso{points3d, angles3d}
## @end deftypefn

function alpha = anglePoints3d(varargin)

  p2 = [0 0 0];
  if length(varargin)==1
      pts = varargin{1};
      if size(pts, 1)==2
          p1 = pts(1,:);
          p0 = [0 0 0];
          p2 = pts(2,:);
      else
          p1 = pts(1,:);
          p0 = pts(2,:);
          p2 = pts(3,:);
      end
  elseif length(varargin)==2
      p1 = varargin{1};
      p0 = [0 0 0];
      p2 = varargin{2};
  elseif length(varargin)==3
      p1 = varargin{1};
      p0 = varargin{2};
      p2 = varargin{3};
  end

  # ensure all data have same size
  n1 = size(p1, 1);
  n2 = size(p2, 1);
  n0 = size(p0, 1);
  if n1~=n2
      if n1==1
          p1 = repmat(p1, [n2 1]);
      elseif n2==1
          p2 = repmat(p2, [n1 1]);
      else
          error('Arguments P1 and P2 must have the same size');
      end
  end
  if n1~=n0
      if n1==1
          p1 = repmat(p1, [n0 1]);
      elseif n0==1
          p0 = repmat(p0, [n1 1]);
      else
          error('Arguments P1 and P0 must have the same size');
      end
  end

  # normalized vectors
  p1 = normalizeVector(p1-p0);
  p2 = normalizeVector(p2-p0);

  # compute angle
  alpha = acos(dot(p1, p2, 2));

endfunction
