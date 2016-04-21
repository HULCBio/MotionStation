## Copyright (C) 2004 Josep Mones i Teixidor <jmones@puntbarra.com>
## Copyright (C) 2011 Adrián del Pino <delpinonavarrete@gmail.com>
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
## @deftypefn {Function File} {@var{eul} = } bweuler (@var{BW}, @var{n})
## Calculate the Euler number of a binary image.
##
## This function calculates the Euler number @var{eul} of a binary
## image @var{BW}. This number is a scalar whose value represents the total
## number of objects in @var{BW} minus the number of holes.
##
## @var{n} is an optional argument that specifies the neighbourhood
## connectivity. Must either be 4 or 8. If omitted, defaults to 8.
##
## This function uses Bit Quads as described in "Digital Image
## Processing" to calculate euler number.
##
## References:
## W. K. Pratt, "Digital Image Processing", 3rd Edition, pp 593-595
##
## @seealso{bwmorph, bwperim, qtgetblk}
## @end deftypefn

function eul = bweuler (BW, n = 8)
  if (nargin < 1 || nargin > 2)
    print_usage;
  elseif (!isbw (BW))
    error("first argument must be a Black and White image");
  endif

  ## lut_4=(q1lut-q3lut+2*qdlut)/4;  # everything in one lut will be quicker
  ## lut_8=(q1lut-q3lut-2*qdlut)/4;  # but only the final result is divided by four 
  ## we precalculate this...         # to save more time

  if (!isnumeric (n) || !isscalar (n) || (n != 8 && n != 4))
    error("second argument must either be 4 or 8");
  elseif (n == 8)
    lut = [0; 1; 1; 0; 1; 0; -2; -1; 1; -2; 0; -1; 0; -1; -1; 0];
  elseif (n == 4)
    lut = [0; 1; 1; 0; 1; 0; 2; -1; 1; 2; 0; -1; 0; -1; -1; 0];
  endif

  ## Adding zeros to the top and left bordes to avoid errors when figures touch these borders.
  ## Notice that 1 0 is equivalent to 1 0 0 because there are implicit zeros in the bottom and right
  ##             0 1                  0 1 0
  ##                                  0 0 0 
  ## borders. Therefore, there are three one-pixel and one diagonal pixels. So, we get 3 * 1 - 2 = 1
  ## (error) instead of 6 * 1 - 2 = 4 (correct).

  BWaux  = zeros (rows (BW) + 1, columns (BW) + 1);

  for r = 1 : rows(BW)
     for c = 1 : columns (BW)
        BWaux (r + 1, c + 1) = BW (r, c);
     endfor
  endfor

  eul = sum (applylut (BWaux, lut) (:)) / 4;

endfunction

%!demo
%! A=zeros(9,10);
%! A([2,5,8],2:9)=1;
%! A(2:8,[2,9])=1
%! bweuler(A)
%! # Euler number (objects minus holes) is 1-2=-1 in an 8-like object

%!test
%! A=zeros(10,10);
%! A(2:9,3:8)=1;
%! A(4,4)=0;
%! A(8,8)=0; # not a hole
%! A(6,6)=0;
%! assert(bweuler(A),-1);

%!# This will test if n=4 and n=8 behave differently
%!test
%! A=zeros(10,10);
%! A(2:4,2:4)=1;
%! A(5:8,5:8)=1;
%! assert(bweuler(A,4),2);
%! assert(bweuler(A,8),1);
%! assert(bweuler(A),1);
