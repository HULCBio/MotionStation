function sys=tss(a,b1,b2,c1,c2,d11,d12,d21,d22)
% SYS= TSS(A,B1,B2,C1,C2,D11,D12,D21,D22) transforms TITO system
%     (two-input-two-output) state-space matrices 
%          A,B1,B2,C1,C2,D11,D12,D21,D22
%      into the corresponding partitioned LTI object.  TSS
%      is the inverse of the function TSSDATA.
% 
% See also TSSDATA, MKTITO

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $
% All rights reserved.

b=[b1,b2];
c=[c1;c2];
d=[d11,d12; d21, d22];
[msg,a,b,c,d]=abcdchk(a,b,c,d);
sys=ss(a,b,c,d);
[nmeas,ncont]=size(d22);
sys=mktito(sys,nmeas,ncont);
% ----------- End of TSS.M --------RYC/MGS 1997

