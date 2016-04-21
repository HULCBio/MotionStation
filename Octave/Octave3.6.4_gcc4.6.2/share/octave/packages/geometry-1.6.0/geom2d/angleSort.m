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
## @deftypefn {Function File} {varargout =} angleSort (@var{pts}, varargin)
## Sort points in the plane according to their angle to origin
##
##
##   PTS2 = angleSort(PTS);
##   Computes angle of points with origin, and sort points with increasing
##   angles in Counter-Clockwise direction.
##
##   PTS2 = angleSort(PTS, PTS0);
##   Computes angles between each point of PTS and PT0, which can be
##   different from origin.
##
##   PTS2 = angleSort(..., THETA0);
##   Specifies the starting angle for sorting.
##
##   [PTS2, I] = angleSort(...);
##   Also returns in I the indices of PTS, such that PTS2 = PTS(I, :);
## 
## @seealso{points2d, angles2d, angle2points, normalizeAngle}
## @end deftypefn

function varargout = angleSort(pts, varargin)

  # default values
  pt0 = [0 0];
  theta0 = 0;

  if length(varargin)==1
      var = varargin{1};
      if size(var, 2)==1
          # specify angle
          theta0 = var;
      else
          pt0 = var;
      end
  elseif length(varargin)==2
      pt0 = varargin{1};
      theta0 = varargin{2};
  end


  n = size(pts, 1);
  pts2 = pts - repmat(pt0, [n 1]);
  angle = lineAngle([zeros(n, 2) pts2]);
  angle = mod(angle - theta0 + 2*pi, 2*pi);

  [dummy, I] = sort(angle);

  # format output
  if nargout<2
      varargout{1} = pts(I, :);
  elseif nargout==2
      varargout{1} = pts(I, :);
      varargout{2} = I;
  end

endfunction

%!shared p1,p2,p3,p4,pts,center
%! p1 = [0 0];
%! p2 = [10 0];
%! p3 = [10 10];
%! p4 = [0 10];
%! pts = [p1;p2;p3;p4];
%! center = [5 5];

%!test
%! expected = pts([3 4 1 2], :);
%! assert (expected, angleSort (pts, center), 1e-6);

%!assert (pts, angleSort (pts, center, -pi), 1e-6);

