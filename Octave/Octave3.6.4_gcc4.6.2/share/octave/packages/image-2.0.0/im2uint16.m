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
## @deftypefn {Function File} @var{im2} = im2uint16 (@var{im1})
## @deftypefnx {Function File} @var{im2} = im2uint16 (@var{im1}, "indexed")
## Convert input image @var{im1} to uint16 precision.
##
## The following images type are supported: double, single, uint8, uint16, int16,
## binary (logical), indexed. If @var{im1} is an indexed images, the second
## argument must be a string with the value `indexed'.
##
## Processing will depend on the class of the input image @var{im1}:
## @itemize @bullet
## @item uint16 - returns the same as input
## @item uint8, double, single, int16, logical - output will be rescaled for the
## interval of the uint16 class [0 65535]
## @item indexed - depends on the input class. If double, no value can be above
## the max of the uint16 class (65535).
## @end itemize
##
## @seealso{im2bw, im2double, im2int16, im2single, im2uint8}
## @end deftypefn

function im = im2uint16 (im, indexed = false)

  ## Input checking (private function that is used for all im2class functions)
  im_class = imconversion (nargin, "im2uint16", indexed, im);

  ## for those who may wonder, 65535 = intmax ("uint16")
  switch im_class
    case "uint16"
      ## do nothing, return the same
    case {"single", "double"}
      if (indexed)
        imax = max (im(:));
        if ( imax > 65535)
          error ("Too many colors '%d' for an indexed uint16 image", imax);
        endif
        im = uint16 (im) - 1;
      else
        im = uint16 (im * 65535);
      endif
    case "logical"
      im = uint16 (im) * uint16 (65535);
    case "uint8"
      if (indexed)
        im = uint16 (im);
      else
        ## 257 is the ratio between the max of uint8 and uint16
        ## double (intmax ("uint16")) / double (intmax ("uint8")) == 257
        im = 257 * uint16 (im);
      endif
    case "int16"
      im = uint16 (double (im) + double (intmax (im_class)) + 1);
    otherwise
      error ("unsupported image class %s", im_class);
  endswitch

endfunction

%!assert(im2uint16(uint16([1 2 3])), uint16([1 2 3]));          # uint16 returns the same
%!assert(im2uint16(uint8([0 255])), uint16([0 65535]));         # basic usage with uint8
%!assert(im2uint16([0 0.5 1]), uint16([0 32768 65535]));        # basic usage with double
%!assert(im2uint16([1 2]), uint16([65535 65535]));              # for double, above 1 is same as 1
%!assert(im2uint16(uint8([3 25]), "indexed"), uint16([3 25]));  # test indexed uint8
%!assert(im2uint16([3 25], "indexed"), uint16([2 24]));         # test indexed double
%!assert(im2uint16(int16([-32768 32768])), uint16([0 65535]));  # test signed integer
