## Copyright (c) 2012 Benjamin Lewis <benjf5@gmail.com>
## 
## This program is free software; you can redistribute it and/or modify it under
## the terms of the GNU General Public License as published by the Free Software
## Foundation; either version 2 of the License, or (at your option) any later
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
## @deftypefn {Function File} {@var{c} =} lombnormcoeff (@var{time}, @var{mag}, @var{freq})
##
## Return the normalized Lomb Periodogram value at one frequency for a time
## series.
##
## @seealso{lombcoeff}
##
## @end deftypefn


function coeff = lombnormcoeff (T, X, omega)

  if (nargin != 3)
     print_usage ();
  endif
  if (! all (size (T) == size (X)))
     error ("lombnormcoeff: Time series vectors of uneven size.\n");
  endif
  if (! isscalar (omega))
     error ("lombnormcoeff: Supplied frequency is not a scalar.\n");
  endif
  if (omega == 0)
     error ("lombnormcoeff: Supplied frequency is not a frequency.\n");
  endif


  xmean = mean (X);

  theta = atan2 (sum (sin (2 .* omega .*T)),
		 sum (cos (2 .* omega .* T))) / (2*omega);

  coeff = ((sum ((X-xmean) .* cos (omega .* T - theta)) .^ 2 /
	    sum (cos (omega .* T - theta) .^ 2) + 
            sum ((X-xmean) .* sin (omega .* T - theta)) .^ 2 /
	    sum (sin (omega .* T - theta) .^ 2 )) / 
           (2 * var(X)));

endfunction

%!shared t, x, o, maxfreq
%! maxfreq = 4 / (2 * pi);
%! t = linspace (0, 8);
%! x = (2 .* sin (maxfreq .* t) + 
%!      3 .* sin ((3/4) * maxfreq .* t) - 
%!      0.5 .* sin((1/4) * maxfreq .* t) - 
%!      0.2 .* cos (maxfreq .* t) + 
%!      cos ((1/4) * maxfreq .*t));
%! o = [maxfreq , (3/4 * maxfreq) , (1/4 * maxfreq)];
%!assert (lombnormcoeff (t,x,o(1)), 44.7068607258824, 5e-10);
%!assert (lombnormcoeff (t,x,o(2)), 35.7769955188467, 5e-10);
%!assert (lombnormcoeff (t,x,o(3)), 20.7577786183241, 5e-10);
