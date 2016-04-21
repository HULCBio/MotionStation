%function [indv,err] = getiv(mat,iv_index)
%
%   Returns the INDEPENDENT VARIABLE values of the
%   VARYING matrix MAT. The INDEPENDENT VARIABLE is
%   returned as a column vector, and ERR = 0. If MAT
%   is not a VARYING matrix, then INDV is empty,
%   and ERR = 1.  With two arguments, it returns only
%   the independent variables associated with the
%   positive integer vector of indices, IV_INDEX.
%
%   See also: INDVCMP, SORT, SORTIV, TACKON, XTRACT, and XTRACTI

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [indv,err] = getiv(mat,iv_index)
  if nargin <1
    disp('usage: [indv,err] = getiv(mat)');
    return
  elseif nargin == 1
    err = 0;
    [type,rows,cols,num] = minfo(mat);
    if strcmp(type,'vary')
      indv = mat(1:num,cols+1);
    else
      indv = [];
      err = 1;
    end
  elseif nargin == 2
    if min(iv_index) < 1 | any(ceil(iv_index) ~= floor(iv_index))
      error('IV_INDEX should be positive integers');
      return
    else
      [type,rows,cols,num] = minfo(mat);
      if strcmp(type,'vary')
        if max(iv_index) > num
          error('IV_INDEX exceeds the data points in MAT');
          return
        else
          indv = mat(iv_index(:),cols+1);
        end
      else
        indv = [];
        err = 1;
      end
    end
  end