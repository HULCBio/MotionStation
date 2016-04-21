% function numinputs = unum(mat)
%
%   Returns number of inputs of SYSTEM matrix.
%   Returns column dimension of a CONSTANT matrix.
%   Returns column dimension of a VARYING matrix.
%   Returns 0 for a EMPTY matrix.
%
%   See also: MINFO, XNUM, YNUM.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function numinputs = unum(mat)
  if nargin == 0
    disp('usage: numinputs = unum(mat)');
  else
    [mtype,mrows,mcols,mnum] = minfo(mat);
    if strcmp(mtype,'empt')
      numinputs = 0;
    else
      numinputs = mcols;
    end
  end