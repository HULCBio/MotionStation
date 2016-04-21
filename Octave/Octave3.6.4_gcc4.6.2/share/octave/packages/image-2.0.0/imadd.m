## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {@var{out} =} imadd (@var{a}, @var{b})
## @deftypefnx {Function File} {@var{out} =} imadd (@var{a}, @var{b}, @var{class})
## Add image or constant to an image.
##
## If @var{a} and @var{b} are two images of same size and class, the images are
## added. Alternatively, if @var{b} is a floating-point scalar, its value is added
## to the image @var{a}.
##
## The class of @var{out} will be the same as @var{a} unless @var{a} is logical
## in which case @var{out} will be double. Alternatively, it can be
## specified with @var{class}.
##
## @emph{Note 1}: you can force output class to be logical by specifying
## @var{class}. This is incompatible with @sc{matlab} which will @emph{not} honour
## request to return a logical matrix.
##
## @emph{Note 2}: the values are truncated to the maximum value of the output
## class.
## @seealso{imabsdiff, imcomplement, imdivide, imlincomb, immultiply, imsubtract}
## @end deftypefn

function img = imadd (img, val, out_class = class (img))

  if (nargin < 2 || nargin > 3)
    print_usage;
  endif
  [img, val] = imarithmetics ("imadd", img, val, out_class);

  ## output class is the same as input img, unless img is logical in which case
  ## it should be double. Tested in matlab by Freysh at ##matlab:
  ##   - if you imadd 2 logical matrix, it's not the union. You actually get values of 2
  ##   - the previous is true even if you specify "logical" as output class. It does
  ##     not honors the request, output will be double class anyway, not even a
  ##     warning will be issued (but we in octave are nicer and will)
  ##   - you can specify smaller integer types for output than input and values
  ##     are truncated. Input uint16 and request uint8, it will be respected

  ## this is matlab imcompatible on purpose. We are compatible and return double
  ## anyway, even if both input are logical (and wether this is correct is
  ## already debatable), but if the user forcelly requests output class to be
  ## logical, then he must be expecting it (matlab returns double anyway and
  ## ignores request).

  if (nargin > 2 && strcmpi (out_class, "logical"))
    img = img | val;
  else
    img = img + val;
  endif

endfunction

%!assert (imadd (uint8   ([23 250]), uint8   ([23 250])),            uint8   ([46 255])); # default to first class and truncate
%!assert (imadd (uint8   ([23 250]), 10),                            uint8   ([33 255])); # works adding a scalar
%!assert (imadd (uint8   ([23 250]), uint8   ([23 250]), "uint16"),  uint16  ([46 500])); # defining output class works
%!assert (imadd (logical ([ 1   0]), logical ([ 1   1])),            double  ([ 2   1])); # return double for two logical images
%!assert (imadd (logical ([ 1   0]), logical ([ 1   1]), "logical"), logical ([ 1   1])); # this is matlab incompatible on purpose
%!fail  ("imadd (uint8   ([23 250]), uint16  ([23 250]))");                               # input need to have same class
