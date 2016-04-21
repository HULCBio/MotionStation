function [g] = clxbode(varargin);
%CLXBODE Continuous complex frequency response (SIMO).
%
%[G] = CLXBODE(SS_,IU,W) or
%[G] = CLXBODE(A,B,C,D,IU,W) produces a complex gain instead of an
%      absolute gain.

% R. Y. Chiang & M. G. Safonov 6/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.
% ----------------------------------------------------------------
%

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,iu,w]=mkargs5x('ss',varargin); error(emsg);

% discrete case (call DCLXBODE)   
if Ts, 
   [g] = dclxbode(varargin{:},abs(Ts));
   return
end   

% continuous case

[rc,cc] = size(c);
cs = max(size(w));
%
b = b(:,iu);
d = d(:,iu);
s = sqrt(-1) * w;
g = ltifr(a,b,s);
g = c * g + diag(d) * ones(rc,cs);
%
% ----- End of CLXBODE.M ---- RYC/MGS 6/85 %







