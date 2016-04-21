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
## @deftypefn {Function File} {}[@var{mTrain}, @var{mTest}, @var{mVali}] = subset (@var{mData},@var{nTargets},@var{iOpti},@var{fTest},@var{fVali})
## @code{subset} splits the main data matrix which contains inputs and targets into 2 or 3 subsets
## depending on the parameters. 
##
## The first parameter @var{mData} must be in row order. This means if the network
## contains three inputs, the matrix must be have 3 rows and x columns to define the
## data for the inputs. And some more rows for the outputs (targets), e.g. a neural network
## with three inputs and two outputs must have 5 rows with x columns!
## The second parameter @var{nTargets} defines the number or rows which contains the target values!
## The third argument @code{iOpti} is optional and can have three status:
## 	   0: no optimization
##     1: will randomise the column order and order the columns containing min and max values to be in the train set
##     2: will NOT randomise the column order, but order the columns containing min and max values to be in the train set
##	   default value is @code{1}
## The fourth argument @code{fTest} is also optional and defines how 
## much data sets will be in the test set. Default value is @code{1/3}
## The fifth parameter @code{fTrain} is also optional and defines how
## much data sets will be in the train set. Default value is @code{1/6}
## So we have 50% of all data sets which are for training with the default values.
##
## @example
##   [mTrain, mTest] = subset(mData,1)
##   returns three subsets of the complete matrix
##   with randomized and optimized columns!
## @end example
## @example
##   [mTrain, mTest] = subset(mData,1,)
##   returns two subsets
## @end example
##
## @end deftypefn

## Author: Michel D. Schmid


function [mTrain, mTest, mVali] = subset(mData,nTargets,iOpti,fTest,fVali)

  ## check range of input arguments
  error(nargchk(2,5,nargin))
  
  ## check the input arguments ...!
  if (nTargets==0)
    error("No TARGETS defined! This doesn't make any sense for feed-forward neural networks! Please define at least one row of targets")
  endif

  ## set default values
  if (nargin==2)
    iOpti = 1;
    fTest = 1/3;
    fVali = 1/6;
  elseif (nargin==3)
    fTest = 1/3;
    fVali = 1/6;
  elseif (nargin==4)
    ## if fTest is set and nothing is set
    ## for fVali I assume that fVali is not used!
    fVali = 0;
  endif
  
  ## calculate the number of train, test and validation sets
  fTrain = 1-fTest-fVali;
  nTrainSets = floor(size(mData,2)*fTrain);
  diffRestSets = size(mData,2)-nTrainSets;
  nTestSets = floor(size(mData,2)*fTest);
  nValiSets = size(mData,2)-nTrainSets-nTestSets;


  ## now let's see if matrix must be optimized!
  bOptiAgain = 1;
  while (bOptiAgain)
    if (iOpti == 1)
    # check that only one optimizing run is enough!!
    # maybe it's necessary to do it twice ..!
    # check that all min and max values are in the train set ...!
      mData = __optimizedatasets(mData,nTrainSets,nTargets,iOpti);
      mTrain = mData(:,1:nTrainSets);
      iRuns = size(mTrain,1);
      i = 1;
      j = 1;
      while (i < iRuns)
    	  if ( max(mTrain(i,:)) == max(mData(i,:)) )
    	    j += 1;
    	  endif
    	  i +=1;
      endwhile
      if (i==j)
        bOptiAgain = 0;
      endif
    elseif (iOpti == 2)
      # check that only one optimizing run is enough!!
      # maybe it's necessary to do it twice ..!
      # check that all min and max values are in the train set ...!
      mData = __optimizedatasets(mData,nTrainSets,nTargets,iOpti);
      mTrain = mData(:,1:nTrainSets);
      iRuns = size(mTrain,1);
      j = 1;
      i = 1;
      while (i < iRuns)
    	  if (max(mTrain(i,:))==max(mData(i,:)))
			j += 1;
    	  endif
    	  i += 1;
      endwhile
      if (i==j)
        bOptiAgain = 0;
      endif
    else
      ## in this case, iOpti must be 0 ==> nothing todo
      bOptiAgain = 0;
    endif
  endwhile #END OF while(bOptiAgain)

  ## now split up 
  if (nargout==1)
    mTrain = mData;
  elseif (nargout==2);
    mTrain = mData(:,1:nTrainSets);
    mTest = mData(:,nTrainSets+1:nTrainSets+nTestSets);
  elseif (nargout==3)
    mTrain = mData(:,1:nTrainSets);
    mTest = mData(:,nTrainSets+1:nTrainSets+nTestSets);
    mVali = mData(:,nTrainSets+nTestSets+1:end);
  endif

endfunction

%!shared matrix, nTargets, mTrain, mTest, mVali
%! disp("testing subset")
%! matrix = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 18 20; \
%!			 0 2 4 1 3 5 3 4 1 -1 -2 -9 -1 10 12 20 11 11 11 11; \
%!			-2 2 2 2 2 0 0 0 0  0 10 12 13 12 13 44 33 32 98 11; \
%!			 0 0 0 0 1 1 1 1 0  0  1  1  1  0  0  1  1  1  0  0; \
%!           4 4 4 4 4 4 4 4 4  4  4  4  4  4  4  4  4  4  4  4; \
%!           1 2 3 4 5 6 7 8 9 10 11 12 13 33 44 55 66 77 88 99];
%! nTargets = 1; # the last row is equivalent to the target values.
%! [mTrain, mTest, mVali] = subset(matrix,nTargets);  ############################
%!assert(size(mTrain,2)==10);# 50% of 20
%!assert(size(mTest,2)==6);# 1/3 of 20 = 6 (floor)
%!assert(size(mVali,2)==4);# 1/6 of 20 = 4 (floor)
%! # It's not possible to test the column order with this call!
%! # randomizing is used! But all max and min values should be
%! # in the training set
%!assert(max(mTrain(1,:))==max(matrix(1,:)));
%!assert(min(mTrain(1,:))==min(matrix(1,:)));
%!assert(max(mTrain(2,:))==max(matrix(2,:)));
%!assert(min(mTrain(2,:))==min(matrix(2,:)));
%!assert(max(mTrain(3,:))==max(matrix(3,:)));
%!assert(min(mTrain(3,:))==min(matrix(3,:)));
%!assert(max(mTrain(4,:))==max(matrix(4,:)));
%!assert(min(mTrain(4,:))==min(matrix(4,:)));
%!
%!
%! [mTrain, mTest, mVali] = subset(matrix,nTargets,0);  ############################
%!assert(size(mTrain,2)==10);# 50% of 20
%!assert(size(mTest,2)==6);# 1/3 of 20 = 6 (floor)
%!assert(size(mVali,2)==4);# 1/6 of 20 = 4 (floor)
%!assert(mTrain==matrix(:,1:10));
%!assert(mTest==matrix(:,11:16));
%!assert(mVali==matrix(:,17:20));
%!
%!
%! [mTrain, mTest, mVali] = subset(matrix,nTargets,2);  ############################
%!assert(size(mTrain,2)==10);# 50% of 20
%!assert(size(mTest,2)==6);# 1/3 of 20 = 6 (floor)
%!assert(size(mVali,2)==4);# 1/6 of 20 = 4 (floor)
%!assert(max(mTrain(1,:))==max(matrix(1,:)));
%!assert(min(mTrain(1,:))==min(matrix(1,:)));
%!assert(max(mTrain(2,:))==max(matrix(2,:)));
%!assert(min(mTrain(2,:))==min(matrix(2,:)));
%!assert(max(mTrain(3,:))==max(matrix(3,:)));
%!assert(min(mTrain(3,:))==min(matrix(3,:)));
%!assert(max(mTrain(4,:))==max(matrix(4,:)));
%!assert(min(mTrain(4,:))==min(matrix(4,:)));
%!
%!
%! ## next test ... optimize twice
%! matrix = [1 2 3 4 5 6 7 20 8 10 11 12 13 14 15 16 17 18 18 9; \
%!			 0 2 4 1 3 5 3 4 1 -1 -2 -9 -1 10 12 20 11 11 11 11; \
%!			-2 2 2 2 2 0 0 0 0  0 10 12 13 12 13 44 33 32 98 11; \
%!			 0 0 0 0 1 1 1 1 0  0  1  1  1  0  0  1  1  1  0  0; \
%!           4 4 4 4 4 4 4 4 4  4  4  4  4  4  4  4  4  4  4  4; \
%!           1 2 3 4 5 6 7 8 9 10 11 12 13 33 44 55 66 77 88 99];
%! [mTrain, mTest, mVali] = subset(matrix,nTargets,2);  ############################
%!assert(max(mTrain(1,:))==max(matrix(1,:)));
%!assert(min(mTrain(1,:))==min(matrix(1,:)));
%!assert(max(mTrain(2,:))==max(matrix(2,:)));
%!assert(min(mTrain(2,:))==min(matrix(2,:)));
%!assert(max(mTrain(3,:))==max(matrix(3,:)));
%!assert(min(mTrain(3,:))==min(matrix(3,:)));
%!assert(max(mTrain(4,:))==max(matrix(4,:)));
%!assert(min(mTrain(4,:))==min(matrix(4,:)));

## \todo, a lot of tests to be sure, everything is working OK!!
## all combinations of arguments must be testet!
