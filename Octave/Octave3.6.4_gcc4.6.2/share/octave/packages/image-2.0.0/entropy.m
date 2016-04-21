## Copyright (C) 2008 Søren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} {@var{E} =} entropy (@var{im})
## @deftypefnx{Function File} {@var{E} =} entropy (@var{im}, @var{nbins})
## Computes the entropy of an image.
##
## The entropy of the elements of the image @var{im} is computed as
##
## @example
## @var{E} = -sum (@var{P} .* log2 (@var{P})
## @end example
##
## where @var{P} is the distribution of the elements of @var{im}. The distribution
## is approximated using a histogram with @var{nbins} cells. If @var{im} is
## @code{logical} then two cells are used by default. For other classes 256 cells
## are used by default.
##
## When the entropy is computed, zero-valued cells of the histogram are ignored.
##
## @seealso{entropyfilt}
## @end deftypefn

function retval = entropy (I, nbins = 0)
  ## Check input
  if (nargin == 0)
    error ("entropy: not enough input arguments");
  endif
  
  if (!ismatrix (I))
    error ("entropy: first input must be a matrix");
  endif
  
  if (!isscalar (nbins))
    error ("entropy: second input argument must be a scalar");
  endif
  
  ## Get number of histogram bins
  if (nbins <= 0)
    if (islogical (I))
      nbins = 2;
    else
      nbins = 256;
    endif
  endif
  
  ## Compute histogram
  P = hist (I (:), nbins, true);
  
  ## Compute entropy (ignoring zero-entries of the histogram)
  P += (P == 0);
  retval = -sum (P .* log2 (P));
endfunction
