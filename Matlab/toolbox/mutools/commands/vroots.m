% function out = vroots(mat)
%
%   If MAT is a VARYING matrix, with either
%   1 row or 1 column, then OUT is a VARYING matrix
%   of the roots of the polynomial represented
%   by the vector. VROOTS works with identically to
%   the MATLAB function ROOTS, however it works
%   with VARYING matrices also.
%
%   See also: DET, POLY, ROOTS, VDET, and VPOLY.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vroots(mat)
  if nargin == 0
    disp('usage: out = vroots(mat)')
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  if mrows ~= 1 & mcols ~= 1
    error(['input to VROOTS should be a vector']);
    return
  end
  if mrows == 1 & mcols == 1
    out = [];
    return
  end
  if mtype == 'cons'
    out = roots(mat);
  elseif mtype == 'vary'
    indv = mat(1:mnum,mcols+1);
    npts = mnum;
    nrout = max([mrows mcols]) - 1;;
    ncout = 1;
    out = zeros(npts*nrout,ncout);
    fone = (npts+1)*mrows;
    pone = 1:mrows:fone;
    ponem1 = pone(2:npts+1) - 1;
    fout = (npts+1)*nrout;
    pout = 1:nrout:fout;
    poutm1 = pout(2:npts+1) - 1;
    for i=1:npts
      out(pout(i):poutm1(i),1:ncout) = ...
         roots(mat(pone(i):ponem1(i),1:mcols));
    end
    out = vpck(out,indv);
  elseif mtype == 'syst'
    error('VROOTS is undefined for SYSTEM matrices')
    return
  else
    out = [];
  end
%
%