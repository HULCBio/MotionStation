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
## @deftypefn {Function File} {@var{range} =} getrangefromclass (@var{img})
## Return display range of image.
##
## For a given image @var{img}, returns @var{range}, a 1x2 matrix with the
## minimum and maximum values. It supports the same classes as @code{intmax} and
## @code{intmin}, as well as 'logical', 'single', and 'double'.
##
## For @sc{matlab} compatibility, if @var{img} is of the class 'single' or
## 'double', min and max are considered 0 and 1 respectively.
##
## @example
## @group
## getrangefromclass (ones (5)) # note that class is 'double'
##      @result{} [0   1]
## getrangefromclass (logical (ones (5)))
##      @result{} [0   1]
## getrangefromclass (int8 (ones (5)))
##      @result{} [-128  127]
## @end group
## @end example
##
## @seealso{intmin, intmax, bitmax}
## @end deftypefn

function r = getrangefromclass (img)

  if (nargin != 1)
    print_usage;
  ## note that isnumeric would return false for logical matrix and ismatrix
  ## returns true for strings
  elseif (!ismatrix (img) || ischar (img))
    error ("Argument 'img' must be an image");
  endif

  cl = class (img);
  if (regexp (cl, "u?int(8|16|32|64)"))
    r = [intmin(cl) intmax(cl)];
  elseif (any (strcmp (cl, {"single", "double", "logical"})))
    r = [0 1];
  else
    error ("Unknown class '%s'", cl)
  endif

endfunction

%!assert (getrangefromclass (double (ones (5))) == [0 1]);      # double returns [0 1]
%!assert (getrangefromclass (single (ones (5))) == [0 1]);      # single returns [0 1]
%!assert (getrangefromclass (logical (ones (5))) == [0 1]);     # logical returns [0 1]
%!assert (getrangefromclass (int8 (ones (5))) == [-128 127]);   # checks int
%!assert (getrangefromclass (uint8 (ones (5))) == [0 255]);     # checks unit
%!fail ("getrangefromclass ('string')");                        # fails with strings
%!fail ("getrangefromclass ({3, 4})");                          # fails with cells
