% file: ex_uspl.m

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

 G1 = mmult(G,nd2sys([6.1],[1 6.1]));
 % G2 = nd2sys([1-0.325],[1 -1+0.325]);
 G2 = nd2sys([1+0.425],[1 -1-0.425]);
 G3 = mmult(G,nd2sys([-0.07 1],[0.07 1]));
 G4 = mmult(G,nd2sys([70^2], [1 2*0.14*70 70^2]));
 G5 = mmult(G,nd2sys([70^2], [1 2*1.86*70 70^2]));
 Gt = nd2sys([50],[1 50]);
 G6 = mmult(Gt,Gt,Gt,Gt,Gt,Gt,G);