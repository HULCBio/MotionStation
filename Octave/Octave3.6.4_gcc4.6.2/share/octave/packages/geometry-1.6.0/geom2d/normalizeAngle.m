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
## @deftypefn {Function File} {@var{alpha2} =} normalizeAngle (@var{alpha})
## @deftypefnx {Function File} {@var{alpha2} =} normalizeAngle (@var{alpha}, @var{center})
## Normalize an angle value within a 2*PI interval
##
##   ALPHA2 = normalizeAngle(ALPHA);
##   ALPHA2 is the same as ALPHA modulo 2*PI and is positive.
##
##   ALPHA2 = normalizeAngle(ALPHA, CENTER);
##   Specifies the center of the angle interval.
##   If CENTER==0, the interval is [-pi ; +pi]
##   If CENTER==PI, the interval is [0 ; 2*pi] (default).
##
##   Example:
##   # normalization between 0 and 2*pi (default)
##   normalizeAngle(5*pi)
##   ans =
##       3.1416
##
##   # normalization between -pi and +pi
##   normalizeAngle(7*pi/2, 0)
##   ans =
##       -1.5708
##
##   References
##   Follows the same convention as apache commons library, see:
##   http://commons.apache.org/math/api-2.2/org/apache/commons/math/util/MathUtils.html## 
##
## @seealso{vectorAngle, lineAngle}
## @end deftypefn

function alpha = normalizeAngle(alpha, varargin)

  center = pi;
  if ~isempty(varargin)
      center = varargin{1};
  end

  alpha = mod(alpha-center+pi, 2*pi) + center-pi;

endfunction

%!assert (pi/2, normalizeAngle (pi/2), 1e-6);
%!assert (pi, normalizeAngle (pi), 1e-6);
%!assert (3*pi/2, normalizeAngle (3*pi/2), 1e-6);
%!assert (pi/2, normalizeAngle (pi/2, pi), 1e-6);
%!assert (pi, normalizeAngle (pi, pi), 1e-6);
%!assert (3*pi/2, normalizeAngle (3*pi/2, pi), 1e-6);

%!test
%! theta = linspace(0, 2*pi-.1, 100);
%! assert(theta, normalizeAngle (theta), 1e-6);

%!assert (0, normalizeAngle (0, 0), 1e-6);
%!assert (pi/2, normalizeAngle (pi/2, 0), 1e-6);
%!assert (-pi, normalizeAngle (-pi, 0), 1e-6);
%!assert (-pi/2, normalizeAngle (7*pi/2, 0), 1e-6);

%!test
%! theta = linspace(-pi+.1, pi-.1, 100);
%! assert(theta, normalizeAngle (theta, 0), 1e-6);


