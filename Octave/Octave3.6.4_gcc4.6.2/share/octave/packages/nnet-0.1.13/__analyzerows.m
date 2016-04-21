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
## @deftypefn {Function File} {} @var{retmatrix} = __analyzerows(@var{matrix})
## @code{__analyzerows} takes a matrix as input argument and checks what kind of
## data are contained in the rows.
##   a.) binary values? Means the row contains only 0 and 1
##   b.) unique values?
##   c.) Min values are several times contained in the row
##   d.) Max values are several times contained in the row
## @end deftypefn

## Author: mds

function retmatrix = __analyzerows(matrix)

  ## check number of inputs
  error(nargchk(1,1,nargin));

  nRows = size(matrix,1);   # get number or rows
  retmatrix = zeros(nRows,4);
  doneVec = zeros(nRows,1);

  ## now let's check which rows are binary
  i = 1;
  while (i <= nRows)
    vec = matrix(i,:);
    n1 = find(vec==1);
    n0 = find(vec==0);
    if (length(n1)==0 || length(n0)==0)
      #do nothing
    else
      if (length(vec)==(length(n1)+length(n0)))
        # in this case, the vector contains only ones and zeros
        retmatrix(i,1) = 1;
        doneVec(i) = 1;
      endif
    endif
    i += 1;
  endwhile

  ## now let's check which rows are unique
  i = 1;
  while (i <= nRows)
    if (doneVec(i)==0)
      vec = matrix(i,:);
      n1 = find(vec==vec(1));
      if (length(vec)==(length(n1)))
        # in this case, the vector contains only unique data
        retmatrix(i,2) = 1;
        doneVec(i) = 1;
      endif
    endif
  i += 1;
  endwhile

  
  ## now let's check how often we can find the min value
  i = 1;
  while (i <= nRows)
	if (doneVec(i)==0)
      vec = matrix(i,:);
      n1 = min(vec);
	  retmatrix(i,3) = length(find(n1==vec));
	endif
  i += 1;
  endwhile
  
  ## now let's check how often we can find the max value
  i = 1;
  while (i <= nRows)
	if (doneVec(i)==0)
      vec = matrix(i,:);
      n1 = max(vec);
	  retmatrix(i,4) = length(find(n1==vec));
	endif
  i += 1;
  endwhile

endfunction

%!shared b, retmat
%! disp("testing __analyzerows")
%! b = [1 0 0 1; 1 0 0 0; 1 2 0 1];
%! retmat = __analyzerows(b);
%!assert(retmat(1,1)==1);#%!assert(retmat(1,1)==1);
%!assert(retmat(2,1)==1);
%!assert(retmat(3,1)==0);
%! b = [1 0 0 2; 1 0 0 0; 1 1 1 1];
%! retmat = __analyzerows(b);
%!assert(retmat(1,2)==0);
%!assert(retmat(2,2)==0);
%!assert(retmat(3,2)==1);
%! b = [1 0 0 2; 1 0 0 0; 1 1 1 1];
%! retmat = __analyzerows(b);
%!assert(retmat(1,3)==2);
%!assert(retmat(2,3)==0);
%!assert(retmat(3,3)==0);
%! retmat = __analyzerows(b);
%!assert(retmat(1,4)==1);
%!assert(retmat(2,4)==0);
%!assert(retmat(3,4)==0);
