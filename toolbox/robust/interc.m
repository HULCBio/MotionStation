function [acl,bcl,ccl,dcl] = interc(varargin)
%INTERC State-space interconnected system.
%
% [SS_CL] = INTERC(SS_,M,N,F) or
% [ACL,BCL,CCL,DCL] = INTERC(A,B,C,D,M,N,F) produces a state space
%        realization of the interconnected system, given system
%        G:(A,B,C,D) and constant blocks -- M, N and F representing
%        the interconnections. The general set-up is as follows:
%
%           - - -    +          - - -           - - -
%   R ----->| M |----->0------->| G |---------->| N |------> Y
%           - - -      ^ +      - - -      |    - - -
%                      |                   |
%                      |        - - -      |
%                      ---------| F |<------
%                               - - -
% Note: ss_ = mksys(a,b,c,d);

% R. Y. Chiang & M. G. Safonov 6/86
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------
%

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d,m,n,f]=mkargs5x('ss',varargin); error(emsg);

df = d * f;
[rdf,cdf] = size(df);
k = inv(eye(rdf)-df);
acl = a + b * f * k * c;
bcl = b * (m + f * k * d * m);
ccl = n * k * c;
dcl = n * k * d * m;
%
if xsflag
   acl = mksys(acl,bcl,ccl,dcl,Ts);
end
%
% ----- End of INTERC.M ---- RYC/MGS 6/86 %