function [ain,bin,cin,din,ainp,binp,cinp,dinp,aout,bout,cout,dout] = iofc(varargin)
%IOFC State-space inner-outer factorization.
%
% [SS_IN,SS_INP,SS_OUT] = IOFC(SS_) or
% [AIN,BIN,CIN,DIN,AINP,BINP,CINP,DINP,AOUT,BOUT,COUT,DOUT] = IOFC(A,B,C,D)
%   produces an inner-outer factorization of a
%   m x n transfer function G: SS_ = MKSYS(A,B,C,D) (m<n)
%     such that
%                      G = |M  0| |Th |
%                                 |Thp|
%     where
%                     |Th |: square and inner
%                     |Thp|
%
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

[ain,bin,cin,din,ainp,binp,cinp,dinp,aout,bout,cout,dout] = iofr(a',c',b',d');
% Trnaspose the state-spaace:
ain = ain'; temp = bin; bin = cin'; cin = temp'; din = din';
ainp = ainp'; temp = binp; binp = cinp'; cinp = temp'; dinp = dinp';
aout = aout'; temp = bout; bout = cout'; cout = temp'; dout = dout';

if xsflag
  ain = mksys(ain,bin,cin,din);
  bin = mksys(ainp,binp,cinp,dinp);
  cin = mksys(aout,bout,cout,dout);
end
%
% ------ End of IOFC.M ---- RYC/MGS 8/85 %