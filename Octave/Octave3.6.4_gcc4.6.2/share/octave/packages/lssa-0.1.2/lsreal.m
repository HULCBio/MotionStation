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
## @deftypefn {Function File} {@var{t} =} lsreal (@var{time}, @var{mag}, @var{maxfreq}, @var{numcoeff}, @var{numoctaves})
##
## Return a series of least-squares transforms of a real-valued time series.
## Each transform is minimized independently for each frequency.  The method
## used is a Lomb-Scargle transform of the real-valued (@var{time}, @var{mag})
## series, starting from frequency @var{maxfreq} and descending @var{numoctaves}
## octaves with @var{numcoeff} coefficients per octave.
##
## The result of the transform for each frequency is the coefficient of a sum of
## sine and cosine functions modified by that frequency, in the form of a
## complex number—where the cosine coefficient is encoded in the real term, and
## the sine coefficient is encoded in the imaginary term. Each frequency is fit
## independently from the others, and to minimize very low frequency error,
## consider storing the mean of a dataset with a constant or near-constant
## offset separately, and subtracting it from the dataset.
##
## @seealso{lscomplex}
## @end deftypefn 



function transform = lsreal (t, x, omegamax, ncoeff, noctave)

  ## Sanity checks to make sure that the user can get meaningful errors.
  if (nargin != 5)
     print_usage ();
  endif
  if (! isvector (t))
     error ("lsreal: Time values are not a vector.\n");
  endif
  if (! isvector (x))
     error ("lsreal: Magnitude values are not a vector.\n");
  endif
  if (! all (size (t) == size (x)))
     error ("lsreal: Size of time vector, magnitude vector unequal.\n");
  endif
  if (! isscalar (omegamax))
     error ("lsreal: More than one value for maximum frequency specified.\n");
  endif
  if (! isscalar (ncoeff))
     error ("lsreal: More than one number of frequencies per octave specified.\n");
  endif
  if (! isscalar (noctave))
     error ("lsreal: More than one number of octaves to traverse specified.\n");
  endif
  if (omegamax == 0)
     error ("lsreal: Specified maximum frequency is not a frequency.\n");
  endif
  if (noctave == 0)
     error ("lsreal: No octaves of results requested.\n");
  endif
  if (ncoeff == 0)
     error ("lsreal: No frequencies per octave requested.\n");
  endif
  if (ncoeff != floor (ncoeff))
     error ("lsreal: Specified number of frequencies per octave is not integral.\n");
  endif
  if (noctave != floor (noctave))
     error ("lsreal: Specified number of octaves of results is not integral.\n");
  endif

  n = numel (t);
  
  iter = 0 : (ncoeff * noctave - 1);
  omul = (2 .^ (- iter / ncoeff));

  ## For a given frequency, the iota term is taken at twice the frequency of the
  ## zeta term.
  ot = t(:) * (omul * omegamax);
  oit = t(:) * (omul * omegamax * 2);
  
  zeta = sum ((cos (ot) - (sin (ot) .* i)) .* x(:), 1) / n;
  iota = sum ((cos (oit) - (sin (oit) .* i)), 1) / n;

  transform = 2 .* (conj (zeta) - conj (iota) .* zeta) ./ (1 - abs (iota) .^ 2);

endfunction

%!test
%! maxfreq = 4 / ( 2 * pi );
%! t = linspace(0,8);
%! x = ( 2 .* sin ( maxfreq .* t ) +
%!       3 .* sin ( (3/4) * maxfreq .* t ) -
%!       0.5 .* sin ( (1/4) * maxfreq .* t ) -
%!       0.2 .* cos ( maxfreq .* t ) +
%!       cos ( (1/4) * maxfreq .* t ) );
%! # In the assert here, I've got an error bound large enough to catch
%! # individual system errors which would present no real issue. 
%! assert (lsreal (t,x,maxfreq,2,2),
%!       [(-1.68275915310663 + 4.70126183846743i), ...
%!        (1.93821553170889 + 4.95660209883437i), ...
%!        (4.38145452686697 + 2.14403733658600i), ...
%!        (5.27425332281147 - 0.73933440226597i)],
%!         5e-10)

