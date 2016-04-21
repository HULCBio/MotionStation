% function [iv_value,iv_index] = vfind(condition,mat)
%
%   Unary FIND function across INDEPENDENT VARIABLE.  The
%   variable condition can be any valid MATLAB conditional
%   statement, using the string 'mat' to identify the matrix,
%   and 'iv' as the independent variable's value.  Both the
%   VALUES and INDICES of the applicable independent variables
%   are returned.
%
%   See also: XTRACT, XTRACTI, and FIND.

%     EXAMPLE: Suppose that MATIN is a VARYING matrix.  In
%		   order to find those entries for which the product of
%		   the norm of the matrix, and the independent variable is
%		   greater than 2, use VFIND as:
%
%		   >> [iv_value,iv_index] = vfind('iv*norm(mat)>2',MATIN);
%		   >> matprop = xtract(mat,iv_value);  % extract by value
%        or
%		   >> matprop = xtracti(mat,iv_index); % extract by index

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [iv_val,iv_ind] = vfind(condstr,arg1)


  if nargin < 2
    disp('usage: [iv_value,iv_index] = vfind(condition,mat)');
    return
  end

  [mtype,mrows,mcols,mnum] = minfo(arg1);
  if strcmp(mtype,'vary')
    tmpoutval = zeros(mnum,1);
    tmpoutind = zeros(mnum,1);
    cnt = 0;

    for i=1:mnum
      mat = arg1((i-1)*mrows+1:i*mrows,1:mcols);
      iv = arg1(i,mcols+1);
      if (eval(condstr))
        tmpoutval(cnt+1,1) = iv;
        tmpoutind(cnt+1,1) = i;
        cnt = cnt+1;
      end
    end
    iv_val = tmpoutval(1:cnt);
    iv_ind = tmpoutind(1:cnt);
  else
    iv_val = [];
    iv_ind = [];
  end
%
%