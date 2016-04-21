## Copyright (C) 2009 VZLU Prague, a.s., Czech Republic
##
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 3 of the License, or (at your option) any later
## version.
##
## This program is distributed in the hope that it will be useful, but WITHOUT
## ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
## FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
## details.
##
## You should have received a copy of the GNU General Public License along with
## this program; if not, see <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn{Function File} {[@var{xs}, @var{ys}] =} adresamp2 (@var{x}, @var{y}, @var{n}, @var{eps})
## Perform an adaptive resampling of a planar curve.
## The arrays @var{x} and @var{y} specify x and y coordinates of the points of the curve.
## On return, the same curve is approximated by @var{xs}, @var{ys} that have length @var{n}
## and the angles between successive segments are approximately equal.
## @end deftypefn

## Author : Jaroslav Hajek <highegg@gmail.com>

function [xs, ys] = adresamp2 (x, y, n, eps)
  if (! isvector (x) || ! size_equal (x, y) || ! isscalar (n) \
      || ! isscalar (eps))
    print_usage ();
  endif

  if (rows (x) == 1)
    rowvec = true;
    x = x.'; y = y.';
  else
    rowvec = false;
  endif

  # first differences
  dx = diff (x); dy = diff (y);
  # arc lengths
  ds = hypot (dx, dy);
  # derivatives
  dx = dx ./ ds;
  dy = dy ./ ds;
  # second derivatives
  d2x = deriv2 (dx, ds);
  d2y = deriv2 (dy, ds);
  # curvature
  k = abs (d2x .* dy - d2y .* dx);
  # curvature cut-off
  if (eps > 0)
    k = max (k, eps*max (k));
  endif
  # cumulative integrals
  s = cumsum ([0; ds]);
  t = cumsum ([0; ds .* k]);
  # generate sample points
  i = linspace (0, t(end), n);
  if (! rowvec)
    i = i.';
  endif
  # and resample
  xs = interp1 (t, x, i);
  ys = interp1 (t, y, i);
endfunction

# calculates second derivatives from first (non-uniform intervals), using local
# quadratic approximations.
function d2x = deriv2 (dx, dt)
  n = length (dt);
  if (n >= 2)
    d2x = diff (dx) ./ (dt(1:n-1) + dt(2:n));
    d2x = [2*d2x(1); d2x(1:n-2) + d2x(2:n-1); 2*d2x(n-1)];
  else
    d2x = zeros (n, 1);
  endif
endfunction

%!demo
%! R = 2; r = 3; d = 1.5;
%! th = linspace (0, 2*pi, 1000);
%! x = (R-r) * cos (th) + d*sin ((R-r)/r * th);
%! y = (R-r) * sin (th) + d*cos ((R-r)/r * th);
%! x += 0.3*exp (-(th-0.8*pi).^2); 
%! y += 0.4*exp (-(th-0.9*pi).^2); 
%! 
%! [xs, ys] = adresamp2 (x, y, 40);
%! plot (x, y, "-", xs, ys, "*");
%! title ("adaptive resampling")
