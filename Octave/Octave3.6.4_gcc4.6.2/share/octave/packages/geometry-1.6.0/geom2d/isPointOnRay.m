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
## @deftypefn {Function File} {@var{b} = } isPointOnRay (@var{point}, @var{ray})
## @deftypefnx {Function File} {@var{b} = } isPointOnRay (@var{point}, @var{ray}, @var{tol})
## Test if a point belongs to a ray
##
##  @var{b} = isPointOnRay(@var{point}, @var{ray});
##  Returns @code{true} if point @var{point} belongs to the ray @var{ray}.
##  @var{point} is given by [x y] and RAY by [x0 y0 dx dy]. @var{tol} gives the
##  tolerance for the calculations.
##
##  @seealso{rays2d, points2d, isPointOnLine}
## @end deftypefn

function b = isPointOnRay(point, ray, varargin)

  # extract computation tolerance
  tol = 1e-14;
  if ~isempty(varargin)
      tol = varargin{1};
  end

  # number of rays and points
  Nr = size(ray, 1);
  Np = size(point, 1);

  # if several rays or several points, adapt sizes of arrays
  x0 = repmat(ray(:,1)', Np, 1);
  y0 = repmat(ray(:,2)', Np, 1);
  dx = repmat(ray(:,3)', Np, 1);
  dy = repmat(ray(:,4)', Np, 1);
  xp = repmat(point(:,1), 1, Nr);
  yp = repmat(point(:,2), 1, Nr);

  # test if points belongs to the supporting line
  b1 = abs ( (xp-x0).*dy - (yp-y0).*dx ) ./ hypot(dx, dy) < tol;

  # check if points lie the good direction on the rays
  ind     = abs (dx) > abs (dy);
  t       = zeros (size (b1));
  t(ind)  = (xp(ind)-x0(ind))./dx(ind);
  t(~ind) = (yp(~ind)-y0(~ind))./dy(~ind);

  # combine the two tests
  b = b1 & (t >= 0);

endfunction

%!shared ray
%! p1 = [10 20];
%! p2 = [80 20];
%! ray = createRay (p1, p2);

%!assert (isPointOnRay([10 20], ray));
%!assert (isPointOnRay([80 20], ray));
%!assert (isPointOnRay([50 20], ray));
%!assert (isPointOnRay([50 20+1e-3], ray,1e-2));
%!assert ( !isPointOnRay([50 20+1e-3], ray,1e-4));
%!assert ( !isPointOnRay([9.99 20], ray));
%!assert ( !isPointOnRay([80 20.01], ray));
%!assert ( !isPointOnRay([50 21], ray));
%!assert ( !isPointOnRay([79 19], ray));
