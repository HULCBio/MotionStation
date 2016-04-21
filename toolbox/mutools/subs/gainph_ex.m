% gainph

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

plant = nd2sys([1 -2],[2 -1],-1);
k1=1;
clp1=formloop(plant,k1,'neg');
spoles(clp1)
om=logspace(-2,2,150);
pg=frsp(plant,om);
k2=nd2sys([1 1.9],[1.9 1]);
k3=nd2sys([1.9 1],[1 1.9]);
k4=nd2sys([1 2.5],[2.5 1]);
k4 = mmult(k4,nd2sys([1.7 1.5 1],[1 1.5 1.7]));

k1g=frsp(k1,om);
k2g=frsp(k2,om);
k3g=frsp(k3,om);
k4g=frsp(k4,om);
lg1=mmult(pg,k1g);
lg2=mmult(pg,k2g);
lg3=mmult(pg,k3g);
lg4=mmult(pg,k4g);
xa = vpck([-4;1],[1;2]);
ya = vpck([-1*sqrt(-1);1*sqrt(-1)],[1;2]);

vplot('nyq',lg1,'-',lg2,'--',lg3,'-.',lg4,'.',xa,'w-',ya,'w-')
add_disk
axis([-4 1 -1 1])
xlabel('Real')
ylabel('Imaginary')
title('Nyquist Plot')
% print -deps gainph_nyq.eps
pause

vplot('bode',lg1,'-',lg2,'--',lg3,'-.',lg4,'.')
subplot(211)
title('Bode Plot')
% print -deps gainph_bode.eps