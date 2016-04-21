% function out = vdet(mat)
%
%   Determinant of a VARYING/CONSTANT matrix, identical
%   to MATLAB's DET command, but works with
%   VARYING matrices also.
%
%   See also: DET, VEBE, and VEVAL.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vdet(mat)
  if nargin == 0
    disp('usage: out = vdet(mat)')
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  [nr,nc] = size(mat);
  if mrows == mcols
    if mtype == 'cons'
      out = det(mat);
    elseif mtype == 'vary'
      omega = mat(1:mnum,nc);
      npts = mnum;
      nrout = 1;
      ncout = 1;
      out = zeros(npts+1,ncout+1);
      out(npts+1,ncout+1) = inf;
      out(npts+1,ncout) = npts;
      out(1:npts,ncout+1) = omega;
      ftop = (npts+1)*mrows;
      ptop = 1:mrows:ftop;
      ptopm1 = ptop(2:npts+1) - 1;
      for i=1:npts
        out(i,1) = det(mat(ptop(i):ptopm1(i),1:mcols));
      end
    elseif mtype == 'syst'
      error('VDET is undefined for SYSTEM matrices')
      return
    else
      out = [];
    end
  else
    if mtype == 'syst'
      error('VDET is undefined for SYSTEM matrices')
      return
    else
      error('input matrix must be square for VDET')
      return
    end
  end
%
%