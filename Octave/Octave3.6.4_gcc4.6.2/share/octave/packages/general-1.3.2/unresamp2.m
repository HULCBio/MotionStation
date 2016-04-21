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
## @deftypefn{Function File} {[@var{xs}, @var{ys}] =} unresamp2 (@var{x}, @var{y}, @var{n})
## Perform a uniform resampling of a planar curve.
## The arrays @var{x} and @var{y} specify x and y coordinates of the points of the curve.
## On return, the same curve is approximated by @var{xs}, @var{ys} that have length @var{n}
## and the distances between successive points are approximately equal.
## @end deftypefn

## Author: Jaroslav Hajek <highegg@gmail.com>

function [xs, ys] = unresamp2 (x, y, n)
  if (! isvector (x) || ! size_equal (x, y) || ! isscalar (n))
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
  # cumulative integral
  s = cumsum ([0; ds]);
  # generate sample points
  i = linspace (0, s(end), n);
  if (! rowvec)
    i = i.';
  endif
  # and resample
  xs = interp1 (s, x, i);
  ys = interp1 (s, y, i);
endfunction

%!demo
%! R = 2; r = 3; d = 1.5;
%! th = linspace (0, 2*pi, 1000);
%! x = (R-r) * cos (th) + d*sin ((R-r)/r * th);
%! y = (R-r) * sin (th) + d*cos ((R-r)/r * th);
%! x += 0.3*exp (-(th-0.8*pi).^2); 
%! y += 0.4*exp (-(th-0.9*pi).^2); 
%! 
%! [xs, ys] = unresamp2 (x, y, 40);
%! plot (x, y, "-", xs, ys, "*");
%! title ("uniform resampling")
