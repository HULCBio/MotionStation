## Copyright (C) 2012 Pablo Rossi <prossi@ing.unrc.edu.ar>
## Copyright (C) 2012 Carnë Draug <carandraug+dev@gmail.com>
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
## @deftypefn {Function File} @var{cropped} = imcrop (@var{Img})
## Crop image.
##
## Displays the image @var{Img} in a figure window and waits for user to select
## two points to define the bounding box.  First click on the top left and then
## on the bottom right corner of the region.  The function will not return until
## two valid points in the correct order are selected.
##
## Returns the @var{cropped} image.
##
## @seealso{imshow}
## @end deftypefn

function col = imcrop (Img)

  handle = imshow (Img);
  [a, b] = size (Img);

  do
    [hl, rd] = ginput(2);
    if (hl(1) <= 1), hl(1) = 1; endif
    if (rd(1) <= 1), rd(1) = 1; endif
    if (hl(2) >= b), hl(2) = b; endif
    if (rd(2) >= a), rd(2) = a; endif
  until (hl(1) < hl(2) || rd(1) < rd(2))
  ## should we close the image after? Anyway, close does not accept the handle
  ## since the handle from imshow is not a figure handle
#  close (handle); 

  hl  = floor (hl);
  rd  = floor (rd);
  col = Img(rd(1):rd(2), hl(1):hl(2));
endfunction
