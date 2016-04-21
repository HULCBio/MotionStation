% function out = vinv(mat)
%
%   Invert a VARYING/CONSTANT matrix. Identical to
%   the MATLAB command INV and works on VARYING matrices.
%
%   See also: INV and MINV.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vinv(mat)
  if nargin == 0
    disp('usage: out = vinv(mat)')
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  if mrows ~= mcols
    error('input matrix should be square')
    return
  end
  [nr,nc] = size(mat);
  if mtype == 'cons'
    out = inv(mat);
  elseif mtype == 'vary'
    omega=mat(1:mnum,nc);
    npts = mnum;
    nrout = mrows;
    ncout = nrout;
    out = zeros(nrout*npts+1,ncout+1);
    out(nrout*npts+1,ncout+1) = inf;
    out(1:mnum,ncout+1) = omega;
    out(nrout*npts+1,ncout) = npts;
    ftop = (npts+1)*mrows;
    ptop = 1:mrows:ftop;
    ptopm1 = ptop(2:npts+1) - 1;
    for i=1:npts
      out(ptop(i):ptopm1(i),1:mrows) = ...
        inv(mat(ptop(i):ptopm1(i),1:mcols));
    end
  elseif mtype == 'syst'
    error(['VINV does not work on SYSTEM matrices']);
    return
  end
%
%