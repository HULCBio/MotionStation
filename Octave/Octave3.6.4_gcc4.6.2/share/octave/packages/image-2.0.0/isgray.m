## Copyright (C) 2000 Kai Habel <kai.habel@gmx.de>
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
## @deftypefn {Function File} @var{bool} = isgray (@var{img})
## Return true if @var{img} is a grayscale image.
##
## A variable is considereed to be a gray scale image if it is 2-dimensional,
## non-sparse matrix, and:
## @itemize @bullet
## @item is of class double and all values are in the range [0, 1];
## @item is of class uint8, uint16 or int16.
## @end itemize
##
## Note that grayscale time-series image have 4 dimensions (NxMx1xtime) but
## isgray will still return false.
##
## @seealso{isbw, isind, isrgb}
## @end deftypefn

function bool = isgray (img)

  if (nargin != 1)
    print_usage ();
  endif

  bool = false;
  if (!isimage (img))
    bool = false;
  elseif (ndims (img) == 2)
    switch (class (img))
      case "double"
        bool = ispart (@is_double_image, img);
      case {"uint8", "uint16", "int16"}
        bool = true;
    endswitch
  endif

endfunction

%!shared a
%! a = rand (100);
%!assert (isgray (a), true);
%! a(50, 50) = 2;
%!assert (isgray (a), false);
%! a = uint8 (randi (255, 100));
%!assert (isgray (a), true);
%! a = int8 (a);
%!assert (isgray (a), false);
