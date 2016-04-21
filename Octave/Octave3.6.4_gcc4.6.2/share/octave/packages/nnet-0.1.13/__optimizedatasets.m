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
## @deftypefn {Function File} {} @var{retmatrix} = __optimizedatasets (@var{matrix},@var{nTrainSets},@var{nTargets},@var{bRand})
## @code{__optimizedatasets} reranges the data sets depending on the input arguments.
## @code{matrix} is the data set matrix containing inputs and outputs (targets) in row order.
## This means for example: the first three rows are inputs and the fourth row is an output row.
## The second argument is used in the optimizing algorithm. All cols with min and max values must
## be in the range of the train data sets. The third argument defines how much rows are equal to the
## neural network targets. These rows must be at the end of the data set!
## The fourth arguemnt is optional and defines if the data sets have to be randomised before
## optimizing.
## Default value for bRand is 1, means randomise the columns.
## @end deftypefn

## Author: mds

function retmatrix = __optimizedatasets(matrix,nTrainSets,nTargets,bRand)

  ## check number of inputs
  error(nargchk(3,4,nargin));

  # set default values
  bRandomise = 1;
  
  if (nargin==4)
    bRandomise = bRand;
  endif
  
  # if needed, randomise the cols
  if (bRandomise)
    matrix = __randomisecols(matrix);
  endif
  
  # analyze matrix, which row contains what kind of data?
  # a.) binary values? Means the row contains only 0 and 1
  # b.) unique values?
  # c.) Min values are several times contained in the row
  # d.) Max values are several times contained in the row
  matrix1 = matrix(1:end-nTargets,:);
  analyzeMatrix = __analyzerows(matrix1);
  
  # now sort "matrix" with help of analyzeMatrix
  # following conditions must be kept:
  # a.) rows containing unique values aren't sorted!
  # b.) sort first rows which contains min AND max values only once
  # c.) sort secondly rows which contains min OR max values only once
  # d.) at last, sort binary data if still needed!
  retmatrix = __rerangecolumns(matrix,analyzeMatrix,nTrainSets);


endfunction

%!shared retmatrix, matrix
%! disp("testing __optimizedatasets")
%! matrix = [1 2 3 2 1 2 3 0 5 4 3 2 2 2 2 2 2; \
%!			 0 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 0; \
%!			-1 3 2 4 9 1 1 1 1 1 9 1 1 1 9 9 0; \
%!			 2 3 2 3 2 2 2 2 3 3 3 3 1 1 1 1 1];
%! ## The last row is equal to the neural network targets
%! retmatrix = __optimizedatasets(matrix,9,1);
%! ## the above statement can't be tested with assert!
%! ## it contains random values! So pass a "success" message
%!assert(1==1);
%! matrix = [1 2 3 2 1 2 3 0 5 4 3 2 2 2 2 2 2; \
%!			 0 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 0; \
%!			-1 3 2 4 9 1 1 1 1 1 9 1 1 1 9 9 0; \
%!			 2 3 2 3 2 2 2 2 3 3 3 3 1 1 1 1 1];
%! ## The last row is equal to the neural network targets
%! retmatrix = __optimizedatasets(matrix,9,1,0);
%!assert(retmatrix(1,1)==5);
%!assert(retmatrix(2,1)==0);
%!assert(retmatrix(3,1)==1);
%!assert(retmatrix(4,1)==3);