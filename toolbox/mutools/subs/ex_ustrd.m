% ex_ustrd

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

clpg_k1dk = sel(formloop(G,K1dk,'pos','neg'),2,1);
clpg1_k1dk = sel(formloop(G1,K1dk,'pos','neg'),2,1);
clpg2_k1dk = sel(formloop(G2,K1dk,'pos','neg'),2,1);
clpg3_k1dk = sel(formloop(G3,K1dk,'pos','neg'),2,1);
clpg4_k1dk = sel(formloop(G4,K1dk,'pos','neg'),2,1);
clpg5_k1dk = sel(formloop(G5,K1dk,'pos','neg'),2,1);
clpg6_k1dk = sel(formloop(G6,K1dk,'pos','neg'),2,1);
clpg7_k1dk = sel(formloop(G7,K1dk,'pos','neg'),2,1);
clpgwc1_k1dk = sel(formloop(Gwc1,K1dk,'pos','neg'),2,1);
clpgwc2_k1dk = sel(formloop(Gwc2,K1dk,'pos','neg'),2,1);

clpg_k3dk = sel(formloop(G,K3dk,'pos','neg'),2,1);
clpg1_k3dk = sel(formloop(G1,K3dk,'pos','neg'),2,1);
clpg2_k3dk = sel(formloop(G2,K3dk,'pos','neg'),2,1);
clpg3_k3dk = sel(formloop(G3,K3dk,'pos','neg'),2,1);
clpg4_k3dk = sel(formloop(G4,K3dk,'pos','neg'),2,1);
clpg5_k3dk = sel(formloop(G5,K3dk,'pos','neg'),2,1);
clpg6_k3dk = sel(formloop(G6,K3dk,'pos','neg'),2,1);
clpg7_k3dk = sel(formloop(G7,K3dk,'pos','neg'),2,1);
clpgwc1_k3dk = sel(formloop(Gwc1,K3dk,'pos','neg'),2,1);
clpgwc2_k3dk = sel(formloop(Gwc2,K3dk,'pos','neg'),2,1);

stepref = step_tr([0 0.5 10],[0 1 1],.01,10);
Tfinal = 10;
tinc = 0.01;

yg_k1dk = trsp(clpg_k1dk,stepref,Tfinal,tinc);
yg1_k1dk = trsp(clpg1_k1dk,stepref,Tfinal,tinc);
yg2_k1dk = trsp(clpg2_k1dk,stepref,Tfinal,tinc);
yg3_k1dk = trsp(clpg3_k1dk,stepref,Tfinal,tinc);
yg4_k1dk = trsp(clpg4_k1dk,stepref,Tfinal,tinc);
yg5_k1dk = trsp(clpg5_k1dk,stepref,Tfinal,tinc);
yg6_k1dk = trsp(clpg6_k1dk,stepref,Tfinal,tinc);
yg7_k1dk = trsp(clpg7_k1dk,stepref,Tfinal,tinc);
ygwc1_k1dk = trsp(clpgwc1_k1dk,stepref,Tfinal,tinc);
ygwc2_k1dk = trsp(clpgwc2_k1dk,stepref,Tfinal,tinc);

yg_k3dk = trsp(clpg_k3dk,stepref,Tfinal,tinc);
yg1_k3dk = trsp(clpg1_k3dk,stepref,Tfinal,tinc);
yg2_k3dk = trsp(clpg2_k3dk,stepref,Tfinal,tinc);
yg3_k3dk = trsp(clpg3_k3dk,stepref,Tfinal,tinc);
yg4_k3dk = trsp(clpg4_k3dk,stepref,Tfinal,tinc);
yg5_k3dk = trsp(clpg5_k3dk,stepref,Tfinal,tinc);
yg6_k3dk = trsp(clpg6_k3dk,stepref,Tfinal,tinc);
yg7_k3dk = trsp(clpg7_k3dk,stepref,Tfinal,tinc);
ygwc1_k3dk = trsp(clpgwc1_k3dk,stepref,Tfinal,tinc);
ygwc2_k3dk = trsp(clpgwc2_k3dk,stepref,Tfinal,tinc);

subplot(211)
vplot(vdcmate(yg_k1dk,5),'+',yg1_k1dk,yg2_k1dk,yg3_k1dk,yg4_k1dk,yg5_k1dk,...
	yg6_k1dk,yg7_k1dk,vdcmate(ygwc1_k1dk,5),'o',ygwc2_k1dk);
xlabel('Time (seconds)')
title('Closed-loop responses using K1dk')

subplot(212)
vplot(vdcmate(yg_k3dk,5),'+',yg1_k3dk,yg2_k3dk,yg3_k3dk,yg4_k3dk,yg5_k3dk,...
	yg6_k3dk,yg7_k3dk,ygwc1_k3dk,vdcmate(ygwc2_k3dk,5),'o');
xlabel('Time (seconds)')
title('Closed-loop responses using K3dk')