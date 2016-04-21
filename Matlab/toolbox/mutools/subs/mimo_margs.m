% mimo_ml

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 a = [0 10;-10 0];
 b = eye(2);
 c = [1 10;-10 1];
 G = pck(a,b,c);
 wdel1 = nd2sys([1 2],[1/60 20]);
 wdel2 = nd2sys([1 9],[1/40 45]);
 omega = logspace(-1,4,50);
 wdel1_g = frsp(wdel1,omega);
 wdel2_g = frsp(wdel2,omega);
 vplot('liv,lm',wdel1_g,wdel2_g)
 title('Multiplicative Uncertainty Weights')
 xlabel('Frequency (rad/sec)')
 ylabel('Magnitude')
 print -deps mimors_p1
 %pause

 systemnames = 'G wdel1 wdel2';
 inputvar = '[w(2); u(2)]';
 outputvar = '[u; G]';
 input_to_wdel1 = '[w(1)]';
 input_to_wdel2 = '[w(2)]';
 input_to_G = '[u(1) + wdel1; u(2) + wdel2]';
 sysoutname = 'uncplant';
 sysic;
 ex_mmmk;
 robica = starp(uncplant,ka,2,2);
 robicb = starp(uncplant,kb,2,2);
 rifd(spoles(robica))
 rifd(spoles(robicb))
 robica_g = frsp(robica,omega);
 robicb_g = frsp(robicb,omega);
 vplot('liv,m',sel(robica_g,1,1),'-',sel(robicb_g,1,1),'--');
 title('Channel 1 robustness: ka (solid), kb (dashed)')
 xlabel('Frequency (rad/sec)')
 ylabel('Magnitude')
 print -deps mimors_p2
 %pause
 vplot('liv,m',sel(robica_g,2,2),'-',sel(robicb_g,2,2),'--');
 title('Channel 2 robustness: ka (solid), kb (dashed)')
 xlabel('Frequency (rad/sec)')
 ylabel('Magnitude')
 print -deps mimors_p3
% pause

 blk = [1 1;1 1];
 [bnds_a,dvec_a,sens_a,pvec_a] = mu(robica_g,blk);
 [bnds_b,dvec_b,sens_b,pvec_b] = mu(robicb_g,blk);
 vplot('liv,m',bnds_a,'-',bnds_b,'--');
 title('Structured singular value with: ka(solid), kb (dashed)')
 xlabel('Frequency (rad/sec)')
 ylabel('mu')
 print -deps mimors_p4
%pause

 perta = dypert(pvec_a,blk,bnds_a);
 pertb = dypert(pvec_b,blk,bnds_b);
 hinfnorm(perta)
 hinfnorm(sel(perta,1,1))
 hinfnorm(sel(perta,1,2))
 hinfnorm(sel(perta,2,1))
 hinfnorm(sel(perta,2,2))
 hinfnorm(pertb)
 hinfnorm(sel(pertb,1,1))
 hinfnorm(sel(pertb,1,2))
 hinfnorm(sel(pertb,2,1))
 hinfnorm(sel(pertb,2,2))
 pertclpa = starp(perta,robica,2,2);
 pertclpb = starp(pertb,robicb,2,2);
 eig(pertclpa)
 eig(pertclpb)