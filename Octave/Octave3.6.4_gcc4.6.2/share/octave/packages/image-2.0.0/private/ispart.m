## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, see <http://www.gnu.org/licenses/>.

## This a private function for the is... type of functions for the image package
## Rather than checking the whol image, there can be a speed up by checking only
## a corner of the image first and then the rest if that part is true.

function bool = ispart (foo, in)
  bool = foo (in(1:ceil (rows (in) /100), 1:ceil (columns (in) /100)));
  if (bool)
    bool = foo (in);
  endif
endfunction
