%ex1d

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

p = nd2sys(1,[1 -1]);
wu = nd2sys([0.5 1],[0.03125 1],.25);
po = .006;
wp = nd2sys([.25 100*po],[1 po]);

wn = 10; zeta = 0.9;
gain  = wn^2;
tau   = (2*zeta*wn + 1)/gain;
knom = nd2sys([tau 1],[1 0],-gain);
wn = 1; zeta = 0.9;
gain  = wn^2;
tau   = (2*zeta*wn + 1)/gain;
krob = nd2sys([tau 1],[1 0],-gain);

systemnames = 'p wu wp';
inputvar = '[ z{1}; d{1}; u{1} ]';
outputvar = '[ wu; wp; d+p ]';
input_to_p = '[ z+u ]';
input_to_wu = '[ u ]';
input_to_wp = '[ d+p ]';
sysoutname = 'olp';
cleanupsysic = 'yes';
sysic

om = logspace(-1,3,80);
om = logspace(-1,3,80);
clpn = starp(olp,knom);
clpr = starp(olp,krob);
rifd(spoles(clpn))
rifd(spoles(clpr))
clpng = frsp(clpn,om);
clprg = frsp(clpr,om);

blk = [1 1;1 1];

bndsn = mu(clpng,blk);
bndsr = mu(clprg,blk);

vplot('liv,m',bndsn,'-',vnorm(sel(clpng,2,2)),'-',...
              bndsr,'--',vnorm(sel(clprg,2,2)),'--')

subplot(121)
vplot('liv,m',vnorm(sel(clpng,2,2)),'-',...
              vnorm(sel(clprg,2,2)),'--',1,'-.')
axis([.1 1000 0 2])
xlabel('Frequency (rad/sec)'), ylabel('Magnitude')
title('Nominal Performance')
subplot(122)
vplot('liv,m',bndsn,'-',bndsr,'--',1,'-.')
axis([.1 1000 0 2])
xlabel('Frequency (rad/sec)'), ylabel('mu')
title('Robust Performance')