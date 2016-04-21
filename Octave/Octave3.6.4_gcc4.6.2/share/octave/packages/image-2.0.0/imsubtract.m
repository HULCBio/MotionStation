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
## @deftypefn {Function File} {@var{out} =} imsubtract (@var{a}, @var{b})
## @deftypefnx {Function File} {@var{out} =} imsubtract (@var{a}, @var{b}, @var{class})
## Subtract image or constant to an image.
##
## If @var{a} and @var{b} are two images of same size and class, @var{b} is subtracted
## to @var{a}. Alternatively, if @var{b} is a floating-point scalar, its value is subtracted
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
## @emph{Note 2}: the values are truncated to the mininum value of the output
## class.
##
## @emph{NOte 3}: values are truncated before the operation so if input images are
## unsigned integers and the request output class is a signed integer, it may lead
## to unexpected results:
##
## @example
## @group
## imsubtract (uint8 ([23 190]), uint8 ([24 200]), "int8")
##      @result{} -1  0
## @end group
## @end example
##
## Because both 190 and 200 were truncated to 127 before subtraction, their difference
## is zero.
## @seealso{imabsdiff, imadd, imcomplement, imdivide, imlincomb, immultiply}
## @end deftypefn

function img = imsubtract (img, val, out_class = class (img))

  if (nargin < 2 || nargin > 3)
    print_usage;
  elseif (any (isa (img, {"uint8", "uint16", "uint32", "uint64"})) && any (strcmpi (out_class, {"int8", "int16", "int32", "int64"})))
    ## because we convert the images before the subtraction, if input is:
    ## imsubtract (uint8(150), uint8 (200), "int8");
    ## rsult will be 0 because both values are truncated to 127 before subtraction.
    ## There is no matlab compatibility issue because matlab does not have the option
    ## to specify output class in imsubtract
    warning ("input images are unsigned integers but requested output is signed integer. This may lead to unexpected results.");
  endif

  [img, val] = imarithmetics ("imsubtract", img, val, out_class);

  ## The following makes the code imcompatible with matlab on certain cases.
  ## This is on purpose. Read comments in imadd source for the reasons
  if (nargin > 2 && strcmpi (out_class, "logical"))
    img = img > val;
  else
    img = img - val;
  endif

endfunction

%!assert (imsubtract (uint8   ([23 250]), uint8   ([24  50])),            uint8   ([ 0 200])); # default to first class and truncate
%!assert (imsubtract (uint8   ([23 250]), 10),                            uint8   ([13 240])); # works subtracting a scalar
%!assert (imsubtract (uint8   ([23 250]), uint8   ([24  50]), "uint16"),  uint16  ([ 0 200])); # defining output class works (not in matlab)
%!assert (imsubtract (uint8   ([23 250]), uint8   ([24 255]), "int8"),    int8    ([-1   0])); # signed integers kinda work (not in matlab)
%!assert (imsubtract (logical ([ 1   0]), logical ([ 1   1])),            double  ([ 0  -1])); # return double for two logical images
%!assert (imsubtract (logical ([ 1   0]), logical ([ 1   1]), "logical"), logical ([ 0   0])); # this is matlab incompatible on purpose
%!fail  ("imsubtract (uint8   ([23 250]), uint16  ([23 250]))");                               # input need to have same class
