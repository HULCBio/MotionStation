% ex_ustr2

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

clpk1nom = sel(sisoloop(K1dk,G,'pos','neg'),2,1);
clpk1g1 = sel(sisoloop(K1dk,G1,'pos','neg'),2,1);
clpk1g2 = sel(sisoloop(K1dk,G2,'pos','neg'),2,1);
clpk1g3 = sel(sisoloop(K1dk,G3,'pos','neg'),2,1);
clpk1g4 = sel(sisoloop(K1dk,G4,'pos','neg'),2,1);
clpk1g5 = sel(sisoloop(K1dk,G5,'pos','neg'),2,1);
clpk1g6 = sel(sisoloop(K1dk,G6,'pos','neg'),2,1);

clpk2nom = sel(sisoloop(K3dk,G,'pos','neg'),2,1);
clpk2g1 = sel(sisoloop(K3dk,G1,'pos','neg'),2,1);
clpk2g2 = sel(sisoloop(K3dk,G2,'pos','neg'),2,1);
clpk2g3 = sel(sisoloop(K3dk,G3,'pos','neg'),2,1);
clpk2g4 = sel(sisoloop(K3dk,G4,'pos','neg'),2,1);
clpk2g5 = sel(sisoloop(K3dk,G5,'pos','neg'),2,1);
clpk2g6 = sel(sisoloop(K3dk,G6,'pos','neg'),2,1);

r = step_tr([0 .5 10],[0 1 1],.01,10);

yk1nom = trsp(clpk1nom,r,10,0.01);
yk1g1 = trsp(clpk1g1,r,10,0.01);
yk1g2 = trsp(clpk1g2,r,10,0.01);
yk1g3 = trsp(clpk1g3,r,10,0.01);
yk1g4 = trsp(clpk1g4,r,10,0.01);
yk1g5 = trsp(clpk1g5,r,10,0.01);
yk1g6 = trsp(clpk1g6,r,10,0.01);

yk2nom = trsp(clpk2nom,r,10,0.01);
yk2g1 = trsp(clpk2g1,r,10,0.01);
yk2g2 = trsp(clpk2g2,r,10,0.01);
yk2g3 = trsp(clpk2g3,r,10,0.01);
yk2g4 = trsp(clpk2g4,r,10,0.01);
yk2g5 = trsp(clpk2g5,r,10,0.01);
yk2g6 = trsp(clpk2g6,r,10,0.01);

vplot(yk1nom,'+',yk1g1,yk1g2,yk1g3,yk1g4,yk1g5,yk1g6)
set(gca,'ylim',[0 2.5]);
title('Step Responses for Extreme Plants: K1dk')

figure
vplot(yk2nom,'+',yk2g1,yk2g2,yk2g3,yk2g4,yk2g5,yk2g6)
set(gca,'ylim',[0 2.5]);
title('Step Responses for Extreme Plants: K3dk')