## Copyright (C) 2009 Luiz Angelo Daros de Luca <luizluca@gmail.com>
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
## @deftypefn {Function File} [@var{trainVectors},@var{validationVectors},@var{testVectors},@var{indexOfTrain},@var{indexOfValidation},@var{indexOfTest}] = dividerand (@var{allCases},@var{trainRatio},@var{valRatio},@var{testRatio})
## Divide the vectors in training, validation and test group according to
## the informed ratios
##
##
## @example
##
## [trainVectors,validationVectors,testVectors,indexOfTrain,indexOfValidatio
## n,indexOfTest] = dividerand(allCases,trainRatio,valRatio,testRatio)
##
## The ratios are normalized. This way:
##
## dividerand(xx,1,2,3) == dividerand(xx,10,20,30)
##
## @end example
##
## @end deftypefn


function [trainVectors,validationVectors,testVectors,indexOfTrain,indexOfValidation,indexOfTest] = dividerand(allCases,trainRatio,valRatio,testRatio)
  #
  # Divide the vectors in training, validation and test group according to
  # the informed ratios
  #
  # [trainVectors,validationVectors,testVectors,indexOfTrain,indexOfValidatio
  # n,indexOfTest] = dividerand(allCases,trainRatio,valRatio,testRatio)
  #
  # The ratios are normalized. This way:
  #
  # dividerand(xx,1,2,3) == dividerand(xx,10,20,30)
  #

  ## Normalize ratios
  total = trainRatio + valRatio + testRatio;
  #trainRatio = trainRatio / total; not used
  validationRatio = valRatio / total;
  testRatio = testRatio / total;

  ## Calculate the number of cases for each type
  numerOfCases = size(allCases,2);
  numberOfValidation = floor(validationRatio*numerOfCases);
  numberOfTest = floor(testRatio*numerOfCases);
  numberOfTrain = numerOfCases - numberOfValidation - numberOfTest;

  ## Find their indexes
  indexOfAll=randperm(numerOfCases);
  indexOfValidation=sort(indexOfAll(1:numberOfValidation));
  indexOfTest=sort(indexOfAll((1:numberOfTest)+numberOfValidation));
  indexOfTrain=sort(indexOfAll((1:numberOfTrain)+numberOfTest+numberOfValidation));

  ## Return vectors
  trainVectors = allCases(:,indexOfTrain);
  testVectors = allCases(:,indexOfTest);
  validationVectors = allCases(:,indexOfValidation);
endfunction

