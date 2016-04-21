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
## @deftypefn {Function File} {} @var{retmatrix} = __rerangecolumns (@var{matrix},@var{analyzeMatrix},@var{nTrainSets})
## @code{__rerangecolumns} reranges the data sets depending on the input arguments.
## @code{matrix} is the data set matrix containing inputs and outputs (targets) in row order.
## This means for example: the first three rows are inputs and the fourth row is an output row.
## The second argument is used in the optimizing algorithm. This matrix contains informations about
## the description of the rows data of matrix.
## The third argument is used to be sure, rerange all the columns to the correct position.
## @end deftypefn

## Author: mds

function retmatrix = __rerangecolumns(matrix,analyzeMatrix,nTrainSets)

  ## check number of inputs
  error(nargchk(3,3,nargin));

  # set default values

  # now sort "matrix" with help of analyzeMatrix
  # following conditions must be kept:
  # a.) rows containing unique values aren't sorted!
  # b.) sort first rows which contains min AND max values only once
  # c.) sort secondly rows which contains min OR max values only once
  # d.) at last, sort binary data if still needed!

  nRows = size(analyzeMatrix,1);   # get number of rows

  ## create i-vector
  i = 1;
  iVec = [];
  while (i <= nRows)
    if ( (analyzeMatrix(i,3)==1) && (analyzeMatrix(i,4)==1) )
      iVec = [iVec i];
    endif
    i += 1;
  endwhile
  i = 1;
  while (i <= nRows)
	if ( (analyzeMatrix(i,3)>1) || (analyzeMatrix(i,4)>1) )
	  iVec = [iVec i];
	endif
	i += 1;
  endwhile
  i = 1;
  while (i <= nRows)
    if (analyzeMatrix(i,1)==1)
      iVec = [iVec i];
    endif
  i += 1;
  endwhile


  ## now do main loop
  j = 1;
  i = iVec(j);
  nRows = length(iVec);
  while (j < nRows)
    if (analyzeMatrix(i,2)==1)
      # easiest case, nothing to do
    else

      # now let's see if min AND max values are only once in the row
      if ( (analyzeMatrix(i,3)==1) && (analyzeMatrix(i,4)==1) )
		# search at which index the min value is
		minVal = min(matrix(i,:));
        [rowInd, colInd] = find(matrix(i,:)==minVal);# colInd is searched
        if (colInd >= nTrainSets ) # move column
		  matrix = __copycoltopos1(matrix,colInd);
        endif
        # search at which index the max value is
        maxVal = max(matrix(i,:));
        [rowInd, colInd] = find(matrix(i,:)==maxVal);# colInd is searched
        if (colInd >= nTrainSets ) # move column
		  matrix = __copycoltopos1(matrix,colInd);
        endif

      else
        
		# now here, we have to copy the rows, if min OR max values are more than once in a row
        if ( (analyzeMatrix(i,3)>=1) || (analyzeMatrix(i,4)>=1) )

		  # search at which index the min value is
		  minVal = min(matrix(i,:));
          [rowInd, colInd] = find(matrix(i,:)==minVal);# colInd is searched
          if (colInd(1) >= nTrainSets ) # move column
		    matrix = __copycoltopos1(matrix,colInd(1));
          endif
          
          # search at which index the max value is
          maxVal = max(matrix(i,:));
          [rowInd, colInd] = find(matrix(i,:) == maxVal);# colInd is searched
          if (colInd(1) >= nTrainSets ) # move column
		    matrix = __copycoltopos1(matrix,colInd(1));
          endif

		else
		  # now sort binary data, if needed
		  
          # search at which index the 0-value is
		  [rowInd, colInd] = find(matrix(i,:)==0);# colInd is searched
          if (colInd(1) >= nTrainSets ) # move column
		    matrix = __copycoltopos1(matrix,colInd(1));
          endif
          # search at which index the 1-value is
          [rowInd, colInd] = find(matrix(i,:)==1);# colInd is searched
          if (colInd(1) >= nTrainSets ) # move column
		    matrix = __copycoltopos1(matrix,colInd(1));
          endif

        endif# END OF if ( (analyzeMatrix(i,3)>=1) || (analyzeMatrix(i,4)>=1) )

      endif # END OF if ( (analyzeMatrix(i,3)==1) AND (analyzeMatrix(i,4)==1) )

    endif # END OF if (analyzeMatrix(i,2)==1)
    j += 1;
    i = iVec(j);
  endwhile
  retmatrix = matrix;
endfunction

%!shared matrix,analyzeMatrix,nTrainSets, returnmatrix
%! disp("testing __rerangecolumns")
%! matrix = [0 1 0 0 0 0 1 0 1 1;  \
%!			 4 4 4 4 4 4 4 4 4 4;  \
%!        -1.1 -1.1 2 3 4 3.2 1 8 9 10; \
%!           0 1.1 3 4 5 2 10 10 2 3; \
%!          -1 1 1 1 1 2 3 4 1 5];
%! analyzeMatrix = [1 0 0 0; 0 1 0 0; 0 0 2 1; 0 0 1 2; 0 0 1 1];
%! nTrainSets = 8;
%! returnmatrix = __rerangecolumns(matrix,analyzeMatrix,nTrainSets);
%!assert(returnmatrix(1,1)==1);
%!assert(returnmatrix(2,1)==4);
%!assert(returnmatrix(3,1)==1);
%!assert(returnmatrix(4,1)==10);
%!assert(returnmatrix(5,1)==3);
%! matrix = [0 1 0 0 0 0 1 0 1 1; 			\
%!			 4 4 4 4 4 4 4 4 4 4; 			\
%!          -1.1 -1.1 2 3 4 3.2 1 8 9 10; 	\
%!           0 1.1 3 4 5 2 10 10 2 3; 		\
%!          -1 1 1 1 1 2 3 4 1 5;     		\
%!			 0 1 2 1 2 1 2 3 4 5;];  # the last row is euqal to the nnet targets
%! analyzeMatrix = [1 0 0 0; 0 1 0 0; 0 0 2 1; 0 0 1 2; 0 0 1 1];
%! nTrainSets = 8;
%! returnmatrix = __rerangecolumns(matrix,analyzeMatrix,nTrainSets);
%!assert(returnmatrix(1,1)==1);
%!assert(returnmatrix(2,1)==4);
%!assert(returnmatrix(3,1)==1);
%!assert(returnmatrix(4,1)==10);
%!assert(returnmatrix(5,1)==3);
%!assert(returnmatrix(6,1)==2);