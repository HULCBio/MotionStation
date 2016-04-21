% function out = vexpm(mat)
%
%   Matrix exponential of a VARYING/CONSTANT matrix.
%   Identical to MATLAB's EXPM command, but works
%   with VARYING matrices also.
%
%   See also: EXP, EXPM, and VEVAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vexpm(mat)
  if nargin == 0
    disp('usage: out = vexpm(mat)')
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  [nr,nc] = size(mat);
  if mrows == mcols
    if mtype == 'cons'
      out = expm(mat);
    elseif mtype == 'vary'
      indv = mat(1:mnum,mcols+1);
      npts = mnum;
      nrout = mrows;
      ncout = mcols;
      out = zeros((nrout*npts)+1,ncout+1);
      out((nrout*npts)+1,ncout+1) = inf;
      out((nrout*npts)+1,ncout) = npts;
      out(1:npts,ncout+1) = indv;

      ftop = (npts+1)*mrows;
      ptop = 1:mrows:ftop;
      ptopm1 = ptop(2:npts+1) - 1;
      for i=1:npts
        out(ptop(i):ptopm1(i),1:mcols) = ...
		  expm(mat(ptop(i):ptopm1(i),1:mcols));
      end
    elseif mtype == 'syst'
      error('VEXPM is undefined for SYSTEM matrices')
      return
    else
      out = [];
    end
  else
    if mtype == 'syst'
      error('VEXPM is undefined for SYSTEM matrices')
      return
    else
      error('input matrix must be square for VEXPM')
      return
    end
  end
%
%