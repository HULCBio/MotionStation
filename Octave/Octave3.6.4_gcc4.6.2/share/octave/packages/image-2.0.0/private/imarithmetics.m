## Copyright (C) 2011 Carnë Draug <carandraug+dev@gmail.com>
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

## -*- texinfo -*-
## @deftypefn {Function File} {} imarithmetics ()
## This is a private function common to the likes of imadd, imsubtract, etc.
##
## First argument is the function name for the error message, while the others are
## the same order as the original function. It returns the two first input of the
## original function
## @end deftypefn

function [img, val] = imarithmetics (func, img, val, out_class, in_args)

  is_valid = @(x) ((!isnumeric (x) && !islogical (x)) || isempty (x) || issparse (x) || !isreal (x));

  if (is_valid (img) || is_valid (val))
    error ("%s: input must be a numeric or logical, non-empty, non-sparse real matrix", func)
  elseif (!ischar (out_class))
    error ("%s: third argument must be a string that specifies the output class", func)
  endif

  same_size = all (size (img) == size (val));
  if (same_size && strcmpi (class (img), class (val)))
    [img, val] = convert (out_class, img, val);

  ## multiplication doesn't require same input class and output class defaults to
  ## whatever input class is not logical (first img, then val)
  elseif (strcmp (func, "immultiply") && same_size)
    if (in_args > 2)
      ## user defined, do nothing
    elseif (islogical (img) && !islogical (val))
      out_class = class (val);
    endif
    [img, val] = convert (out_class, img, val);
  elseif (isscalar (val) && isfloat (val) && !strcmp (func, "imabsdiff"))
    ## according to matlab's documentation, if val is not an image of same size
    ## and class as img, then it must be a double scalar. But why not also support
    ## a single scalar and use isfloat?
    img = convert (out_class, img);
  else
    error ("%s: second argument must either be of same class and size of the first or a floating point scalar", func)
  end
endfunction

function [a, b] = convert (out_class, a, b = 0)
  ## in the case that we only want to convert one matrix, this subfunction is called
  ## with 2 arguments only. Then, b takes the value of zero so that the call to the
  ## functions that change the class is insignificant
  if ((nargin == 3 && any (!strcmpi ({class(a), class(b)}, out_class))) || (nargin == 2 && !strcmpi (class (a), out_class)))
    switch tolower (out_class)
      case {"logical"}  a = logical (a); b = logical (b);
      case {"uint8"}    a = uint8   (a); b = uint8   (b);
      case {"uint16"}   a = uint16  (a); b = uint16  (b);
      case {"uint32"}   a = uint32  (a); b = uint32  (b);
      case {"uint64"}   a = uint64  (a); b = uint64  (b);
      case {"int8"}     a = int8    (a); b = int8    (b);
      case {"int16"}    a = int16   (a); b = int16   (b);
      case {"int32"}    a = int32   (a); b = int32   (b);
      case {"int64"}    a = int64   (a); b = int64   (b);
      case {"double"}   a = double  (a); b = double  (b);
      case {"single"}   a = single  (a); b = single  (b);
      otherwise
        error ("%s: requested class '%s' for output is not supported", func, out_class)
    endswitch
  endif
endfunction
