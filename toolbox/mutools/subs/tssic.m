% tssic - make up spinning satellite interconnection structure
%	     for D-K iteration

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

P      = pss2sys([0 10 1 0;-10 0 0 1;1 10 0 0;-10 1 0 0],2);
w_del1 = nd2sys([1 4],[1 40],2);
w_del2 = nd2sys([1 24],[1 40],2/3);

systemnames = 'P w_del1 w_del2';
inputvar    = '[z{2}; d{2}; n{2}; u{2}]';
outputvar   = '[u ; d - P; P + n - d; d; u;  P + n - d]';
input_to_P      = '[u(1) + w_del1; u(2) + w_del2]';
input_to_w_del1 = '[ z(1) ]';
input_to_w_del2 = '[ z(2) ]';
cleanupsysic    = 'yes';
sysoutname      = 'P_tss';
sysic

u1 = step_tr(0,1,.01,5);
u2 = mscl(u1,0);
t = getiv(u1);
u34  = siggen('0.05*randn(2,1)',t);
u  = abv(u1,u2,u34);