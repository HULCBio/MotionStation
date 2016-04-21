## Copyright (C) 2007 Søren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} @var{im2} = im2uint8 (@var{im1})
## @deftypefnx {Function File} @var{im2} = im2uint8 (@var{im1}, "indexed")
## Convert input image @var{im1} to uint16 precision.
##
## The following images type are supported: double, single, uint8, uint16, int16,
## binary (logical), indexed. If @var{im1} is an indexed images, the second
## argument must be a string with the value `indexed'.
##
## Processing will depend on the class of the input image @var{im1}:
## @itemize @bullet
## @item uint8 - returns the same as input
## @item uint16, double, single, int16, logical - output will be rescaled for the
## interval of the uint8 class [0 255]
## @item indexed - depends on the input class. No value can be above the max of
## the uint8 class (255).
## @end itemize
##
## @seealso{im2bw, im2double, im2int16, im2single, im2uint16}
## @end deftypefn

function im = im2uint8 (im, indexed = false)

  ## Input checking (private function that is used for all im2class functions)
  im_class = imconversion (nargin, "im2uint8", indexed, im);

  if (indexed)
    imax = max (im(:));
    if (imax > 255)
      error ("Too many colors '%d' for an indexed uint8 image", imax);
    endif
  endif

  ## for those who may wonder, 255 = intmax ("uint8")
  switch im_class
    case "uint8"
      ## do nothing, return the same
    case {"single", "double"}
      if (indexed)
        im = uint8 (im) - 1;
      else
        im = uint8 (im * 255);
      endif
    case "logical"
      im = uint8 (im) * uint8 (255);
    case "uint16"
      if (indexed)
        im = uint8 (im);
      else
        ## 257 is the ratio between the max of uint8 and uint16
        ## double (intmax ("uint16")) / double (intmax ("uint8")) == 257
        im = uint8 (im / 257);
      endif
    case "int16"
      im = uint8 ((double (im) + double (intmax (im_class)) + 1) / 257);
    otherwise
      error ("unsupported image class %s", im_class);
  endswitch

endfunction

%!assert(im2uint8(uint8([1 2 3])), uint8([1 2 3]));               # uint16 returns the same
%!assert(im2uint8(uint16([0 65535])), uint8([0 255]));            # basic usage with uint16
%!assert(im2uint8([0 0.5 1]), uint8([0 128 255]));                # basic usage with double
%!assert(im2uint8([1 2]), uint8([255 255]));                      # for double, above 1 is same as 1
%!assert(im2uint8(uint16([3 25]), "indexed"), uint8([3 25]));     # test indexed uint8
%!assert(im2uint8([3 25], "indexed"), uint8([2 24]));             # test indexed double
%!assert(im2uint8(int16([-32768 0 32768])), uint8([0 128 255]));  # test signed integer
