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
## @deftypefn {Function File} {} imhist (@var{I})
## @deftypefnx {Function File} {} imhist (@var{I}, @var{n})
## @deftypefnx {Function File} {} imhist (@var{X}, @var{cmap})
## @deftypefnx {Function File} {[@var{counts}, @var{x}] =} imhist (@dots{})
## Produce histogram counts of image @var{I}.
##
## The second argument can either be @var{n}, a scalar that specifies the number
## of bins; or @var{cmap}, a colormap in which case @var{X} is expected to be
## an indexed image. If not specified, @var{n} defauls to 2 for binary images,
## and 256 for grayscale images.
##
## If output is requested, @var{counts} is the number of counts for each bin and
## @var{x} is a range for the bins so that @code{stem (@var{x}, @var{counts})} will
## show the histogram.
##
## Since a colorbar is not displayed under the histogram, calling this function
## to visualize the histogram of an indexed image may not be very helpful.
##
## @seealso{hist, histc, histeq}
## @end deftypefn

function [varargout] = imhist (img, b)

  ## then img can either be a "normal" or indexed image. We will need to
  ## check the second argument to find out
  indexed = false;

  if (nargin < 1 || nargin > 2)
    print_usage;

  elseif (nargin == 1)
    if (islogical (img))
      b = 2;
    else
      b = 256;
    endif

  elseif (nargin == 2)
    if (iscolormap (b))
      ## if using a colormap, image must be an indexed image
      indexed = true;
    elseif (isnumeric (b) && isscalar (b) && fix(b) == b)
      ## do nothing, all is good
      if (islogical (img) && b != 2)
        error ("there can only be 2 bins when input image is binary")
      endif
    else
      error ("second argument should either be a positive integer scalar or a colormap");
    endif
  endif

  ## check if img is good
  if (indexed)
    if (!isind(img))
      error ("second argument is a colormap but image is not indexed");
    endif
    ## an indexed image reads differently wether it's uint8/16 or double
    ## If uint8/16, index-1 is the colormap row number (there's an offset of 1)
    ## If double, index is the colormap row number (no offset)
    ## isind above already checks for double/uint8/uint16 so we can use isinteger
    ## and isfloat safely
    if ( (isfloat   (img) && max (img(:)) > rows(b)  ) ||
         (isinteger (img) && max (img(:)) > rows(b)-1) )
      warning ("largest index in image exceeds length of colormap");
    endif
  endif

  ## prepare bins
  if (indexed)
    if (isinteger (img))
      bins = 0:rows(b)-1;
    else
      bins = 1:rows(b);
    endif
  else
    if (isinteger (img))
      bins  = linspace (intmin (class (img)), intmax (class (img)), b);
    elseif (islogical (img))
      bins = 0:1;
    else
      ## image must be single or double
      bins = linspace (0, 1, b);
    endif
    ## we will use this bins with histc where they are the edges for each bin
    ## but in imhist we want them to be the center of each bin. We can't use
    ## hist either since values right in the middle will go to the bottom
    ## bin (4.5 will be placed on the bin 4 instead of 5 and this is like
    ## matlab, not an octave bug). So we still use histc but we decrease their
    ## values by half of bin width and increase it back in the end to return
    ## the values (if we did it on the image it would be only one step but
    ## would be heavier on the system since images are likely to be larger
    ## than bins)
    if (!islogical (img))
      bins -= ((bins(2) - bins(1))/2);
    endif
    ## matlab returns bins as one column instead of a row but only for non
    ## indexed images
    bins = bins';
  endif

  ## if not dealing with indexed image, we may need to make sure values are
  ## between get bin values
  if (!indexed)
    ## while integers could in no way have a value below the minium of their
    ## class, floats can have values below zero which need to be truncated
    if (isfloat (img))
      img(img < 0) = 0;
    endif
    ## because we adjusted the bins edge below the max value of the class, and
    ## because histc will not count values outside the edges, we need to bring
    ## them down (no need to worry about the min because the min edge is already
    ## below the mininum of the class). This also adjusts floats above 1
    if (max (img(:)) > bins(end))
      ## in case it's a integer, if we try to assign the non integer values it 
      ## will fail so we need to make it double. But this means it takes more
      ## memory so let's first make sure we need to
      if (fix(bins(end)) != bins(end))
        img = double (img);
      endif
      img(img > bins(end)) = bins(end);
    endif
  endif
  [nn] = histc (img(:), bins);
  if (!indexed && !islogical(img))
    bins += ((bins(2) - bins(1))/2);
  endif

  if (nargout != 0)
    varargout{1} = nn;
    varargout{2} = bins;
  else
    hold on;
    stem (bins, nn);
    colormap (gray (b));
    colorbar ("SouthOutside", "xticklabel", []);
    hold off;
  endif
endfunction

%!shared nn, bb, enn, ebb
%! [nn, bb] = imhist(logical([0 1 0 0 1]));
%!assert({nn, bb}, {[3 2]', [0 1]'})
%! [nn, bb] = imhist([0 0.2 0.4 0.9 1], 5);
%!assert({nn, bb}, {[1 1 1 0 2]', [0 0.25 0.5 0.75 1]'})
%! [nn, bb] = imhist([-2 0 0.2 0.4 0.9 1 5], 5);
%!assert({nn, bb}, {[2 1 1 0 3]', [0 0.25 0.5 0.75 1]'})
%! [nn, bb] = imhist(uint8([0 32 255]), 256);
%! enn = zeros(256, 1); enn([1, 33, 256]) = 1;
%! ebb = 0:255;
%!assert({nn, bb}, {enn, ebb'})
%! [nn, bb] = imhist(int8([-50 0 100]), 31);
%! enn = zeros(31, 1); enn([10, 16, 28]) = 1;
%! ebb = -128:8.5:127;
%!assert({nn, bb}, {enn, ebb'})
