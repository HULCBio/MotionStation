% function [matout,ivval] = var2con(mat,desiv)
%
%   VARYING to CONSTANT matrix conversion. If there is
%   one input argument, MAT, and it is a VARYING matrix, then
%   the output MATOUT is the CONSTANT matrix in MAT associated
%   with the INDEPENDENT VARIABLE's first value. The optional
%   second output argument is this INDEPENDENT VARIABLE's value.
%   If two input arguments are used, then it is assumed that
%   the first is a VARYING matrix, and the second is a
%   desired INDEPENDENT VARIABLE's value. The command
%   finds the matrix in MAT whose INDEPENDENT VARIABLE's
%   value is closest to DESIV, and returns this matrix
%   as a CONSTANT matrix.
%
%   See also: XTRACT and XTRACTI.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [matout,ivval] = var2con(mat,desiv)
  if nargin < 1
    disp('usage: [matout,ivval] = var2con(mat,desiv)')
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  if mtype == 'vary'
    indv = mat(1:mnum,mcols+1);
    if nargin == 2
      [val,loc] = min(abs(indv-desiv*ones(mnum,1)));
      matout = mat((loc-1)*mrows+1:mrows*loc,1:mcols);
      ivval = mat(loc,mcols+1);
    else
      matout = mat(1:mrows,1:mcols);
      ivval = mat(1,mcols+1);
    end
  elseif mtype == 'cons'
    matout = mat;
    ivval = [];
  elseif mtype == 'syst'
    error(['input is not a valid VARYING matrix'])
    return
  end
%
%