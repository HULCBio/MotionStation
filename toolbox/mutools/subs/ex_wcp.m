% ex_wcp

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

[deltabad1,wcp_l1,wcp_u1] = wcperf(M1g,uncblk,1.0,8);
[deltabad2,wcp_l2,wcp_u2] = wcperf(M2g,uncblk,1.0,8);
vplot(wcp_l1,wcp_u1,wcp_l2,'--',wcp_u2,'--')
	xlabel('Size of Delta_G')
	ylabel('Weighted Sensitivity');
	title('Performance Degradation (K1 solid, K2 dashed)');
