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
## @deftypefn {Function File} {@var{S} =} stdfilt (@var{im})
## @deftypefnx{Function File} {@var{S} =} stdfilt (@var{im}, @var{domain})
## @deftypefnx{Function File} {@var{S} =} stdfilt (@var{im}, @var{domain}, @var{padding}, @dots{})
## Computes the local standard deviation in a neighbourhood around each pixel in
## an image.
##
## The standard deviation of the pixels of a neighbourhood is computed as
##
## @example
## @var{S} = sqrt ((sum (@var{x} - @var{mu}).^2)/(@var{N}-1))
## @end example
##
## where @var{mu} is the mean value of the pixels in the neighbourhood,
## @var{N} is the number of pixels in the neighbourhood. So, an unbiased estimator
## is used.
##
## The neighbourhood is defined by the @var{domain} binary mask. Elements of the
## mask with a non-zero value are considered part of the neighbourhood. By default
## a 3 by 3 matrix containing only non-zero values is used.
##
## At the border of the image, extrapolation is used. By default symmetric
## extrapolation is used, but any method supported by the @code{padarray} function
## can be used. Since extrapolation is used, one can expect a lower deviation near
## the image border.
##
## @seealso{std2, paddarray, entropyfilt}
## @end deftypefn

function retval = stdfilt (I, domain = true (3), padding = "symmetric", varargin)
  ## Check input
  if (nargin == 0)
    error ("stdfilt: not enough input arguments");
  endif
  
  if (!ismatrix (I))
    error ("stdfilt: first input must be a matrix");
  endif
  
  if (!ismatrix (domain))
    error ("stdfilt: second input argument must be a logical matrix");
  endif
  domain = (domain > 0);
  
  ## Pad image
  pad = floor (size (domain)/2);
  I = padarray (I, pad, padding, varargin {:});
  even = (round (size (domain)/2) == size (domain)/2);
  idx = cell (1, ndims (I));
  for k = 1:ndims (I)
    idx {k} = (even (k)+1):size (I, k);
  endfor
  I = I (idx {:});

  ## Perform filtering
  retval = __spatial_filtering__ (I, domain, "std", I, 0);

endfunction
