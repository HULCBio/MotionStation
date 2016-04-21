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
## @deftypefn {Function File} {@var{out} =} imabsdiff (@var{a}, @var{b})
## @deftypefnx {Function File} {@var{out} =} imabsdiff (@var{a}, @var{b}, @var{class})
## Return absolute difference of image or constant to an image.
##
## If @var{a} and @var{b} are two images of same size and class, returns the absolute
## difference between @var{b} and @var{a}.
##
## The class of @var{out} will be the same as @var{a} unless @var{a} is logical
## in which case @var{out} will be double. Alternatively, the class can be
## specified with @var{class}.
##
## @emph{Note 1}: you can force output class to be logical by specifying
## @var{class}. This is incompatible with @sc{matlab} which will @emph{not} honour
## request to return a logical matrix.
##
## @emph{Note 2}: the values are truncated to the mininum value of the output
## class.
## @seealso{imadd, imcomplement, imdivide, imlincomb, immultiply, imsubtract}
## @end deftypefn

function img = imabsdiff (img, val, out_class = class (img))

  if (nargin < 2 || nargin > 3)
    print_usage;
  endif

  ## we want to make subtraction as double so this is it
  [img, val] = imarithmetics ("imabsdiff", img, val, "double");
  converter = str2func (tolower (out_class));

  if (nargin < 3 && strcmp (out_class, "logical"))
    ## it is using logical as default. Use double instead. We only have this
    ## problem on this function because we are are not actually giving out_class
    ## to imarithmetics
    converter = @double;
  else
    converter = str2func (tolower (out_class));
  endif
  img = converter (abs (img - val));

endfunction

%!assert (imabsdiff (uint8   ([23 250]), uint8   ([26  50])),            uint8   ([ 3 200])); # default to first class and abs works
%!assert (imabsdiff (uint8   ([23 250]), uint8   ([24  50]), "uint16"),  uint16  ([ 1 200])); # defining output class works (not in matlab)
%!assert (imabsdiff (uint8   ([23 250]), uint8   ([24 255]), "int8"),    int8    ([ 1   5])); # signed integers kinda work (not in matlab)
%!assert (imabsdiff (logical ([ 1   0]), logical ([ 1   1])),            double  ([ 0   1])); # return double for two logical images
%!fail  ("imabsdiff (uint8   ([23 250]), 30");                                                # fails subtracting a scalar
%!fail  ("imabsdiff (uint8   ([23 250]), uint16  ([23 250]))");                               # input need to have same class
