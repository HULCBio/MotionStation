%function numoutputs = ynum(mat)
%
%   Returns number of outputs of SYSTEM matrix.
%   Returns row dimension of a CONSTANT matrix.
%   Returns row dimension of a VARYING matrix.
%   Returns 0 for a EMPTY matrix.
%
%   See also: MINFO, XNUM, UNUM.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function numoutputs = ynum(mat)
  if nargin == 0
    disp('usage: numoutputs = ynum(mat)');
  else
    [mtype,mrows,mcols,mnum] = minfo(mat);
    if strcmp(mtype,'empt')
      numoutputs = 0;
    else
      numoutputs = mrows;
    end
  end