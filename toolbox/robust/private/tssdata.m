function [a,b1,b2,c1,c2,d11,d12,d21,d22]=tssdata(sys)
% [A,B1,B2,C1,C2,D11,D12,D21,D22]=tssdata(sys) extracts partitioned
%    state-space matrices from a TITO (two-input-two-output) system.
%
% See also:  ISTITO, MKTITO

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.5.4.3 $
% All rights reserved.


[tito,u1,u2,y1,y2]=istito(sys);
if ~tito,
   error('SYS must be TITO')
   return
end

[a,b,c,d,e]=dssdata(sys);

b1=b(:,u1); b2 =b(:,u2);
c1=c(y1,:); c2 =c(y2,:);
d11=d(y1,u1);  d12=d(y1,u2);
d21=d(y2,u1);  d22=d(y2,u2);
% ----------- End of TSSDATA.M --------RYC/MGS 1997
