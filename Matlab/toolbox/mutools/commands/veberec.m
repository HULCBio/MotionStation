% function out = veberec(matin)
%
%  element-by-element reciprocal for
%  VARYING matrices

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

function out = veberec(matin)

  if nargin == 0
    disp('usage: out = veberec(matin)');
    return
  end

  [mtype,mrows,mcols,mnum] = minfo(matin);
  if strcmp(mtype,'vary')
    out = matin;
    out(1:mrows*mnum,1:mcols) = ...
	 ones(mrows*mnum,mcols)./matin(1:mrows*mnum,1:mcols);
  elseif strcmp(mtype,'cons')
    out(1:mrows,1:mcols) = ones(mrows,mcols)./matin(1:mrows,1:mcols);
  elseif strcmp(mtype,'empt')
    out = [];
  else
    disp('MATIN must be VARYING, CONSTANT or EMPTY')
  end