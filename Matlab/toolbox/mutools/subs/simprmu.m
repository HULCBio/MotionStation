% simprmu.m
%
%    creates a 5 by 5 matrix m, along with several
%    block structures. this is useful in seeing the
%    dependency of real/complex mu(M) on the block structure
%    DELTA.

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

i=sqrt(-1);
M=[0.10+0.07*i -0.1538+0.1615*i 0-0.56*i  0+42.0*i  4.-1.4*i
 0-0.2730*i -0.30-0.28*i 2.86+0.546*i -26.0+72.8*i 13.+5.4600*i
 0.10+0.1750*i 0.0769-0.1077*i -0.40+0.2100*i 5.0+3.5000*i 4.5-0.70*i
  0+0.0021*i -0.0038-0.0021*i 0.0060+0.0112*i 0.2000+0.4200*i  0.0600+0.0140*i
 0.0240+0.0280*i 0+0.0269*i -0.0660+0.0420*i 0+0.70*i -0.4210+0.49*i
];
clear i

blka = [2 2;-1 0;-1 0;1 0];
blkb = [2 2;-1 0;-1 0;-1 0];
blkc = [-2 0;3 3];
blkd = [-2 0;-2 0;1 1];
blke = [2 2;2 2;-1 0];
blkf = [3 3;-2 0];
blkg = [-4 0;1 1];
blkh = [-1 0;-1 0;-1 0;2 2];
blki = [4 4;-1 0];
blkj = [-2 0;1 1;2 0];