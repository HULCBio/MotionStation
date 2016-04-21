## Copyright (C) 2009 Sergey Kirgizov
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
## @deftypefn {Function File} {[@var{Y}, @var{newmap}] =} imdither (@var{img})
## @deftypefnx {Function File} {[@var{Y}, @var{newmap}] =} imdither (@var{img}, @
## @var{colors})
## @deftypefnx {Function File} {[@var{Y}, @var{newmap}] =} imdither (@var{img}, @
## @var{colors}, @var{dithtype})
## @deftypefnx {Function File} {[@var{Y}, @var{newmap}] =} imdither (@var{img}, @
## @var{map})
## @deftypefnx {Function File} {[@var{Y}, @var{newmap}] =} imdither (@var{img}, @
## @var{map}, @var{colors})
## @deftypefnx {Function File} {[@var{Y}, @var{newmap}] =} imdither(@var{img}, @
## @var{map}, @var{colors}, @var{dithtype})
## Reduce the number a colors of rgb or indexed image.
##
## Note: this requires the ImageMagick "convert" utility.
## get this from www.imagemagick.org if required
## additional documentation of options is available from the
## convert man page.
##
## where
## @var{dithtype} is a value from list:
## 
## @itemize @bullet
## @item "None"
## @item "FloydSteinberg" (default)
## @item "Riemersma"
## @end itemize 
##
## @var{colors} is a maximum number of colors in result map
##
## TODO: Add facility to use already created colormap over "-remap" option
##
## BUGS: This function return a 0-based indexed images 
## when colormap size is lower or equals to 256 like at cmunique code
## @seealso{cmunique}
##
## @end deftypefn

function [Y, newmap] = imdither (im, p1, p2, p3)
  colors="256";
  dithtype="FloydSteinberg";
  if (nargin < 1)
    print_usage;
  endif

  fname = [tmpnam(),".ppm"];
  if (nargin == 1 || isscalar(p1))
                # rgb
    if (nargin >= 2)
      colors=sprintf("%d",p1);
      if (nargin >= 3)
    dithtype=p2;
      endif
    endif
    opts=["-colors ",colors;"-dither ",dithtype];
    imwrite(fname,im(:,:,1),im(:,:,2),im(:,:,3),opts);
    [Y,newmap]=cmunique(imread(fname));
    delete(fname);
  else
    if (nargin <= 1)
      print_usage;
    endif
                # indexed
    if (nargin >= 3)
      colors=sprintf("%d",p2);
      if (nargin >= 4)
    dithtype=p3;
      endif
    endif
    opts=["-colors ",colors;"-dither ",dithtype];
    im (rows(p1)<=256)
    imwrite(fname,im,(p1+1),opts);
    [Y,newmap]=cmunique(imread(fname));
    delete(fname);
  endif
endfunction
