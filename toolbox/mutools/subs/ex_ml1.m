% file: ex_ml1.m

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

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