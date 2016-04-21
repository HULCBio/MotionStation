%ex1t

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

% plants in the set
p1 = mmult(p,nd2sys([6.1],[1 6.1]));
p2 = nd2sys([1+0.425],[1 -1-0.425]);
p3 = mmult(p,nd2sys([-0.07 1],[0.07 1]));
p4 = mmult(p,nd2sys([70^2],[1 2*(1-0.856)*70 70^2]));
p5 = mmult(p,nd2sys([70^2],[1 2*(1+0.856)*70 70^2]));
pt = nd2sys([50],[1 50]);
p6 = mmult(pt,pt,pt,pt,pt,pt,p);

allplant = ipii(allplant,p,1);
allplant = ipii(allplant,p1,2);
allplant = ipii(allplant,p2,3);
allplant = ipii(allplant,p3,4);
allplant = ipii(allplant,p4,5);
allplant = ipii(allplant,p5,6);
allplant = ipii(allplant,p6,7);

systemnames = 'knom';
inputvar = '[ ref; e ]';
outputvar = '[ e; knom; knom ]';
input_to_knom = '[ -ref+e ]';
sysoutname = 'olpn';
cleanupsysic = 'yes';
sysic

systemnames = 'krob';
inputvar = '[ ref; e ]';
outputvar = '[ e; krob; krob ]';
input_to_krob = '[ -ref+e ]';
sysoutname = 'olpr';
cleanupsysic = 'yes';
sysic

in = step_tr([0 0.5 10],[0 1 1],.01,10);

% time response with the non-robust controller

ynom = trsp(starp(olpn,p),in,10,.01);
for i=2:7
	cl = starp(olpn,xpii(allplant,i));
	y = trsp(cl,in,10,.01);
	ynom = sbs(ynom,y);
 end
vplot(sel(ynom,1,[1 3 5 6]),in)
xlabel('Time')
title('Closed-loop response with K1')
axis([0 10 0 1.8])
pause

% time response with the robust controller
yrob = trsp(starp(olpr,p),in,10,.01);

for i=2:7
	cl = starp(olpr,xpii(allplant,i));
	y = trsp(cl,in,10,.01);
	yrob = sbs(yrob,y);
 end
vplot(sel(yrob,1,1:7),in)
xlabel('Time')
title('Closed-loop response with K2')
axis([0 10 0 1.8])