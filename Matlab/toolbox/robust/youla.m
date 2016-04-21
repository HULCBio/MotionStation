%YOULA Youla parameterization.
%
%         YOULA produces a state space realization of T11, T12, T21,
%         T12p, T21p via Youla lemma - parameterization of
%         stabilizing controller.
%         Program inputs : augmented plant (A,B1,B2,C1,C2,D11,
%                          D12,D21,D22).
%         Program outputs: state-space of T11, T12, T12p, T21, T21p
%                          full-state LQR: kx,x,f
%                          observer LQR  : ky,y,h

% R. Y. Chiang & M. G. Safonov 6/86
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
%--------------------------------------------------------------------

%
% II). Small Gain Problem :
%
%      Parametrize all stabilizing controller (Youla lemma)
%
disp('  ')
disp('      << Working on Phase II: Youla parametrization >>')
disp('   ')
%
[rrrra,rrrra] = size(A);
twoN = 2*rrrra;
%
[D12p] = ortc(D12);
qrnx = [C1'*C1 C1'*D12;(C1'*D12)' D12'*D12];
[kx,x,xerr] = lqrc(A,B2,qrnx);
f = - kx;
[D21p] = ortr(D21);
qrny = [B1*B1' B1*D21';(B1*D21')' D21*D21'];
[ky,y,yerr] = lqrc(A',C2',qrny);
h = - ky';
%
% ------------------------------------ Normalization terms :
%
mr = (D12'*D12)^(0.5);
ml = (D21*D21')^(0.5);
%
% ------------------------------------ State Space of T12 :
%
at12 = A + B2 * f;
bt12 = B2 * inv(mr);
ct12 = C1 + D12 * f;
dt12 = D12 * inv(mr);
%
% ------------------------------------ State Space of T12p :
%
xp = pinv(x);
at1p = A + B2 * f;
bt1p = -xp * C1' * D12p;
ct1p = C1 + D12 * f;
dt1p = D12p;
%
% ------------------------------------ State Space of T21 :
%
at21 = A + h * C2;
bt21 = B1 + h * D21;
ct21 = inv(ml) * C2;
dt21 = inv(ml) * D21;
%
% ------------------------------------ State Space of T21p :
%
yp = pinv(y);
at2p = A + h * C2;
bt2p = B1 + h * D21;
ct2p = -D21p * B1' * yp;
dt2p = D21p;
%
% ------------------------------------ State Space of T11 :
%
at10 = A + B2 * f;
[rat1,cat1] = size(at10);
at00 = A + h * C2;
[rat0,cat0] = size(at00);
at11 = [at10 -B2*f;zeros(rat0,cat1) at00];
bt11 = [B1;B1+h*D21];
ct11 = [C1+D12*f -D12*f];
dt11 = D11;
%
[rbt2,cbt2] = size(bt21);
[rct2,cct2] = size(ct21);
[rbt1,cbt1] = size(bt12);
[rct1,cct1] = size(ct12);
%
% --------------------------------------------------------
%
% III). Interpolation Problem :
%
% ------------------------------------- Assign execution :
%
[rbt2,cbt2] = size(bt21);
[rct2,cct2] = size(ct21);
[rbt1,cbt1] = size(bt12);
[rct1,cct1] = size(ct12);
%
if (cbt2 == rct2) & (cbt1 == rct1)
   yulacase = 1.;
end
%
if (cbt2 == rct2) & (cbt1 ~= rct1)
   yulacase = 2.;
end
%
if (cbt2 ~= rct2) & (cbt1 == rct1)
   yulacase = 3.;
end
%
if (cbt2 ~= rct2) & (cbt1 ~= rct1)
   yulacase = 4.;
end
%
sqrmtx
%
% ------- Default setting of "no" and "MRtype":
%
MRtype = 2;
tol = 0.01;
%
% ------- End of YOULA.M ---- RYC/MGS %
