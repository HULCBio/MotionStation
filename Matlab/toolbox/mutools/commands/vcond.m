% function out = vcond(mat)
%
%   Condition number of a VARYING/CONSTANT matrix,
%   identical to MATLAB's COND command, but works
%   with VARYING matrices also.
%
%   See also: COND, VEBE, VEVAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vcond(mat)
  if nargin == 0
    disp('usage: out = vcond(mat)')
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  [nr,nc] = size(mat);
    if mtype == 'cons'
      out = cond(mat);
    elseif mtype == 'vary'
      npts = mnum;
      nrout = 1;
      ncout = 1;
      out = zeros(npts+1,ncout+1);
      out(npts+1,ncout+1) = inf;
      out(npts+1,ncout) = npts;
      out(1:npts,ncout+1) = mat(1:mnum,nc);
      ftop = (npts+1)*mrows;
      ptop = 1:mrows:ftop;
      ptopm1 = ptop(2:npts+1) - 1;
      for i=1:npts
        out(i,1) = cond(mat(ptop(i):ptopm1(i),1:mcols));
      end
    elseif mtype == 'syst'
      error('VCOND is undefined for SYSTEM matrices')
      return
    else
      out = [];
    end
%
%