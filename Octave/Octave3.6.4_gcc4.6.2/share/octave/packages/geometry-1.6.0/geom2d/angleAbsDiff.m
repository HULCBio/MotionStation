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
## @deftypefn {Function File} {@var{dif} =} angleAbsDiff (@var{angle1}, @var{angle2})
## Computes the absolute angular difference between two angles in radians.
## The result is comprised between 0 and pi.
##
## @example
##     A = angleAbsDiff(pi/2, pi/3)
##     A = 
##         0.5236   # equal to pi/6
## @end example
## 
## @seealso{angles2d, angleDiff}
## @end deftypefn

function dif = angleAbsDiff(angle1, angle2)

  # first, normalization
  angle1 = normalizeAngle(angle1);
  angle2 = normalizeAngle(angle2);

  # compute difference and normalize
  dif = normalizeAngle(angle1 - angle2);
  dif = min(dif, 2*pi - dif);

endfunction

%!shared xp
%! xp = pi/2;
%!assert (xp, angleAbsDiff (pi/2, 0), 1e-6);
%!assert (xp, angleAbsDiff (0, pi/2), 1e-6);
%!assert (xp, angleAbsDiff (0, 3*pi/2), 1e-6);
%!assert (xp, angleAbsDiff (3*pi/2, 0), 1e-6);

