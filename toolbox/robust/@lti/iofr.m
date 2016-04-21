function [ain,bin,cin,din,ainp,binp,cinp,dinp,aout,bout,cout,dout] = iofr(varargin)
%IOFR State-space inner-outer factorization.
%
% [SS_IN,SS_INP,SS_OUT] = IOFR(SS_) or
% [AIN,BIN,CIN,DIN,AINP,BINP,CINP,DINP,AOUT,BOUT,COUT,DOUT] = IOFR(A,B,C,D)
%     produces an inner-outer factorization of a m x n transfer function
%     G: SS_ = MKSYS(A,B,C,D) (m>=n)
%     such that
%                      G = |Th Thp| |M|
%                                   |0|
%     where
%                      [Th Thp] : square and inner.
%                      M : outer factor.
%
%     The resulting state-space quadruples are accumulated in
%     (ain,bin,...) or
%
%            ss_in  = mksys(ain,bin,cin,din);
%            ss_inp = mksys(ainp,binp,cinp,dinp);
%            ss_out = mksys(aout,bout,cout,dout);
%
%     The standard state-space can be recovered by "branch".

% R. Y. Chiang & M. G. Safonov 8/85
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.6.4.3 $
% ---------------------------------------------------------------
%

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

[dp] = ortc(d);
deln1 = inv(d'*d);
aric = a - b * deln1 * d' * c;
qric = c' * dp * dp' * c;
rric = d' * d;
qrn = diagmx(qric,rric);
[kx,x] = lqrc(aric,b,qrn);
f = -deln1 * (b' * x + d' * c);
%
% --------- Inner factor:
%
Ri12 = (d'*d)^(-0.5);
ain = a + b * f; bin = b * Ri12;
cin = c + d * f; din = d * Ri12;
%
% --------- Complementary inner factor:
%
xp = pinv(x);
binp = -xp * c' * dp;
dinp = dp;
ainp = ain;
cinp = cin;
%
% --------- Inverse of the outer factor:
%
aouti = ain;
bouti = bin;
couti = f;
douti = Ri12;
%
% --------- Outer factor:
%
dout = inv(douti);
aout = ain-bouti*dout*couti;
bout = bouti*dout;
cout = -dout*couti;
%
if xsflag
  ain = mksys(ain,bin,cin,din);
  bin = mksys(ainp,binp,cinp,dinp);
  cin = mksys(aout,bout,cout,dout);
end
%
% ------ End of IOFR.M ---- RYC/MGS 8/85 %