## Copyright (C) 2012 Benjamin Lewis <benjf5@gmail.com>
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
## @deftypefn {Function File} {@var{c} =} lombcoeff (@var{time}, @var{mag}, @var{freq})
##
## Return the Lomb Periodogram value at one frequency for a time series.
##
## @seealso{lombnormcoeff}
## @end deftypefn


function coeff = lombcoeff (T, X, o)

  if (nargin != 3)
     print_usage ();
  endif
  if (! all (size (T) == size (X)))
     error ("lombcoeff: Time series vectors of uneven size.\n");
  endif
  if (! isscalar (o))
     error ("lombcoeff: Supplied frequency is not a scalar.\n");
  endif
  if (o == 0)
     error ("lombcoeff: Supplied frequency is not a frequency.\n");
  endif

  oT = o .* T;

  theta = atan2 (sum (sin (2 * oT)), 
                 sum (cos (2 * oT))) ./ (2 * o);

  coeff = (sum (X .* cos (oT - theta)) ^2 / 
           sum (cos (oT - theta) .^2) + 
           sum (X .* sin (oT - theta)) ^2 / 
           sum (sin (oT - theta) .^2));

endfunction


%!shared t, x, o, maxfreq
%! maxfreq = 4 / (2 * pi);
%! t = linspace (0, 8);
%! x = (2 .* sin (maxfreq .* t) + 
%!      3 .* sin ((3/4) * maxfreq .* t) - 
%!      0.5 .* sin ((1/4) * maxfreq .* t) - 
%!      0.2 .* cos (maxfreq .* t) + 
%!      cos ((1/4) * maxfreq .* t));
%! o = [maxfreq , (3/4 * maxfreq) , (1/4 * maxfreq)];
%!assert (lombcoeff (t, x, maxfreq), 1076.77574184435, 5e-10);
%!assert (lombcoeff (t, x, 3/4*maxfreq), 1226.53572492183, 5e-10);
%!assert (lombcoeff (t, x, 1/4*maxfreq), 1341.63962181896, 5e-10);
