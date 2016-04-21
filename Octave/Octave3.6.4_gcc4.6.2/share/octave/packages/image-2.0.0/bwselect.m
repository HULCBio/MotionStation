## Copyright (C) 1999 Andy Adler <adler@sce.carleton.ca>
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
## @deftypefn {Function File} {[@var{imout}, @var{idx}] =} bwselect(@var{im}, @var{cols}, @var{rows}, @var{connect})
## Select connected regions in a binary image.
##
## @table @code
## @item @var{im}
## binary input image
## @item [@var{cols}, @var{rows}]
## vectors of starting points (x,y)
## @item @var{connect}
## connectedness 4 or 8. default is 8
## @item @var{imout}
## the image of all objects in image im that overlap
## pixels in (cols,rows)
## @item @var{idx}
## index of pixels in imout
## @end table
## @end deftypefn

function [imout, idx] = bwselect( im, cols, rows, connect )

if nargin<4
   connect= 8;
end

[jnk,idx]= bwfill( ~im, cols,rows, connect );

imout= zeros( size(jnk) );
imout( idx ) = 1;
