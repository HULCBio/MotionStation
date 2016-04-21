% function sysout = statecc(sysin,t)
%
%   Applies a state coordinate transformation to the
%   system matrix, yielding a new system matrix with:
%
%       sysout = pck(inv(t)*a*t,inv(t)*b,c*t,d)
%
%   See also: EIG, INV, MINV, MMULT, REORDSYS, SRESID,
%             STRANS, and TRUNC.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function sysout = statecc(sysin,t)
if nargin ~= 2
  disp(['usage: sysout = statecc(sysin,t)']);
else
  [type,mrow,mcol,mnum] = minfo(sysin);
  [nrt,nct] = size(t);
  if nrt ~= mnum | nct ~= mnum
    error(['incompatible dimensions'])
    return
  end
  if strcmp(type,'syst')
    [a,b,c,d] = unpck(sysin);
    nab = t\[a b];
    sysout = pck(nab(1:mnum,1:mnum)*t,nab(1:mnum,mnum+1:mnum+mcol),c*t,d);
  else
    disp(['sysin needs to be a SYSTEM matrix'])
  end
end
%
%