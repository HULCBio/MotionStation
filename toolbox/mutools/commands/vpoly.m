% function out = vpoly(mat)
%
%   Characteristic polynomial of a VARYING/CONSTANT
%   matrix. Identical to MATLAB's POLY command, but
%   works with VARYING matrices also.
%
%   See also: DET, POLY, ROOTS, VDET, and VROOTS.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = vpoly(mat)
  if nargin == 0
    disp('usage: out = vpoly(mat)')
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  [nr,nc] = size(mat);
  if mrows == mcols
    if mtype == 'cons'
      out = poly(mat);
    elseif mtype == 'vary'
      npts = mnum;
      ncout = mcols + 1;
      out = zeros(npts+1,ncout+1);
      ftop = (npts+1)*mrows;
      ptop = 1:mrows:ftop;
      ptopm1 = ptop(2:npts+1) - 1;
      for i=1:npts
        out(i,1:ncout) = poly(mat(ptop(i):ptopm1(i),1:mcols));
      end
      out(1:npts,ncout+1) = mat(1:mnum,nc);
      out(npts+1,ncout+1) = inf;
      out(npts+1,ncout) = npts;
    elseif mtype == 'syst'
      error('VPOLY is undefined for SYSTEM matrices')
      return
    else
      out = [];
    end
  elseif mrows == 1 | mcols == 1
    if mtype == 'cons'
      out = poly(mat);
    elseif mtype == 'vary'
      npts = mnum;
      if mrows ~= 1
	 mat = transp(mat);
         [mtype,mrows,mcols,mnum] = minfo(mat);
      end
      ncout = mcols + 1;
      out = zeros(npts+1,ncout+1);
      for i=1:npts
         out(i,1:ncout) = poly(mat(i,1:mcols));
      end
      out(1:npts,ncout+1) = mat(1:mnum,nc);
      out(npts+1,ncout+1) = inf;
      out(npts+1,ncout) = npts;
    elseif mtype == 'syst'
      error('VPOLY is undefined for SYSTEM matrices')
      return
    else
      out = [];
    end
  else
    if mtype == 'syst'
      error('VPOLY is undefined for SYSTEM matrices')
      return
    else
      error('input matrix must be square for VPOLY')
      return
    end
  end
%
%