% ex_ustr

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

stepref = step_tr([0 0.5 10],[0 1 1],.01,10);
Tfinal = 10;
tinc = 0.01;

yg_k1 = trsp(clpg_k1,stepref,Tfinal,tinc);
yg1_k1 = trsp(clpg1_k1,stepref,Tfinal,tinc);
yg2_k1 = trsp(clpg2_k1,stepref,Tfinal,tinc);
yg3_k1 = trsp(clpg3_k1,stepref,Tfinal,tinc);
yg4_k1 = trsp(clpg4_k1,stepref,Tfinal,tinc);
yg5_k1 = trsp(clpg5_k1,stepref,Tfinal,tinc);
yg6_k1 = trsp(clpg6_k1,stepref,Tfinal,tinc);
yg7_k1 = trsp(clpg7_k1,stepref,Tfinal,tinc);
ygwc1_k1 = trsp(clpgwc1_k1,stepref,Tfinal,tinc);
ygwc2_k1 = trsp(clpgwc2_k1,stepref,Tfinal,tinc);

yg_k2 = trsp(clpg_k2,stepref,Tfinal,tinc);
yg1_k2 = trsp(clpg1_k2,stepref,Tfinal,tinc);
yg2_k2 = trsp(clpg2_k2,stepref,Tfinal,tinc);
yg3_k2 = trsp(clpg3_k2,stepref,Tfinal,tinc);
yg4_k2 = trsp(clpg4_k2,stepref,Tfinal,tinc);
yg5_k2 = trsp(clpg5_k2,stepref,Tfinal,tinc);
yg6_k2 = trsp(clpg6_k2,stepref,Tfinal,tinc);
yg7_k2 = trsp(clpg7_k2,stepref,Tfinal,tinc);
ygwc1_k2 = trsp(clpgwc1_k2,stepref,Tfinal,tinc);
ygwc2_k2 = trsp(clpgwc2_k2,stepref,Tfinal,tinc);

subplot(211)
vplot(vdcmate(yg_k1,5),'+',yg1_k1,yg2_k1,yg3_k1,yg4_k1,yg5_k1,...
	yg6_k1,yg7_k1,vdcmate(ygwc1_k1,5),'+',ygwc2_k1);
xlabel('Time (seconds)')
title('Closed-loop responses using K1')
subplot(212)
vplot(vdcmate(yg_k2,5),'+',yg1_k2,yg2_k2,yg3_k2,yg4_k2,yg5_k2,...
	yg6_k2,yg7_k2,ygwc1_k2,vdcmate(ygwc2_k2,5),'+');
xlabel('Time (seconds)')
title('Closed-loop responses using K2')