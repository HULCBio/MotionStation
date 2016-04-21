## Copyright (C) 2012 Benjamin Lewis  <benjf5@gmail.com>
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
## @deftypefn {Function File} {@var{c} =} lscorrcoeff (@var{time1}, @var{mag1}, @var{time2}, @var{mag2}, @var{time}, @var{freq})
## @deftypefnx {Function File} {@var{c} =} lscorrcoeff (@var{time1}, @var{mag1}, @var{time2}, @var{mag2}, @var{time}, @var{freq}, @var{window} = @var{cubicwgt})
## @deftypefnx {Function File} {@var{c} =} lscorrcoeff (@var{time1}, @var{mag1}, @var{time2}, @var{mag2}, @var{time}, @var{freq}, @var{window} = @var{cubicwgt}, @var{winradius} = 1)
##
## Return the coefficient of the wavelet correlation of two complex time
## series.  The correlation is only effective at a given time and frequency.
## The windowing function applied by default is cubicwgt, this can be changed by
## passing a different function handle to @var{window}, while the radius applied
## is set by @var{winradius}.  Note that this will be most effective when both
## series have had their mean value (if it is not zero) subtracted (and stored
## separately); this reduces the constant-offset error further, and allows the
## functions to be compared on their periodic features rather than their
## constant features.
##
## @seealso{lswaveletcoeff, lscomplexwavelet, lsrealwavelet}
##
## @end deftypefn

function coeff = lscorrcoeff (x1, y1, x2, y2, t, o, wgt = @cubicwgt, wgtrad = 1)

  ## Input checking is absolutely necessary.

  if (!((nargin >= 6) && (nargin <= 8)))
     print_usage ();
  endif

  ## Test to be sure x1, y1, x2, y2 are all vectors, and that t and o are
  ## scalars.
  if (! isvector (x1))
     error ("lscorrcoeff: First time series time values are not a vector.\n");
  endif
  if (! isvector (y1))
     error ("lscorrcoeff: First time series magnitude values are not a vector.\n");
  endif
  if (! isvector (x2))
     error ("lscorrcoeff: Second time series time values are not a vector.\n");
  endif
  if (! isvector (y2))
     error ("lscorrcoeff: Second time series magnitude values are not a vector.\n");
  endif
  if (! isscalar (t))
     error ("lscorrcoeff: Window centre is not a scalar.\n");
  endif
  if (! isscalar (o))
     error ("lscorrcoeff: Specified frequency is not a scalar.\n");
  endif
  if (! isscalar (wgtrad))
     error ("lscorrcoeff: Window radius is not a scalar.\n");
  endif
  if (! all (size (x1) == size (y1)))
     error ("lscorrcoeff: First time series vectors not of matching size.\n");
  endif
  if (! all (size (x2) == size (y2)))
     error ("lscorrcoeff: Second time series vectors not of matching size.\n");
  endif

  ## How to determine if a weight function has been assigned or not? (Possible
  ## to get name of function?)

  so = 0.05 * o;

  ## The first solution that comes to mind is admittedly slightly
  ## ugly and has a data footprint of O(2n) but it is vectorised.
  mask = (abs (x1 - t) * so) < wgtrad;

  rx1 = x1(mask);
  ## FIXME : Needs to have a noisy error if length(y1) != length(x1) -- add this!
  ry1 = y1(mask);

  mask = (abs (x2 - t) * so ) < wgtrad;
  rx2 = x2(mask);
  ry2 = y2(mask);

  windowed_element_count = length (rx1);
  if (windowed_element_count == 0)
     error("lscorrcoeff: No time-series elements contained in window.\n");
  endif

  s = sum (wgt ((rx1 - t) .* so)) * sum (wgt ((rx2 - t ) .* so ));
  if (s != 0)
    coeff = sum (wgt ((rx1 - t) .* so) .* exp (i * o .* rx1) .* ry1) * ...
        sum (wgt ((rx2 - t) .* so) .* exp (i * o .* rx2) .* conj (ry2)) / s;
  else
    coeff = 0;
  endif

endfunction


%!shared t, p, x, y, z, o, maxfreq
%! maxfreq = 4 / (2 * pi);
%! t = linspace (0, 8);
%! x = (2 .* sin (maxfreq .* t) +
%!      3 .* sin ((3/4) * maxfreq .* t) -
%!      0.5 .* sin ((1/4) * maxfreq .* t) -
%!      0.2 .* cos (maxfreq .* t) +
%!      cos ((1/4) * maxfreq .* t));
%! y = - x;
%! p = linspace (0, 8, 500);
%! z = (2 .* sin (maxfreq .* p) +
%!      3 .* sin ((3/4) * maxfreq .* p) -
%!      0.5 .* sin ((1/4) * maxfreq .* p) -
%!      0.2 .* cos (maxfreq .* p) +
%!      cos ((1/4) * maxfreq .* p));
%! o = [maxfreq , (3/4 * maxfreq) , (1/4 * maxfreq)];
%!assert (lscorrcoeff (t, x, t, x, 0.5, maxfreq), 
%!                     -5.54390340863576 - 1.82439880893383i, 5e-10);
%!assert (lscorrcoeff (t, x, t, y, 0.5, maxfreq), 
%!                     5.54390340863576 + 1.82439880893383i, 5e-10);
%!assert (lscorrcoeff (t, x, p, z, 0.5, maxfreq), 
%!                     -5.55636741054624 - 1.82803733863170i, 5e-10);

## Demo with sin, cos as Nir suggested.
%!demo
%! ## This generates the correlation coefficient at time 0.5 and circular freq. 0.9
%! x = 1:10;
%! y = sin (x);
%! z = cos (x);
%! a = lscorrcoeff (x, y, x, z, 0.5, 0.9)

