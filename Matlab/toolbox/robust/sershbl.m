function [a,b,c,d,hsv] = sershbl(varargin)
%SERSHBL Minimal realization of two state-space system in series.
%
% [SS_,HSV] = SERSHBL(SS_1,SS_2,SERAUG) or
% [A,B,C,D,BND] = SERSHBL(A1,B1,C1,D1,A2,B2,C2,D2,seraug) produces a
%     minimal realization of two state space in series via real
%     Schur Balanced model reduction.
%

% R. Y. Chiang & M. G. Safonov 8/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
%
nag1=nargin;
[emsg,nag1,xsflag,Ts,a1,b1,c1,d1,a2,b2,c2,d2,seraug]=mkargs5x('ss,ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

[aa,bb,cc,dd] = series(a1,b1,c1,d1,a2,b2,c2,d2);
[a,b,c,d,bnd,hsv] = schmr(aa,bb,cc,dd,seraug(1,1),seraug(1,2));

if xsflag
   a = mksys(a,b,c,d);
   b = hsv;
end
%
% ----- End of SERSHBL.M --- RYC/MGS 8/87 %