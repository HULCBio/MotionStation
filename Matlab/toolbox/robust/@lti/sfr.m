function [am,bm,cm,dm] = sfr(varargin)
%SFR Right spectral factorization.
%
% [SS_M] = SFR(SS_) or
% [AM,BM,CM,DM] = SFR(A,B,C,D) produces a right spectral factorization
%      via the duality of SFL such that
%
%                 M(s)M'(-s) = I - G(s)G'(-s)
%
%                Input data:  G(s):= SS_ = MKSYS(A,B,C,D);
%                Output data: M(s):= SS_M = MKSYS(AM,BM,CM,DM);
%
%  The regular state-space can be recovered by "branch".

% R. Y. Chiang & M. G. Safonov 7/85
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.7.4.3 $
% ---------------------------------------------------------------------
%
nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

[amm,bmm,cmm,dmm] = sfl(a',c',b',d');
am = amm';
bm = cmm';
cm = bmm';
dm = dmm';
%
if xsflag
   am = mksys(am,bm,cm,dm);
end
%
% ------ End of SFR.M ---- RYC/MGS 7/85 %
