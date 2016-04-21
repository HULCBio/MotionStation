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
## @deftypefn {Function File} {@var{alpha} =} angle2Points (@var{p1}, @var{p2})
## Compute horizontal angle between 2 points
##
## @var{p1} and @var{p2} are either [1x2] arrays, or [Nx2] arrays, in this case
## @var{alpha} is a [Nx1] array. The angle computed is the horizontal angle of
## the line (@var{p1},@var{p2}).
##
## Result is always given in radians, between 0 and 2*pi.
## 
## @seealso{points2d, angles2d, angle3points, normalizeAngle, vectorAngle}
## @end deftypefn

function theta = angle2Points(varargin)

  # process input arguments
  if length(varargin)==2
      p1 = varargin{1};
      p2 = varargin{2};
  elseif length(varargin)==1
      var = varargin{1};
      p1 = var(1,:);
      p2 = var(2,:);
  end    

  # ensure data have correct size
  n1 = size(p1, 1);
  n2 = size(p2, 1);
  if n1~=n2 && min(n1, n2)>1
      error('angle2Points: wrong size for inputs');
  end

  # angle of line (P2 P1), between 0 and 2*pi.
  dp = bsxfun(@minus, p2, p1);
  theta = mod(atan2(dp(:,2), dp(:,1)) + 2*pi, 2*pi);

endfunction

%!test
%! # all points inside window, possibly touching edges
%! p1 = [0 0];
%! p2 = [10 0];
%! angle_ = angle2Points (p1, p2);
%! assert (angle_,0,1e-6);
%! angle_ = angle2Points (p2, p1);
%! assert (angle_,pi,1e-6);


%!test
%! # all points inside window, possibly touching edges
%! p1 = [0 0];
%! p2 = [0 10];
%! angle_ = angle2Points (p1, p2);
%! assert (pi/2, angle_,1e-6);
%! angle_ = angle2Points (p2, p1);
%! assert (3*pi/2, angle_,1e-6);

%!test
%! # all points inside window, possibly touching edges
%! p1 = [0 0;0 0;0 0;0 0];
%! p2 = [10 0;10 10;0 10;-10 10];
%! angle_ = angle2Points (p1, p2);
%! assert (size (p1, 1), size (angle_, 1));
%! res = [0;pi/4;pi/2;3*pi/4];
%! assert (res, angle_, 1e-6);

%!test
%! # all points inside window, possibly touching edges
%! p1 = [0 0];
%! p2 = [10 0;10 10;0 10;-10 10];
%! angle_ = angle2Points (p1, p2);
%! assert(size (p2, 1), size (angle_, 1));
%! res = [0;pi/4;pi/2;3*pi/4];
%! assert(res, angle_,1e-6);


