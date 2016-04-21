function [A,B1,B2,C1,C2,D11,D12,D21,D22] = asys2ss(sysp,dimp);
%ASY2SS Convert two-port state-space quadruple to regular state-space matrices.
%
% [A,B1,B2,C1,C2,D11,D12,D21,D22] = ASYS2SS(SYSP,DIMP) converts
%    an augmented state-space quadruple to regular state-space
%    matrices.
%

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.7.4.3 $
% All Rights Reserved.

x1 = dimp(1,1); x2 = dimp(1,2); x3 = dimp(1,3);
x4 = dimp(1,4); x5 = dimp(1,5);
A = sysp(1:x1,1:x1);
B1 = sysp(1:x1,x1+1:x1+x2);
B2 = sysp(1:x1,x1+x2+1:x1+x2+x3);
C1 = sysp(x1+1:x1+x4,1:x1);
C2 = sysp(x1+x4+1:x1+x4+x5,1:x1);
D11 = sysp(x1+1:x1+x4,x1+1:x1+x2);
D12 = sysp(x1+1:x1+x4,x1+x2+1:x1+x2+x3);
D21 = sysp(x1+x4+1:x1+x4+x5,x1+1:x1+x2);
D22 = sysp(x1+x4+1:x1+x4+x5,x1+x2+1:x1+x2+x3);
%
% ------- End of ASYS2SS.M % RYC/MGS %