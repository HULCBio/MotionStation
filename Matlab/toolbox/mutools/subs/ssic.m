% ssic - make up spinning satellite interconnection structure
%	     for D-K iteration

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

P      = pss2sys([0 10 1 0;-10 0 0 1;1 10 0 0;-10 1 0 0],2);
w_del1 = nd2sys([1 4],[1 200],10);
w_del2 = nd2sys([1 24],[1 200],10/3);
w_n    = nd2sys([1 25],[1 6000],12/5);
W_n    = daug(w_n,w_n);
w_p    = nd2sys([1 4],[1 0.02],1/2);
W_p    = daug(w_p,w_p);

systemnames = 'P w_del1 w_del2 W_p W_n';
inputvar    = '[z1; z2; d{2}; nois{2}; u{2}]';
outputvar   = '[u(1); u(2); P + W_p; P + W_p + W_n]';
input_to_P      = '[u(1) + w_del1; u(2) + w_del2]';
input_to_w_del1 = '[ z1 ]';
input_to_w_del2 = '[ z2 ]';
input_to_W_p    = '[ d ]';
input_to_W_n    = '[ nois ]';
cleanupsysic    = 'yes';
sysoutname      = 'P_ss';
sysic

clear P w_del1 w_del2 w_n W_n w_p W_p