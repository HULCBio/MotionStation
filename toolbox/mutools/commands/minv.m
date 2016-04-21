% function out = minv(mat)
%
%   Invert a SYSTEM/VARYING/CONSTANT matrix.
%
%   See also: INV, VDET, and VINV.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = minv(mat)
  if nargin == 0
    disp('usage: out = minv(mat)')
    return
  end
  [mtype,mrows,mcols,mnum] = minfo(mat);
  if mrows ~= mcols
    error('input matrix should be square')
    return
  end
  if mtype == 'cons'
    out = inv(mat);
  elseif mtype == 'vary'
    if mrows == 1    % fast for     1 x 1    VARYING matrices
      out = mat;
      out(1:mnum,1) = ones(mnum,1)./mat(1:mnum,1);
    else
      omega = mat(1:mnum,mcols+1);
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
    end
  elseif mtype == 'syst'
    [a,b,c,d] = unpck(mat);
    bdi = b / d;
    di = inv(d);
    dic = d \ c;
    out = pck(a-b*dic,-bdi,dic,di);
  end

%
%