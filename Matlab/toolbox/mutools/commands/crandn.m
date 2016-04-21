% function out = crandn(dim1,dim2)
%
%   Complex random matrix generator: generates a complex,
%   random matrix with a normal distribution of dimension
%   DIM1 x DIM2. If only one dimension argument is given,
%   the output matrix is square.
%
%   See also: CRAND, RAND, RANDN and SYSRAND.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out] = crandn(dim1,dim2)

matlab_ver = version;
  if nargin == 2
    if strcmp(matlab_ver(1),num2str(3))
    %  rand('normal')
      out = rand(dim1,dim2) + sqrt(-1)*rand(dim1,dim2);   %version 3
    else
      out = randn(dim1,dim2) + sqrt(-1)*randn(dim1,dim2); %version 4
    end
  elseif nargin == 1
    if strcmp(matlab_ver(1),num2str(3))
    %  rand('normal')
      out = rand(dim1) + sqrt(-1)*rand(dim1);    %version 3
    else
      out = randn(dim1) + sqrt(-1)*randn(dim1);  %version 4
    end
  else
    disp('usage: out = crandn(dim1,dim2)')
  end
%
%