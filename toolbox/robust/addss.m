function [a,b,c,d] = addss(varargin)
%ADDSS Add two state-space systems together.
%
% [SS_] = ADDSS(SS_1,SS_2) or
% [A,B,C,D] = ADDSS(A1,B1,C1,D1,A2,B2,C2,D2) add two state-space realization:
%
%                                           -1
%             G(s) = G1(s) + G2(s) = C(Is-A)  B + D
%       where
%                              -1
%             G1(s) = C1(Is-A1)  B1 + D1,  SS_1 = MKSYS(A1,B1,C1,D1)
%
%                              -1
%             G2(s) = C2(Is-A2)  B2 + D2,  SS_2 = MKSYS(A2,B2,C2,D2);

% R. Y. Chiang & M. G. Safonov 8/85
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.

% Handle lti's with fall though to sys1+sys2
if isa(varargin{1},'lti') | isa(varargin{2},'lti'),
   warning('Usage ADDSS(SYS1,SYS2) is obsolete.  For LTI objects, use SYS1+SYS2 instead.');
   a=rct2lti(varargin{1})+rct2lti(varargin{2});
   return;
end

nag1=nargin;
[emsg,nag1,xsflag,Ts,a1,b1,c1,d1,a2,b2,c2,d2]=mkargs5x('ss',varargin); error(emsg);

[rb1,cb1] = size(b1);
[rc1,cc1] = size(c1);
[rb2,cb2] = size(b2);
[rc2,cc2] = size(c2);
%
if (cb1 ~= cb2) + (rc1 ~= rc2)
   ERROR = 'TWO SYSTEMS ARE NOT COMPATIABLE !'
   return
end
%
a = [a1 zeros(rb1,cc2); zeros(rb2,cc1) a2];
b = [b1;b2];
c = [c1 c2];
d = d1 + d2;

if xsflag
   a = mksys(a,b,c,d,Ts);
end
%
% ----- End of ADDSS.CTR ---- RYC/MGS 8/85%