%function numstates = xnum(sys)
%
%   Returns number of states of SYSTEM matrix.
%   Returns 0 for a CONSTANT or EMPTY matrix,
%   and -1 for a VARYING matrix.
%
%   See also: MINFO, YNUM, UNUM.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function numstates = xnum(sys)
  if nargin == 0
    disp('usage: numstates = xnum(sys)');
  else
    [mtype,mrows,mcols,mnum] = minfo(sys);
    if strcmp(mtype,'empt')
      numstates = 0;
    elseif strcmp(mtype,'vary')
      numstates = -1;
    elseif strcmp(mtype,'cons')
      numstates = 0;
    elseif strcmp(mtype,'syst')
      numstates = mnum;
    else
      error('SYSTEM is invalid')
    end
  end