## Copyright (C) 1999, 2000 Kai Habel <kai.habel@gmx.de>
## Copyright (C) 2011, 2012 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} {@var{I} =} mat2gray (@var{M})
## @deftypefnx {Function File} {@var{I} =} mat2gray (@var{M}, [@var{min} @var{max}])
## Convert a matrix to an intensity image.
##
## The returned matrix @var{I} is a grayscale image, of double class and in the
## range of values [0, 1]. The optional arguments @var{min} and @var{max} will
## set the limits of the conversion; values in @var{M} below @var{min} and
## above @var{max} will be set to 0 and 1 on @var{I} respectively.
##
## @var{max} and @var{min} default to the maximum and minimum values of @var{M}.
##
## If @var{min} is larger than @var{max}, the `inverse' will be returned. Values
## in @var{M} above @var{max} will be set to 0 while the ones below @var{min}
## will be set to 1.
##
## @strong{Caution:} For compatibility with @sc{matlab}, if @var{min} and @var{max}
## are equal (either from being actually being set manually or automatically
## calculated from the @var{M} min and max values, Octave's mat2gray will truncate
## all values between [0 1]. For example
##
## @example
## @group
## mat2gray ([-2 0 0.5 0.9 5], [2 2])
##      @result{} [0  0  0.5  0.9  1]
## mat2gray ([0.5 0.5 0.5])
##      @result{} [0.5  0.5  0.5]
## mat2gray ([4 4 4])
##      @result{} [1  1  1]
## @end group
## @end example
##
## @seealso{gray2ind, ind2gray, rgb2gray, im2double, im2uin16, im2uint8, im2int16}
## @end deftypefn

function in = mat2gray (in, scale)

  if (nargin < 1 || nargin > 2)
    print_usage;
  elseif (!ismatrix (in) || ischar(in))
    error ("mat2gray: first argument must be a matrix");
  elseif (nargin == 2 && (!isvector (scale) || numel (scale) != 2))
    error ("mat2gray: second argument must be a vector with 2 elements");
  endif

  if (nargin == 1)
    out_min = min (in(:));
    out_max = max (in(:));
  else
    ## see more at the end for the cases where max and min are swapped
    out_min = min (scale (1), scale (2));
    out_max = max (scale (1), scale (2));
  endif

  ## since max() and min() return a value of same class as input,
  ## need to make this values double or the calculations later may fail
  out_min = double (out_min);
  out_max = double (out_max);

  ## if max and min are the same, matlab seems to simple truncate the input
  ## between 0 and 1, and ignores the min/max values set. Don't get the logic
  ## but hey! Matlab compatibility
  if (out_min == out_max)
    in(in>1) = 1;
    in(in<0) = 0;
    return
  endif

  ## we are editing the input matrix rather than creating a new one to save
  ## memory. We need to make sure it's double though
  in = double(in);

  ## it's faster to get the index of values between max and min only once
  ## than to have it calculated on both sides of the assignment later on. We
  ## need to get the index before starting editing
  idx = (in > out_min & in < out_max);

  in(in <= out_min) = 0;
  in(in >= out_max) = 1;
  in(idx) = (1/(out_max - out_min)) * (double(in(idx)) - out_min);

  ## if the given min and max are in the inverse order...
  if (nargin > 1 && scale(1) > scale (2))
    ## matlab seems to allow setting the min higher than the max but not by
    ## checking which one is actually correct. Seems to just invert it
    in = abs (in - 1);
  endif

endfunction

%!assert(mat2gray([1 2 3]), [0 0.5 1]);           # standard use
%!assert(mat2gray(repmat ([1 2; 3 3], [1 1 3])), repmat ([0 0.5; 1 1], [1 1 3])); # setting min and max
%!assert(mat2gray([1 2 3], [2 2]), [1 1 1]);      # equal min and max
%!assert(mat2gray([-1 0 0.5 3], [2 2]), [0 0 0.5 1]);      # equal min and max
%!assert(mat2gray(ones(3*0.5)), ones(3*0.5));      # equal min and max from the image (not set)
%!assert(mat2gray([1 2 3], [3 1]), [1 0.5 0]);    # max and min inverted
