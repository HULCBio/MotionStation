% ex_mkpl

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

G1 = mmult(G,nd2sys([6.1],[1 6.1]));
G2 = nd2sys([1+0.425],[1 -1-0.425]);
G3 = nd2sys([1-0.33],[1 -1+0.33]);
G4 = mmult(G,nd2sys([-0.07 1],[0.07 1]));
G5 = mmult(G,nd2sys([70^2], [1 2*0.14*70 70^2]));
G6 = mmult(G,nd2sys([70^2], [1 2*5.6*70 70^2]));
Gt = nd2sys([50],[1 50]);
G7 = mmult(G,Gt,Gt,Gt,Gt,Gt,Gt);
Gwc1 = mmult(G,madd(1,mmult(deltabad1,Wu)));
Gwc2 = mmult(G,madd(1,mmult(deltabad2,Wu)));