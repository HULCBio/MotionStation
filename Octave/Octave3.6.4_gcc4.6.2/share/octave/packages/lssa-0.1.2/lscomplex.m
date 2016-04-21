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
## @deftypefn {Function File} {@var{t} =} lscomplex (@var{time}, @var{mag}, @var{maxfreq}, @var{numcoeff}, @var{numoctaves})
## 
## Return a series of least-squares transforms of a complex-valued time series.
## Each transform is minimized independently at each frequency. @var{numcoeff}
## frequencies are tested for each of @var{numoctaves} octaves, starting from
## @var{maxfreq}.
##
## Each result (a + bi) at a given frequency, o, defines the real and imaginary
## coefficients for a sum of cosine and sine functions: a cos(ot) + b i
## sin(ot).  The specific frequency can be determined by its index in @var{t},
## @var{ind}, as @var{maxfreq} * 2 ^ (- (@var{ind} - 1) / @var{numcoeff}).
##
## @seealso{lsreal}
## @end deftypefn


function transform = lscomplex (t, x, omegamax, ncoeff, noctave)

  if (nargin != 5)
     print_usage ();
  endif
  if (! isvector (t))
     error ("lscomplex: Time values are not a vector.\n");
  endif
  if (! isvector (x))
     error ("lscomplex: Magnitude values are not a vector.\n");
  endif
  if (! all (size (t) == size (x)))
     error ("lscomplex: Size of time vector, magnitude vector unequal.\n");
  endif
  if (! isscalar (omegamax))
     error ("lscomplex: More than one value for maximum frequency specified.\n");
  endif
  if (! isscalar (ncoeff))
     error ("lscomplex: More than one number of frequencies per octave specified.\n");
  endif
  if (! isscalar (noctave))
     error ("lscomplex: More than one number of octaves to traverse specified.\n");
  endif
  if (omegamax == 0)
     error ("lscomplex: Specified maximum frequency is not a frequency.\n");
  endif
  if (noctave == 0)
     error ("lscomplex: No octaves of results requested.\n");
  endif
  if (ncoeff == 0)
     error ("lscomplex: No frequencies per octave requested.\n");
  endif
  if (ncoeff != floor (ncoeff))
     error ("lscomplex: Specified number of frequencies per octave is not integral.\n");
  endif
  if (noctave != floor (noctave))
     error ("lscomplex: Specified number of octaves of results is not integral.\n");
  endif

  n = numel (t); 
   
  iter = 0 : (ncoeff * noctave - 1);
  omul = (2 .^ (- iter / ncoeff));

  ot = t(:) * (omul * omegamax);

  transform = sum ((cos (ot) - (sin (ot) .* i)) .* x(:), 1) / n; 
  
endfunction 

%!test
%! maxfreq = 4 / ( 2 * pi );
%! t = [0:0.008:8];
%! x = ( 2 .* sin (maxfreq .* t) +
%!       3 .* sin ( (3 / 4) * maxfreq .* t)-
%!       0.5 .* sin ((1/4) * maxfreq .* t) -
%!       0.2 .* cos (maxfreq .* t) + 
%!       cos ((1/4) * maxfreq .* t));
%! assert (lscomplex (t, x, maxfreq, 2, 2), 
%!       [(-0.400924546169395 - 2.371555305867469i), ...
%!        (1.218065147708429 - 2.256125004156890i), ... 
%!        (1.935428592212907 - 1.539488163739336i), ...
%!        (2.136692292751917 - 0.980532175174563i)], 5e-10);
