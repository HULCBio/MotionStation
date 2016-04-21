% ex_f14wt.m

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

  hqmod_p    = nd2sys([2.0],[1 2.0],5.0);
  hqmod_beta = nd2sys([1.25^2],[1 2.5 1.25^2],-2.5);
  freq = 12.5;
  freqr = freq*2*pi;
  zeta = 0.5;
  antia_filt_yaw = nd2sys(freqr^2,[1 2*zeta*freqr freqr^2]);
  antia_filt_lata = nd2sys(freqr^2,[1 2*zeta*freqr freqr^2]);
  freq = 4.1;
  freqr = freq*2*pi;
  zeta = 0.7;
  antia_filt_roll = nd2sys(freqr^2,[1 2*zeta*freqr freqr^2]);
  antia_filt      = daug(antia_filt_lata,antia_filt_roll,antia_filt_yaw);
  clear freq freqr zeta
  W_act = daug(1/90,1/20,1/125,1/30);
  W_n = daug(0.025,0.025,nd2sys([1 1],[1 100],0.0125));
  W_p    = nd2sys([0.05 2.9 105.93 6.17 0.16],[1 9.19 30.80 18.83 3.95]);
  W_beta = mscl(W_p,2);

  load F14_nom

  A_S = pck(-25,25,[-25;1],[25;0]);
  A_R = pck(-25,25,[-25;1],[25;0]);
  w_1  = nd2sys([1 4],[1 160],2.0);
  w_2  = nd2sys([1 20],[1 200],1.5);
  W_in  = daug(w_1,w_2);