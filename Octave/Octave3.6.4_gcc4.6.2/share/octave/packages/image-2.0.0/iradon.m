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
## @defun @var{recon} = iradon (@var{proj}, @var{theta}, @var{interp}, @
##                              @var{filter}, @var{scaling}, @var{output_size})
##
## Performs filtered back-projection on the projections in @var{proj}
## to reconstruct an approximation of the original image.
##
## @var{proj} should be a matrix whose columns are projections of an
## image (or slice).  Each element of @var{theta} is used as the angle
## (in degrees) that the corresponding column of @var{proj} was
## projected at.  If @var{theta} is omitted, it is assumed that
## projections were taken at evenly spaced angles between 0 and 180 degrees.
## @var{theta} can also be a scalar, in which case it is taken as the
## angle between projections if more than one projection is provided.
## 
## @var{interp} determines the type of interpolation that is used
## in the back-projection.  It must be one of the types accepted by
## @command{interp1}, and defaults to 'Linear' if it is omitted.
##
## @var{filter} and @var{scaling} determine the type of rho filter 
## to apply.  See the help for @command{rho_filter} for their use.
##
## @var{output_size} sets the edge length of the output image (it
## is always square).  This argument does not scale the image.  If it
## is omitted, the length is taken to be
## @group
## 2 * floor (size (proj, 1) / (2 * sqrt (2))).
## @end group
## 
## If @var{proj} was obtained using @command{radon}, there is no
## guarantee that the reconstructed image will be exactly the same
## size as the original.
## 
## @defunx [@var{recon}, @var{filt}] = iradon (...)
##
## This form also returns the filter frequency response in the vector
## @var{filt}.
## @end defun
##
## Performs filtered back-projection in order to reconstruct an
## image based on its projections.
##
## Filtered back-projection is the most common means of reconstructing
## images from CT scans.  It is a two step process: First, each of 
## the projections is filtered with a `rho filter', so named due
## to its frequency domain definition, which is simply |rho|, where
## rho is the radial axis in a polar coordinate system.  Second, 
## the filtered projections are each `smeared' across the image
## space.  This is the back-projection part.
##
## Usage example:
## @example
##   P = phantom ();
##   projections = radon (P, 1:179);
##   reconstruction = iradon (filtered_projections, 1:179, 'Spline', 'Hann');
##   figure, imshow (reconstruction, [])
## @end example

function [recon, filt] = iradon (proj, theta, interp, filter, scaling, output_size)
  
  if (nargin == 0)
    error ("No projections provided to iradon");
  endif
  
  if (nargin < 6)
    output_size = 2 * floor (size (proj, 1) / (2 * sqrt (2)));
  endif
  if (nargin < 5) || (length (scaling) == 0)
    scaling = 1;
  endif
  if (nargin < 4) || (length (filter) == 0)
    filter = "Ram-Lak";
  endif
  if (nargin < 3) || (length (interp) == 0)
    interp = "linear";
  endif
  if (nargin < 2) || (length (theta) == 0)
    theta = 180 * (0:1:size (proj, 2) - 1) / size (proj, 2);
  endif
  
  if (isscalar (theta)) && (size (proj, 2) != 1)
    theta = (0:size (proj, 2) - 1) * theta;
  endif
  
  if (length (theta) != size (proj, 2))
    error ("iradon: Number of projections does not match number of angles")
  endif
  if (!isscalar (scaling))
    error ("iradon: Frequency scaling value must be a scalar");
  endif
  if (!length (find (strcmpi (interp, {'nearest', 'linear', 'spline', \
                                       'pchip', 'cubic'}))))
    error ("iradon: Invalid interpolation method specified");
  endif
  
  ## Convert angles to radians
  theta *= pi / 180;
  
  ## First, filter the projections
  [filtered, filt] = rho_filter (proj, filter, scaling);
  
  ## Next, back-project
  recon = back_project (filtered, theta, interp, output_size);
  
endfunction


function recon = back_project (proj, theta, interpolation, dim)
  ## Make an empty image
  recon = zeros (dim, dim);
  
  ## Zero pad the projections if the requested image
  ## has a diagonal longer than the projections
  diagonal = ceil (dim * sqrt (2)) + 1;
  if (size (proj, 1) < diagonal)
    diff = 2 * ceil ((diagonal - size (proj, 1)) / 2);
    proj = padarray (proj, diff / 2);
  endif
  
  ## Create the x & y values for each pixel
  centre = floor ((dim + 1) / 2);
  x = (0:dim - 1) - centre + 1;
  x = repmat (x, dim, 1);
   
  y = (dim - 1: -1 : 0)' - centre;
  y = repmat (y, 1, dim);
  
  ## s axis for projections, needed by interp1
  s = (0:size (proj, 1) - 1) - floor (size (proj, 1) / 2);
  
  ## Sum each projection's contribution
  for i = 1:length (theta)
    s_dash = (x * cos (theta (i)) + y * sin (theta (i)));
    interpolated = interp1 (s, proj (:, i), s_dash (:), ["*", interpolation]);
    recon += reshape (interpolated, dim, dim);
  endfor
  
  ## Scale the reconstructed values to their original size
  recon *= pi / (2 * length (theta));
  
endfunction

%!demo
%! P = phantom ();
%! figure, imshow (P, []), title ("Original image")
%! projections = radon (P, 0:179);
%! reconstruction = iradon (projections, 0:179, 'Spline', 'Hann');
%! figure, imshow (reconstruction, []), title ("Reconstructed image")
