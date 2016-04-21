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

## This is a private fucntion for the common code between the functions that
## convert an input image into another class. Mostly does the input checking for
## all of them and returns the class of the input image

function im_class = imconversion (nargs, fname, ind, im1)
  ## Input checking
  if (nargs < 1 || nargs > 2)
    print_usage (fname);
  elseif (nargs == 2 && (!ischar (ind) || !strcmpi (ind, "indexed")))
    error ("%s: second argument must be a string with the word `indexed'\n", fname);
  endif

  if (ind && !isind (im1))
    error ("%s: input should have been an indexed image but it is not.\n", fname);
  endif

  im_class = class (im1);

endfunction
