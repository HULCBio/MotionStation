function [A,B,C,D] = feedbk(varargin)
%FEEDBK Feedback closed-loop state-space realization.
%
% [SS_] = FEEDBK(SS_1,FBTYPE,SS_2) or
% [A,B,C,D] = FEEDBK(A1,B1,C1,D1,FBTYPE,A2,B2,C2,D2) produces a
%    state-space closed-loop transfer function for 5 common
%    types of negative feedback:
%
% fbtype = 1 ---- forward loop, I; feedback loop, (A1,B1,C1,D1).
% fbtype = 2 ---- forward loop, (A1,B1,C1,D1); feedback loop, I.
% fbtype = 3 ---- forward loop, (A1,B1,C1,D1); feedback loop, (A2,B2,C2,D2).
% fbtype = 4 ---- state feedback: A2 <-- F.
% fbtype = 5 ---- output injection: A2 <-- H.
%

% R. Y. Chiang & M. G. Safonov 6/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------------
%
nag1 = nargin;

[emsg,nag1,xsflag,Ts,a1,b1,c1,d1,fbtype,a2,b2,c2,d2]=mkargs5x('ss',varargin); error(emsg);
     % NAG1 may have changed

if nag1 == 6 & fbtype == 4
   % Case (a1,b1,c1,d1,fbtype,F)
   f = a2;
end
if nag1 == 6 & fbtype == 5
   % Case (a1,b1,c1,d1,fbtype,H)
   h = a2;
end

if fbtype== 1
   sz = size(d1)*[1;0];
   idiv = inv(eye(sz)+d1);
   A = a1-b1*idiv*c1;
   B = b1*idiv;
   C = -idiv*c1;
   D = idiv;
end
%
if fbtype== 2
   sz = size(d1)*[1;0];
   idiv = inv(eye(sz)+d1);
   A = a1-b1*idiv*c1;
   B = b1*idiv;
   C = idiv*c1;
   D = idiv*d1;
end
%
if fbtype== 3
   dji = d2*d1;
   dij = d1*d2;
   szj = size(dji)*[1;0];
   szi = size(dij)*[1;0];
   iii = inv(eye(szj)+dji);
   jjj = inv(eye(szi)+dij);
   A = [a1-b1*iii*d2*c1 -b1*iii*c2;b2*jjj*c1 a2-b2*jjj*d1*c2];
   B = [b1*iii;b2*jjj*d1];
   C = [jjj*c1 -jjj*d1*c2];
   D = jjj*d1;
end
%
if fbtype== 4
   f = a2;
   A = a1-b1*f;
   B = b1;
   C = c1-d1*f;
   D = d1;
end
%
if fbtype== 5
   h = a2;
   A = a1-h*c1;
   B = b1-h*d1;
   C = c1;
   D = d1;
end
%
if xsflag
   A = mksys(A,B,C,D,Ts);
   if isa(varargin{1},'lti'),
      warning('FEEDBK is obsolete. For LTI objects, consider using FEEDBACK');
      A=rct2lti(A);
   end
end
%
% ------- End of FEEDBK.M -- % RYC/MGS %