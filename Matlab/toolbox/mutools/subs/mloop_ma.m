
%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.8.2.3 $

 a = [0 10;-10 0];
 b = eye(2);
 c = [1 10;-10 1];
 G = pck(a,b,c);
 K = eye(2);
 omega = logspace(-3,2,150);
 Gg = frsp(G,omega);
 minfo(Gg);
 nom_ch1_lb = starp(mscl(Gg,-1),1,1,1);
 nom_ch2_lb = starp(1,mscl(Gg,-1),1,1);
 vplot('bode',nom_ch1_lb,'-',nom_ch2_lb,'--');
 subplot(211)
 title('Bode Plot: Single Loop Broken in Channel 1 and 2')
print -deps mloop_p1.eps
 pause

 delta1 = -1/sqrt(101);
 delta2 = 1/sqrt(101);
 delta = [1+delta1 0 ; 0 1+delta2];
 minfo(G)
 minfo(delta)
 clpAmat = starp(mscl(G,-1),delta,2,2)
 minfo(clpAmat)
 eig(clpAmat)
 delta2 = 0.001;
 pert_ch1_lb1 = starp(mscl(Gg,-1),1+delta2,1,1);
 vplot('nyq',pert_ch1_lb1);
 delta2 = 0.01;
 pert_ch1_lb2 = starp(mscl(Gg,-1),1+delta2,1,1);
 xa = vpck([-2; 12],[1 2]);
 ya = vpck([-sqrt(-1); 6*sqrt(-1)],[1 2]);
 clf
 vplot('nyq',pert_ch1_lb1,'-',pert_ch1_lb2,'--',xa,ya);
 add_disk
 title('Nyquist Plot: Loop Broken in Channel 1, Delta2 =.001, .01')
 xlabel('Real')
 ylabel('Imaginary')
print -deps mloop_nyq1.eps
 pause

 delta2values = logspace(-3,-1,6);
 pert_ch1_lb =  [];
 for i=1:length(delta2values)
     delta2 = delta2values(i);
     pert_ch1_lb = sbs(pert_ch1_lb,starp(mscl(Gg,-1),1+delta2,1,1));
 end
 xa = vpck([-2; 12],[1 2]);
 ya = vpck([-sqrt(-1); 6*sqrt(-1)],[1 2]);
 vplot('nyq',pert_ch1_lb,xa,ya);
 add_disk
 title('Nyquist Plot: Loop Broken in Channel 1, Delta2 in [.001 .1]')
 xlabel('Real')
 ylabel('Imaginary')
print -deps mloop_nyq2.eps
 pause

 delta1 = -0.01;
 pert_ch2_lb = starp(1+delta1,mscl(Gg,-1),1,1);
 xa = vpck([-2; 1],[1 2]);
 ya = vpck([-2*sqrt(-1); 2*sqrt(-1)],[1 2]);
 vplot('nyq',pert_ch2_lb,xa,ya);
 add_disk
 title('Nyquist Plot: Loop Broken in Channel 2, Delta1 = -0.01')
 xlabel('Real')
 ylabel('Imaginary')
print -deps mloop_nyq3.eps