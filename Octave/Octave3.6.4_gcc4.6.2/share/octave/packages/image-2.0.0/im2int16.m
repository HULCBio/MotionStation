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
## @deftypefn {Function File} @var{im2} = im2int16 (@var{im1})
## Convert input image @var{im1} to int16 precision.
##
## The following images type are supported: double, single, uint8, uint16, int16,
## binary (logical).
##
## Processing will depend on the class of the input image @var{im1}:
## @itemize @bullet
## @item int16 - returns the same as input
## @item uint8, double, single, uint16, logical - output will be rescaled for the
## interval of the uint16 class [0 65535]
## @end itemize
##
## @seealso{im2bw, im2double, im2single, im2uint8, im2uint16}
## @end deftypefn

function im = im2int16 (im)

  ## unlike the others for imconversion, this only accepts 1 argument so we check here
  if (nargin != 1)
    print_usage;
  endif
  ## Input checking (private function that is used for all im2class functions)
  im_class = imconversion (nargin, "im2int16", false, im);

  ## for those who may wonder, 32767 = intmax ("int16")
  ## for those who may wonder, 65535 = intmax ("uint16")
    switch im_class
    case "int16"
      ## do nothing, return the same
    case {"single", "double"}
      im = int16 (double (im * uint16(65535)) - 32767 - 1);
    case "logical"
      im(im)  = intmax ("int16");
      im(!im) = intmin ("int16");
    case "uint8"
        ## 257 is the ratio between the max of uint8 and uint16
        ## double (intmax ("uint16")) / double (intmax ("uint8")) == 257
        im = int16 (double (257 * uint16 (im)) - 32767 - 1);
    case "uint16"
      im = int16 (double (im) - 32767 - 1);
    otherwise
      error ("unsupported image class %s", im_class);
  endswitch

endfunction

%!assert(im2int16(int16([-2 2 3])), int16([-2 2 3]));           # uint16 returns the same
%!assert(im2int16(uint8([0 255])), int16([-32768 32767]));      # basic usage with uint8
%!assert(im2int16(uint16([0 65535])), int16([-32768 32767]));   # basic usage with uint16
%!assert(im2int16([0 0.5 1]), int16([-32768 0 32767]));         # basic usage with double
%!assert(im2int16([1 2]), int16([32767 32767]));                # for double, above 1 is same as 1
