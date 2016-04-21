## Copyright (C) 2011 William Krekeler <WKrekeler@cleanearthtech.com>
## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn  {Function File} {@var{rgb} =} wavelength2rgb (@var{wavelength})
## @deftypefnx {Function File} {@var{rgb} =} wavelength2rgb (@var{wavelength}, @var{class})
## @deftypefnx {Function File} {@var{rgb} =} wavelength2rgb (@var{wavelength}, @var{class}, @var{gamma})
## Convert wavelength in nm into an RGB value set.
##
## Given a N-dimensional matrix @var{wavelength} with color values in nm, returns
## a RGB image with N+3 dimensions.
##
## @group
## @example
## wavelength2rgb (400)
##     @result{} [0.51222 0.00000 0.70849]
##
## wavelength2rgb ([400 410])
##     @result{(:,:,1)} 0.51222   0.49242
##     @result{(:,:,2)} 0         0
##     @result{(:,:,3)} 0.70849   0.85736
## @end example
## @end group
##
## The @var{rgb} class can be specified with @var{class}.  Possible values are
## double (default), single, uint8, uint16, and int16.
##
## @group
## @example
## wavelength2rgb (400)
##     @result{} 0.51222  0.00000  0.70849
##
## wavelength2rgb (400, "uint8")
##     @result{} 131    0  181
## @end example
## @end group
##
## The luminance of colors can be adjusted with @var{gamma} which must a scalar
## value in the range [0 1]. Defaults to 0.8.
##
## Reference:
## @itemize @bullet
## @item @uref{http://stackoverflow.com/questions/2374959/algorithm-to-convert-any-positive-integer-to-an-rgb-value}
## @item @uref{http://www.midnightkite.com/color.html} per Dan Bruton
## @end itemize
## @end deftypefn

function rgb = wavelength2rgb (wavelength, out_class = "double", gamma = 0.8)

  if (nargin < 1 || nargin > 3)
    print_usage;
  elseif (!isnumeric (wavelength) || any (wavelength <= 0))
    error ("wavelength2rgb: wavelength must a positive numeric");
  elseif (!ischar (out_class) || all (!strcmpi (out_class, {"single", "double", "uint8", "uint16", "int16"})))
    error ("wavelength2rgb: unsupported class `%s'", char (out_class));
  elseif (!isnumeric (gamma) || !isscalar (gamma) || gamma > 1 || gamma < 0)
    error ("wavelength2rgb: gamma must a numeric scalar between 1 and 0");
  endif

  ## initialize rgb. One extra dimension of size 3 for RGB. Later on, we will
  ## use ndims and when input is a scalar, ndims still returns 2 which means
  ## output would be 1x1x3. Check this and adjust later on
  if (isscalar (wavelength))
    rgb = zeros (1, 3);
    size_adjust = 1;
  else
    rgb = zeros ([size(wavelength), 3]);
    size_adjust = 0;
  endif

  ## this RGBmask's will be used for broadcasting later
  Rmask = Gmask = Bmask = false ([ones(1, ndims (wavelength) - size_adjust) 3]);
  Rmask(1)  = true;
  Gmask(2)  = true;
  Bmask(3)  = true;

  ## for each group of wavelengths we calculate the mask, expand for the 3
  ## channels and use Rmask, Gmask and Bmask with broadcasting to select the
  ## right one. Will skip some channels since their values would be zero and
  ## we already initialized the matrix with zeros()
  get_rgb_mask = @(mask) repmat (mask, [ones(1, ndims (mask) - size_adjust) 3]);

  ## FIXME when warning for broadcasting is turned off by default, this
  ## unwind_protect block could be removed
  bc_warn = warning ("query", "Octave:broadcast");
  unwind_protect
    warning ("off", "Octave:broadcast");
    mask    = wavelength >= 380 & wavelength < 440;
    rgbmask = get_rgb_mask (mask);
    rgb(rgbmask & Rmask) = -(wavelength(mask) - 440) / 60; # 60 comes from 440-380
    ## skiping green channel (values of zero)
    rgb(rgbmask & Bmask) = 1;

    mask    = wavelength >= 440 & wavelength < 490;
    rgbmask = get_rgb_mask (mask);
    ## skiping red channel (values of zero)
    rgb(rgbmask & Gmask) = (wavelength(mask) - 440) / 50; # 50 comes from 490-440
    rgb(rgbmask & Bmask) = 1;

    mask    = wavelength >= 490 & wavelength < 510;
    rgbmask = get_rgb_mask (mask);
    ## skiping red channel (values of zero)
    rgb(rgbmask & Gmask) = 1;
    rgb(rgbmask & Bmask) = -(wavelength(mask) - 510) / 20; # 20 comes from 510-490

    mask    = wavelength >= 510 & wavelength < 580;
    rgbmask = get_rgb_mask (mask);
    rgb(rgbmask & Rmask) = (wavelength(mask) - 510) / 70; # 70 comes from 580-510
    rgb(rgbmask & Gmask) = 1;
    ## skiping blue channel (values of zero)

    mask    = wavelength >= 580 & wavelength < 645;
    rgbmask = get_rgb_mask (mask);
    rgb(rgbmask & Rmask) = 1;
    rgb(rgbmask & Gmask) = -(wavelength(mask) - 645) / 65; # 65 comes from 645-580
    ## skiping blue channel (values of zero)

    mask    = wavelength >= 645 & wavelength <= 780;
    rgbmask = get_rgb_mask (mask);
    rgb(rgbmask & Rmask) = 1;
    ## skiping green channel (values of zero)
    ## skiping blue channel (values of zero)

    ## all other wavelengths have values of zero in all channels (black)
  unwind_protect_cleanup
    ## restore broadcats warning status
    warning (bc_warn.state, "Octave:broadcast");
  end_unwind_protect

  ## let intensity fall off near the vision limits
  ## set the factor
  factor        = zeros (size (wavelength));
  mask          = wavelength >= 380 & wavelength < 420;
  factor(mask)  = 0.3 + 0.7*(wavelength(mask) - 380) / 40; # 40 = 420 - 380
  mask          = wavelength >= 420 & wavelength <= 700;
  factor(mask)  = 1;
  mask          = wavelength > 700 & wavelength <= 780;
  factor(mask)  = 0.3 + 0.7*(780 - wavelength(mask)) / 80; # 80 = 780 - 700
  ## for other wavelengths, factor is 0

  ## expand factor for the 3 channels
  factor = repmat (factor, [ones(1, ndims (factor) - size_adjust) 3]);

  ## correct rgb
  rgb = (rgb .* factor) .^gamma;

  ## scale to requested class
  switch tolower (out_class)
    case {"single"}   rgb = im2single (rgb);
    case {"double"}   ## do nothing, already class double
    case {"uint8"}    rgb = im2uint8  (rgb);
    case {"uint16"}   rgb = im2uint16 (rgb);
    case {"int16"}    rgb = im2int16  (rgb);
    otherwise         error ("wavelength2rgb: unsupported class `%s'", out_class)
  endswitch
endfunction

%!demo
%!
%! RGB = wavelength2rgb (350:800); # RGB values for wavelengths between 350 and 800 nm
%! RGB = RGB .* ones (300, 1, 1);  # make it 300 rows for display
%! imshow (RGB)
