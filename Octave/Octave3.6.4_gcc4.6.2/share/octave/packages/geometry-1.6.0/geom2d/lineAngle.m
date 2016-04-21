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
## @deftypefn {Function File} {@var{theta} =} lineAngle(varargin)
## Computes angle between two straight lines
##
##   A = lineAngle(LINE);
##   Returns the angle between horizontal, right-axis and the given line.
##   Angle is fiven in radians, between 0 and 2*pi, in counter-clockwise
##   direction.
##
##   A = lineAngle(LINE1, LINE2);
##   Returns the directed angle between the two lines. Angle is given in
##   radians between 0 and 2*pi, in counter-clockwise direction.
## 
## @seealso{lines2d, angles2d, createLine, normalizeAngle}
## @end deftypefn

function theta = lineAngle(varargin)

  nargs = length(varargin);
  if nargs == 1
      # angle of one line with horizontal
      line = varargin{1};
      theta = mod(atan2(line(:,4), line(:,3)) + 2*pi, 2*pi);
      
  elseif nargs==2
      # angle between two lines
      theta1 = lineAngle(varargin{1});
      theta2 = lineAngle(varargin{2});
      theta = mod(bsxfun(@minus, theta2, theta1)+2*pi, 2*pi);
  end

endfunction

# horizontal
%!test
%! line1 = createLine([2 3 1 0]);
%! assert (lineAngle(line1), 0, 1e-6);

%!test
%! line1 = createLine([2 3 0 1]);
%! assert (lineAngle(line1), pi/2, 1e-6);

%!test
%! line1 = createLine([2 3 1 1]);
%! assert (lineAngle(line1), pi/4, 1e-6);

%!test
%! line1 = createLine([2 3 5 -1]);
%! assert (lineAngle(line1), mod(atan2(-1, 5)+2*pi, 2*pi), 1e-6);

%!test
%! line1 = createLine([2 3 5000 -1000]);
%! assert (lineAngle(line1), mod(atan2(-1, 5)+2*pi, 2*pi), 1e-6);

%!test
%! line1 = createLine([2 3 -1 0]);
%! assert (lineAngle(line1), pi, 1e-6);

# test lineAngle with two parameters : angle between 2 lines
# check for 2 orthogonal lines
%!test
%! line1 = createLine([1 3 1 0]);
%! line2 = createLine([-2 -1 0 1]);
%! assert (lineAngle(line1, line2), pi/2, 1e-6);
%! assert (lineAngle(line2, line1), 3*pi/2, 1e-6);

# check for 2 orthogonal lines, with very different parametrizations
%!test
%! line1 = createLine([1 3 1 1]);
%! line2 = createLine([-2 -1 -1000 1000]);
%! assert (lineAngle(line1, line2), pi/2, 1e-6);
%! assert (lineAngle(line2, line1), 3*pi/2, 1e-6);
