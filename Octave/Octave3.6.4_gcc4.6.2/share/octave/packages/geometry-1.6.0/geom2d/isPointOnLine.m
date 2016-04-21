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
## @deftypefn {Function File} {@var{b} = } isPointOnLine (@var{point}, @var{line})
## Test if a point belongs to a line
##
##   B = isPointOnLine(POINT, LINE)
##   with POINT being [xp yp], and LINE being [x0 y0 dx dy].
##   Returns 1 if point lies on the line, 0 otherwise.
##
##   If POINT is an N*2 array of points, B is a N*1 array of booleans.
##
##   If LINE is a N*4 array of line, B is a 1*N array of booleans.
##
##   @seealso {lines2d, points2d, isPointOnEdge, isPointOnRay, angle3Points}
## @end deftypefn

function b = isPointOnLine(point, line, varargin)
 
  # extract computation tolerance
  tol = 1e-14;
  if ~isempty(varargin)
      tol = varargin{1};
  end

  # number of lines and of points
  Nl = size(line, 1);
  Np = size(point, 1);

  # adapt the size of inputs
  x0 = repmat(line(:,1)', Np, 1);
  y0 = repmat(line(:,2)', Np, 1);
  dx = repmat(line(:,3)', Np, 1);
  dy = repmat(line(:,4)', Np, 1);
  xp = repmat(point(:,1), 1, Nl);
  yp = repmat(point(:,2), 1, Nl);

  # test if lines are colinear
  b = abs((xp-x0).*dy-(yp-y0).*dx)./hypot(dx, dy) < tol;

endfunction
