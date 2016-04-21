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
## @deftypefn {Function File} @var{im2} = im2single (@var{im1})
## @deftypefnx {Function File} @var{im2} = im2single (@var{im1}, "indexed")
## Convert input image @var{im1} to single precision.
##
## The following images type are supported: double, single, uint8, uint16, int16,
## binary (logical), indexed. If @var{im1} is an indexed images, the second
## argument must be a string with the value `indexed'.
##
## Processing will depend on the class of the input image @var{im1}:
## @itemize @bullet
## @item uint8, uint16, int16 - output will be rescaled for the interval [0 1]
## with the limits of the class;
## @item single - output will be the same as input;
## @item double - output will have the same values as input but the class will
## single;
## @item indexed, logical - converted to single class.
## @end itemize
##
## @seealso{im2bw, im2double, im2int16, im2uint8, im2uint16}
## @end deftypefn

function im = im2single (im, indexed = false)
  im = im2float ("single", nargin, im, indexed);
endfunction

%!assert(im2single([1 2 3]), single([1 2 3]));                  # double returns the same
%!assert(im2single(uint8([0 255])), single([0 1]));             # basic usage
%!assert(im2single(uint8([1 25]), "indexed"), single([2 26]));  # test indexed
%!assert(im2single(int16([-32768 32768])), single([0 1]));      # test signed integer
