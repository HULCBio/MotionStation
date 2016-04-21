## Copyright (C) 2000 Etienne Grossmann <etienne@egdn.net>
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
## @deftypefn {Function File} {@var{b} = } bwborder (@var{im})
## Finds the borders of foreground objects in a binary image.
##
## @var{b} is the borders in the 0-1 matrix @var{im}. 4-neighborhood is considered.
## 
## A pixel is on the border if it is set in @var{im}, and it has at least one
## neighbor that is not set.
## @end deftypefn

function b = bwborder(im)

[R,C]=size(im);

b = im & ...
    !([im(2:R,:) ;  zeros(1,C) ] & ...
      [zeros(1,C); im(1:R-1,:) ] & ...
      [im(:,2:C) ,  zeros(R,1) ] & ...
      [zeros(R,1),  im(:,1:C-1)] ) ;
