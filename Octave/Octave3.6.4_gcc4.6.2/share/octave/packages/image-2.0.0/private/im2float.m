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

## im2double and im2single are very similar so here's the common code,
## which is prety much all of it.

function im = im2float (out_class, caller_nargin, im, indexed = false)

  ## Input checking (private function that is used for all im2class functions)
  im_class = imconversion (caller_nargin, ["im2" out_class], indexed, im);

  converter = eval (["@" out_class]);
  switch im_class
    case {"single", "double", "logical"}
      if (strcmp (im_class, out_class))
        ## do nothing, return the same
      else
        im = converter (im);
      endif
    case {"uint8", "uint16"}
      if (indexed)
        im = converter (im) + 1;
      else
        im = converter (im) / converter (intmax (im_class));
      endif
    case "int16"
      im = (converter (im) + converter (intmax (im_class)) + 1) / converter (intmax ("uint16"));
    otherwise
      error ("unsupported image class %s", im_class);
  endswitch
endfunction
