function [ai,bi,ci,di] = ssinv(varargin)
%SSINV State-space inversion.
%
% [SS_I] = SSINV(SS_) or
% [AI,BI,CI,DI] = SSINV(A,B,C,D) computes the inverse system
%                       -1
%         GI(s) = [G(s)]
%                                        -1         -1      -1           -1
% using the state-space formulae AI=A-B D  C, BI=B D  , CI=-D  C, and DI=D  .


% R. Y. Chiang & M. G. Safonov 8/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.

% Handle lti's with fall though to lti/inv
if isa(varargin{1},'lti'),
   warning('Usage SSINV(SYS) is obsolete.   For LTI object SYS, use INV(SYS) instead.');
   ai=inv(varargin{1});
   return; 
end

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d]=mkargs5x('ss',varargin); error(emsg);

%
di = inv(d);
ai = a - b*di*c;
bi = b*di;
ci = -di*c;

if xsflag
   ai = mksys(ai,bi,ci,di,Ts);
end
%
% ---------------- End of SSINV.M -- RYC/MGS %
