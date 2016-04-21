% function out = crand(dim1,dim2)
%
%   Complex random matrix generator: generates a complex,
%   random matrix with a uniform distribution of dimension
%   DIM1 x DIM2. If only one dimension argument is given,
%   the output matrix is square.
%
%   See also: CRANDN, RAND, RANDN and SYSRAND.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [out] = crand(dim1,dim2)

matlab_ver = version;
  if nargin == 2
    if strcmp(matlab_ver(1),num2str(3))
      rand('uniform')
      out = rand(dim1,dim2) + sqrt(-1)*rand(dim1,dim2);  %version 3
    else
      out = rand(dim1,dim2) + sqrt(-1)*rand(dim1,dim2);  %version 4
    end
  elseif nargin == 1
    if strcmp(matlab_ver(1),num2str(3))
      rand('uniform')
      out = rand(dim1) + sqrt(-1)*rand(dim1);  %version 3
    else
      out = rand(dim1) + sqrt(-1)*rand(dim1);  %version 4
    end
  else
    disp('usage: out = crand(dim1,dim2)')
  end
%
%