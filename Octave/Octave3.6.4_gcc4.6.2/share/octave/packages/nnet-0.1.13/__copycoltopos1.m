## Copyright (C) 2008 Michel D. Schmid  <michaelschmid@users.sourceforge.net>
##
##
## This program is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## This program is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; see the file COPYING.  If not, see
## <http://www.gnu.org/licenses/>.

## -*- texinfo -*-
## @deftypefn {Function File} {} @var{retmatrix} = __copycoltopos1(@var{matrix},@var{colIndex})
## @code{__copycoltopos1} copies the column of position colIndex to the first position.
## Moves the rest of the matrix one position to the right.
## @end deftypefn

## Author: mds

function retmatrix = __copycoltopos1(matrix,colIndex)

  ## check number of inputs
  error(nargchk(2,2,nargin));

  temp = matrix(:,colIndex);
  matrix(:,colIndex) = []; # delete col
  retmatrix = [temp matrix ];

endfunction

%!shared a, retmat
%! disp("testing __copycoltopos1")
%! a = [0 1 2 3 4; 5 6 7 8 9];
%! retmat = __copycoltopos1(a,3);
%!assert(retmat(1,1)==2);
%!assert(retmat(2,1)==7);
%! retmat = __copycoltopos1(a,5);
%!assert(retmat(1,1)==4);
%!assert(retmat(2,1)==9);
