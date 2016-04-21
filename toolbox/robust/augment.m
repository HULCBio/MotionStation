function [a,b1,b2,c1,c2,d11,d12,d21,d22] = augment(sysg,sysw1,sysw2,sysw3,dim)
%%AUGMENT Augmentation of W1,W2,W3 (state-space form) into two-port plant.
%  [A,B1,B2,C1,C2,D11,D12,D21,D22] = AUGMENT(SYSG,SYSW1,SYSW2,SYSW3,DIM)
%    computes the state-space model of the augment plant with weighting
%    strategy as follows:
%
%       W1 = sysw1:=[aw1 bw1;cw1 dw1] ---- on 'e', the error signal
%       W2 = sysw2:=[aw2 bw2;cw2 dw2] ---- on 'u', the control signal.
%       W3 = sysw3:=[aw3 bw3;cw3 dw3] ---- on 'y', the output signal.
%
%    (any of the above weightings can be removed by setting sysw1 or
%     sysw2 or sysw3 equals to [], a non-dimensional state-space).
%
%       dim = [xg xw1 xw2 xw3]
%          where xg: no. of states of G(s)
%                xw1: no. of states of W1(s) (= 0, if sysw1 = [ ])
%                xw2: no. of states of W2(s) .... etc...
%
%    The augmented system P(s):= (a,b1,b2,c1,c2,d11,d12,d21,d22).

% R. Y. Chiang & M. G. Safonov 1/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.8.4.3 $
% All Rights Reserved.

%
% ----- Peel off the state-space of G, W1, W2, W3:
%
xg = dim(1,1); xw1 = dim(1,2); xw2 = dim(1,3); xw3 = dim(1,4);
mg = size(sysg)*[1;0]-xg;
ng = size(sysg)*[0;1]-xg;
mw1 = size(sysw1)*[1;0]-xw1;
nw1 = size(sysw1)*[0;1]-xw1;
mw2 = size(sysw2)*[1;0]-xw2;
nw2 = size(sysw2)*[0;1]-xw2;
mw3 = size(sysw3)*[1;0]-xw3;
nw3 = size(sysw3)*[0;1]-xw3;
%
[ag,bg,cg,dg] = sys2ss(sysg,xg);
[aw1,bw1,cw1,dw1] = sys2ss(sysw1,xw1);
[aw2,bw2,cw2,dw2] = sys2ss(sysw2,xw2);
[aw3,bw3,cw3,dw3] = sys2ss(sysw3,xw3);
%
% ----- A matrix:
%
a = [ag zeros(xg,xw1+xw2+xw3);-bw1*cg aw1 zeros(xw1,xw2+xw3);...
     zeros(xw2,xg+xw1) aw2 zeros(xw2,xw3);...
     bw3*cg zeros(xw3,xw1+xw2) aw3];
%
% ----- B matrix:
%
b1 = [zeros(xg,nw1);bw1;zeros(xw2+xw3,nw1)];
b2 = [bg;-bw1*dg;bw2;bw3*dg];
%
% ----- C matrix:
%
c1 = [-dw1*cg cw1 zeros(mw1,xw2+xw3);zeros(mw2,xg+xw1) cw2 zeros(mw2,xw3);...
      dw3*cg zeros(mw3,xw1+xw2) cw3];
c2 = [-cg zeros(mg,xw1+xw2+xw3)];
%
% ----- D matrix:
%
d11 = [dw1;zeros(mw2+mw3,nw1)];
d12 = [-dw1*dg;dw2;dw3*dg];
d21 = eye(nw1);
d22 = -dg;
%
% --------- End of AUGMENT.M --- RYC/MGS %
