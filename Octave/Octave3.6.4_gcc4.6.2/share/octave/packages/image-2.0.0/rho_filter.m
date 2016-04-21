## Copyright (C) 2010 Alex Opie <lx_op@orcon.net.nz>
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
## @defun {@var{filtered} =} rho_filter (@var{proj}, @var{type}, @var{scaling})
##
## Filters the parallel ray projections in the columns of @var{proj},
## according to the filter type chosen by @var{type}.  @var{type}
## can be chosen from
## @itemize
## @item 'none'
## @item 'Ram-Lak' (default)
## @item 'Shepp-Logan'
## @item 'Cosine'
## @item 'Hann'
## @item 'Hamming'
## @end itemize
## 
## If given, @var{scaling} determines the proportion of frequencies
## below the nyquist frequency that should be passed by the filter.
## The window function is compressed accordingly, to avoid an abrupt
## truncation of the frequency response.
##
## @defunx {[@var{filtered}, @var{filter}] =} rho_filter (...)
##
## This form also returns the frequency response of the filter in
## the vector @var{filter}.
##
## @end defun
## 
## Performs rho filtering on the parallel ray projections provided.
##
## Rho filtering is performed as part of the filtered back-projection
## method of CT image reconstruction.  It is the filtered part of
## the name.
## The simplest rho filter is the Ramachadran-Lakshminarayanan (Ram-Lak),
## which is simply |rho|, where rho is the radial component of spatial
## frequency.  However, this can cause unwanted amplification of noise, 
## which is what the other types attempt to minimise, by introducing
## roll-off into the response.  The Hann and Hamming filters multiply
## the standard response by a Hann or Hamming window, respectively.
## The cosine filter is the standard response multiplied by a cosine
## shape, and the Shepp-Logan filter multiplies the response with
## a sinc shape.  The 'none' filter performs no filtering, and is
## included for completeness and to enable incorporating this function
## easily into scripts or functions that may offer the ability to choose
## to apply no filtering.
##
## This function is designed to be used by the function @command{iradon},
## but has been exposed to facilitate custom inverse radon transforms
## and to more clearly break down the process for educational purposes.
## The operations
## @example
##     filtered = rho_filter (proj);
##     reconstruction = iradon (filtered, 1, 'linear', 'none');
## @end example
## are exactly equivalent to
## @example
##     reconstruction = iradon (proj, 1, 'linear', 'Ram-Lak');
## @end example
##
## Usage example:
## @example
##   P = phantom ();
##   projections = radon (P);
##   filtered_projections = rho_filter (projections, 'Hamming');
##   reconstruction = iradon (filtered_projections, 1, 'linear', 'none');
##   figure, imshow (reconstruction, [])
## @end example

function [filtered_proj, filt] = rho_filter (proj, type, scaling)

  filtered_proj = proj;
  
  if (nargin < 3)
    scaling = 1;
  endif
  if (nargin < 2) || (size (type) == 0)
    type = 'ram-lak';
  endif

  if (strcmpi (type, 'none'))
    filt = 1;
    return;
  endif
  
  if (scaling > 1) || (scaling < 0)
    error ('Scaling factor must be in [0,1]');
  endif
  
  ## Extend the projections to a power of 2
  new_len = 2 * 2^nextpow2 (size (filtered_proj, 1));
  filtered_proj (new_len, 1) = 0;
  
  ## Scale the frequency response
  int_len = (new_len * scaling);
  if (mod (floor (int_len), 2))
    int_len = ceil (int_len);
  else
    int_len = floor (int_len);
  endif
  
  ## Create the basic filter response
  rho = scaling * (0:1 / (int_len / 2):1);
  rho = [rho'; rho(end - 1:-1:2)'];
  
  ## Create the window to apply to the filter response
  if (strcmpi (type, 'ram-lak'))
    filt = 1;
  elseif (strcmpi (type, 'hamming'))
    filt = fftshift (hamming (length (rho)));
  elseif (strcmpi (type, 'hann'))
    filt = fftshift (hanning (length (rho)));
  elseif (strcmpi (type, 'cosine'))
    f = 0.5 * (0:length (rho) - 1)' / length (rho);
    filt = fftshift (sin (2 * pi * f));
  elseif (strcmpi (type, 'shepp-logan'))
    f = (0:length (rho) / 2)' / length (rho);
    filt = sin (pi * f) ./ (pi * f);
    filt (1) = 1;
    filt = [filt; filt(end - 1:-1:2)];
  else
    error ('rho_filter: Unknown window type');
  endif
  
  ## Apply the window
  filt = filt .* rho;
  
  ## Pad the response to the correct length
  len_diff = new_len - int_len;
  if (len_diff != 0)
    pad = len_diff / 2;
    filt = padarray (fftshift (filt), pad);
    filt = fftshift (filt);
  endif
  
  filtered_proj = fft (filtered_proj);
  
  ## Perform the filtering
  for i = 1:size (filtered_proj, 2)
    filtered_proj (:, i) = filtered_proj (:, i) .* filt;
  endfor
  
  ## Finally bring the projections back to the spatial domain
  filtered_proj = real (ifft (filtered_proj));
  
  ## Chop the projections back to their original size
  filtered_proj (size (proj, 1) + 1:end, :) = [];
  
endfunction

%!demo
%! P = phantom ();
%! projections = radon (P);
%! filtered_projections = rho_filter (projections, 'Hamming');
%! reconstruction = iradon (filtered_projections, 1, 'linear', 'none');
%! figure, imshow (reconstruction, [])
