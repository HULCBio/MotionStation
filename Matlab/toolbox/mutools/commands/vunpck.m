% function [data,rowpoint,indv,err] = vunpck(mat)
%
%   Unpacks a VARYING matrix. The values of MAT are
%   placed in the variable DATA, stacked one on top of
%   another. The value of ROWPOINT(i) points to the
%   row of DATA which corresponds to the first row of
%   the i'th value of MAT. INDV is a column vector with
%   the INDEPENDENT VARIABLE values. ERR normally is 0,
%   but equals 1 if mat is a SYSTEM matrix.
%
%   See also: GETIV, MINFO, PCK, UNPCK, VPCK, XTRACT and XTRACTI.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [data,rowpoint,indv,err] = vunpck(mat)

   if nargin ~= 1
     disp('usage: [data,rowpoint,indv,err] = vunpck(mat)')
     return
   end

  err = 0;
  [type,rows,cols,num] = minfo(mat);
  if type == 'vary'
    indv = mat(1:num,cols+1);
    rowpoint = rows*(0:num-1) + 1;
    colpoint = cols;
    data = mat(1:num*rows,1:cols);
  elseif type == 'cons'
    data = mat;
    rowpoint = rows;
    indv = [];
  else
    data = [];
    rowpoint = [];
    indv = [];
    err = 1;
  end

%
%