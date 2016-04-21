## Copyright (C) 2000, 2001 Kai Habel <kai.habel@gmx.de>
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
## @deftypefn {Function File} @var{gray}= rgb2gray (@var{rgb})
## Convert RGB image or colormap to grayscale.
##
## If @var{rgb} is an RGB image, the conversion to grayscale is weighted based
## on the luminance values (see @code{rgb2ntsc}).  Supported classes are single,
## double,  uint8 and uint16.
##
## If @var{rgb} is a colormap it is converted into the YIQ space of ntsc.  The
## luminance value (Y) is taken to create a gray colormap.
##
## @seealso{mat2gray, ntsc2rgb, rgb2ind, rgb2ntsc, rgb2ycbcr}
## @end deftypefn

function gray = rgb2gray (rgb)

  if (nargin != 1)
    print_usage();
  endif

  if (iscolormap (rgb))
    gray = rgb2ntsc (rgb) (:, 1) * ones (1, 3);
  elseif (isimage (rgb) && ndims (rgb) == 3)

    ## FIXME when warning for broadcasting is turned off by default, this
    ## unwind_protect block could be removed

    ## we are using broadcasting on the code below so we turn off the
    ## warnings but will restore to previous state at the end
    bc_warn = warning ("query", "Octave:broadcast");
    unwind_protect
      warning ("off", "Octave:broadcast");

      ## mutiply each color by the luminance factor (this is also matlab compatible)
      ##      0.29894 * red + 0.58704 * green + 0.11402 * blue
      gray = im2double (rgb) .* permute ([0.29894, 0.58704, 0.11402], [1, 3, 2]);
      gray = sum (gray, 3);

      switch (class (rgb))
      case {"single", "double"}
        ## do nothing. All is good
      case "uint8"
        gray = im2uint8 (gray);
      case "uint16"
        gray = im2uint16 (gray);
      otherwise
        error ("rgb2gray: unsupported class %s", class(rgb));
      endswitch

    unwind_protect_cleanup
      ## restore broadcats warning status
      warning (bc_warn.state, "Octave:broadcast");
    end_unwind_protect
  else
    error ("rgb2gray: the input must either be an RGB image or a colormap");
  endif
endfunction

# simplest test, double image, each channel on its own and then all maxed
%!shared img
%! img = zeros (2, 2, 3);
%! img(:,:,1) = [1 0; 0 1];
%! img(:,:,2) = [0 1; 0 1];
%! img(:,:,3) = [0 0; 1 1];
%! img = rgb2gray (img);
%!assert ([img(1,1) img(1,2) img(2,1) img(2,2)], [0.29894 0.58704 0.11402 1]);
