%
%   split up the H-infinity matrices for FULL INFORMATION case.
%

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

function [ap,bp,cp,dp,b1,b2,c1,d11,d12,ndata] = hinffi_p(p,ncon)
%
[pptype,nr,nc,np] = minfo(p);
if pptype ~= 'syst'
  error('matrix is not a system matrix')
end
npout = nr;
npin  = nc;
np1 = npout;
np2 = 0;
nm1 = npin-ncon;
nm2 = ncon;
ndata = [np1 np2 nm1 nm2];
[ap,bp,cp,dp] = unpck(p);
% dum = sqrt(norm(bp,'inf')/norm(cp,'inf'));
% bp = bp/dum;
% cp = cp*dum;
b1 = bp(:,[1:nm1]);
b2 = bp(:,[(nm1+1):npin]);
c1 = cp([1:np1],:);
d11 = dp(1:np1,1:nm1);
d12 = dp(1:np1,(nm1+1):npin);
%
%