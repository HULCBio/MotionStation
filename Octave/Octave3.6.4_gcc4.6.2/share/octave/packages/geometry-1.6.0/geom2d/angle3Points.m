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
## @deftypefn {Function File} {@var{alpha} =} angle3Points (@var{p1}, @var{p2}, @var{p3})
## Computes the angle between the points @var{p1}, @var{p2} and @var{p3}.
##
## @var{p1}, @var{p2} and @var{p3} are either [1x2] arrays, or [Nx2] arrays, in this case
## @var{alpha} is a [Nx1] array. The angle computed is the directed angle between line 
## (@var{p2}@var{p1}) and line (@var{p2}@var{p3}).
##
## Result is always given in radians, between 0 and 2*pi.
## 
## @seealso{points2d, angles2d, angle2points}
## @end deftypefn

function theta = angle3Points(varargin)

  if length(varargin)==3
      p1 = varargin{1};
      p2 = varargin{2};
      p3 = varargin{3};
  elseif length(varargin)==1
      var = varargin{1};
      p1 = var(1,:);
      p2 = var(2,:);
      p3 = var(3,:);
  end

  # angle line (P2 P1)
  theta = lineAngle(createLine(p2, p1), createLine(p2, p3));

endfunction

%!test
%! # all points inside window, possibly touching edges
%! p1 = [10 0];
%! p2 = [0 0];
%! p3 = [0 10];
%! angle_ = angle3Points(p1, p2, p3);
%! assert(pi/2, angle_,1e-6);
%! angle_ = angle3Points([p1; p2; p3]);
%! assert(pi/2, angle_, 1e-6);

%!test
%! p1 = [10 0; 20 0];
%! p2 = [0 0;0 0];
%! p3 = [0 10; 0 20];
%! angle_ = angle3Points(p1, p2, p3);
%! assert(2, size(angle_, 1));
%! assert([pi/2;pi/2], angle_, 1e-6);

