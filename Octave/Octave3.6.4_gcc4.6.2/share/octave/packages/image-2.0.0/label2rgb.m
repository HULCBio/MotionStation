## Copyright (C) 2006 Søren Hauberg <soren@hauberg.org>
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
## @deftypefn {Function File} @var{RGB} = label2rgb(@var{L})
## @deftypefnx{Function File} @var{RGB} = label2rgb(@var{L}, @var{map})
## @deftypefnx{Function File} @var{RGB} = label2rgb(@var{L}, @var{map}, @var{background})
## @deftypefnx{Function File} @var{RGB} = label2rgb(@var{L}, @var{map}, @var{background}, @var{order})
## Converts a labeled image to an RGB image.
##
## label2rgb(@var{L}) returns a color image, where the background color
## (the background is the zero-labeled pixels) is white, and all other
## colors come from the @code{jet} colormap.
##
## label2rgb(@var{L}, @var{map}) uses colors from the given colormap.
## @var{map} can be
## @itemize
## @item A string containing the name of a function to be called to
## produce a colormap. The default value is "jet".
## @item A handle to a function to be called to produce a colormap.
## @item A @var{N}-by-3 colormap matrix.
## @end itemize
##
## label2rgb(@var{L}, @var{map}, @var{background}) sets the background
## color. @var{background} can be a 3-vector corresponding to the wanted
## RGB color, or one of the following strings
## @table @samp
## @item "b"
## The background color will be blue.
## @item "c"
## The background color will be cyan.
## @item "g"
## The background color will be green.
## @item "k"
## The background color will be black.
## @item "m"
## The background color will be magenta.
## @item "r"
## The background color will be red.
## @item "w"
## The background color will be white. This is the default behavior.
## @item "y"
## The background color will be yellow.
## @end table
##
## label2rgb(@var{L}, @var{map}, @var{background}, @var{order}) allows for random
## permutations of the colormap. @var{order} must be one of the following strings
## @table @samp
## @item "noshuffle"
## The colormap is not permuted in any ways. This is the default.
## @item "shuffle"
## The used colormap is permuted randomly.
## @end table
## @seealso{bwlabel, ind2rgb}
## @end deftypefn

function rgb = label2rgb(L, map = "jet", background = "w", order = "noshuffle")
  ## Input checking
  if (nargin < 1)
    print_usage();
  endif
  if ( !ismatrix(L) || ndims(L) != 2 || any(L(:) != round(L(:))) || any(L(:) < 0) )
    error("label2rgb: first input argument must be a labelled image");
  endif
  if ( !ischar(map) && !isa(map, "function_handle") && !(ismatrix(map) && ndims(map)==2 && columns(map)==3) )
    error("label2rgb: second input argument must be a color map or a function that can generate a colormap");
  endif
  if ( !ischar(background) && !(isreal(background) && numel(background)==3) )
    error("label2rgb: third input argument must be a color given as a string or a 3-vector");
  endif
  if ( !any(strcmpi(order, {"noshuffle", "shuffle"})) )
    error("label2rgb: fourth input argument must be either 'noshuffle' or 'shuffle'");
  endif
  
  ## Convert map to a matrix if needed
  num_objects = max(L(:));
  if (ischar(map) || isa(map, "function_handle"))
    map = feval(map, num_objects+1);
  endif

  num_colors  = rows(map);
  if (num_objects > num_colors)
    warning("label2rgb: number of objects exceeds number of colors in the colormap");
  endif

  ## Handle the background color
  if (ischar(background))
    switch (background(1))
      case 'b' background = [0, 0, 1];
      case 'c' background = [0, 1, 1];
      case 'g' background = [0, 1, 0];
      case 'k' background = [0, 0, 0];
      case 'm' background = [1, 0, 1];
      case 'r' background = [1, 0, 0];
      case 'w' background = [1, 1, 1];
      case 'y' background = [1, 1, 0];
      otherwise
        error("label2rgb: unknown background color '%s'", background);
    endswitch
  endif
  background = background(:)';
  if (min(background) < 0 || max(background) > 1)
    error("label2rgb: the background color must be in the interval [0, 1]");
  endif
  
  ## Should we shuffle the colormap?
  if (strcmpi(order, "shuffle"))
    r = rows(map);
    map = map(randperm(r),:);
  endif
  
  ## If the background color is in the color map: remove it
  idx = find((map(:,1) == background(1)) & (map(:,2) == background(2)) & (map(:,3) == background(3)));
  if (!isempty(idx))
    map(idx, :) = [];
  endif
  
  ## Insert the background color as the first element in the color map
  map = [background; map];
  
  ## Convert L to an RGB image
  rgb = ind2rgb(L+1, map);
  rgb /= max(rgb(:));
  rgb = uint8(255*rgb);
endfunction
