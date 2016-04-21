function nmh2 = normh2(varargin)
%NORMH2 Continuous H2 norm.
%
% [NMH2] = NORMH2(A,B,C,D) or
% [NMH2] = NORMH2(SS_) computes the H2 norm of the given state-space
%    realization. If the system not strictly proper, INF is returned.
%    Otherwise, the H2 norm is computed as
%
%            NMH2 = trace[CPC']^0.5 = trace[B'QB]^0.5
%
%    where P is the controllability grammian, and Q is the observability
%    grammian.

% R. Y. Chiang & M. G. Safonov 8/91
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.

nag1=nargin;
[emsg,nag1,xsflag,Ts,a,b,c,d]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end


if norm(d,'fro') > sqrt(eps)
   nmh2 = inf;
   return
end

P = gram(a,b);
nmh2 = sqrt(trace(c*P*c'));

%
% ---- End of NORMH2.M % RYC/MGS %