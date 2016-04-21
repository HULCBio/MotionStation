function [g] = dclxbode(varargin)
%DCLXBODE Discrete complex frequency response (SIMO).
%
% [G] = DCLXBODE(SS_,IU,W,TS) or
% [G] = DCLXBODE(A,B,C,D,IU,W,TS)  calculates the frequency
%       response of the system:
%			x[n+1] = Ax[n] + Bu[n]		          -1
%			y[n]   = Cx[n] + Du[n]	     G(z) = C(zI-A) B + D
%
%	from the iu'th input.  Vector W must contain the frequencies, in
%	radians, at which the Bode response is to be evaluated.  DCLXBODE
%       returns matrices MAG and PHASE (in degrees) with as many columns
%	as there are outputs y, and with LENGTH(W) rows.
%

% R. Y. Chiang & M. G. Safonov 6/23/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------------
%

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,iu,w,Ts]=mkargs5x('ss',varargin); error(emsg);

[no,ns] = size(c);
nw = max(size(w));
b = b(:,iu);
d = d(:,iu);
w = exp(sqrt(-1) * w * Ts);
g = ltifr(a,b,w);
g = c * g + diag(d) * ones(no,nw);
%
% ------ End of DCLXBODE.M --- RYC/MGS 6/23/87 %