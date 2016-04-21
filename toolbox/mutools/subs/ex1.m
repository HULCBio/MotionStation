% ex1.m

%   Copyright 1991-2004 MUSYN Inc. and The MathWorks, Inc.
% $Revision: 1.7.2.3 $

p = nd2sys(1,[1 -1]);
wu = nd2sys([0.5 1],[0.03125 1],.25);
omega = logspace(-2,2,80);
beta = 1;
ptilde = mmult(nd2sys(beta,[1 beta]),p);