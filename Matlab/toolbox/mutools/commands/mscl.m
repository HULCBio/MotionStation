% function out = mscl(mat,fac)
%
%   Scale a SYSTEM/VARYING/CONSTANT by a scalar number.
%   In a SYSTEM matrix, this command scales the B and
%   D matrices by FAC
%
%	out = fac*mat
%
%   See also: *, MMULT, SCLIN, SCLOUT, and SCLIV.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function out = mscl(mat,fac)
  if nargin <= 1
    disp('usage: out = mscl(mat,fac)')
    return
  end
  [nrf,ncf] = size(fac);
  if nrf ~= 1 | ncf ~= 1
    error('second argument should be a scalar')
    return
  else
    [mtype,mrows,mcols,mnum] = minfo(mat);
    if mtype == 'vary'
      [vd,rp,indv] = vunpck(mat);
      out = zeros(mrows*mnum+1,mcols+1);
      out(mrows*mnum+1,mcols+1) = inf;
      out(mrows*mnum+1,mcols) = mnum;
      out(1:mnum,mcols+1) = indv;
      out(1:mrows*mnum,1:mcols) = fac*vd;
    elseif mtype == 'syst'
      [a,b,c,d] = unpck(mat);
      out=pck(a,fac*b,c,fac*d);
    elseif mtype == 'cons'
      out = fac*mat;
    else
      out = [];
    end
  end
%
%