function [mu,logd] = ssv(varargin)
%SSV Structured singular value frequency response.
%
% [MU,LOGD] = SSV(A,B,C,D,W) or SSV(A,B,C,D,W,K) or (A,B,C,D,W,K,OPTION)
% or [MU,LOGD] = SSV(SS_,...), etc. produces the row-vector MU
% containing an upper bound on the structured singular value (ssv) of
%        G(jw) = C * inv(jwI-A) * B + D
% at each frequency in the real vector w.
% Input:
%     A,B,C,D  -- state-space matrices of pxq transfer function matrix G(s)
%     W        -- vector of frequencies at which MU is to be computed
% Optional inputs:
%     K  -- uncertainty block sizes--default is K=ones(q,2).  K is an
%           an nx1 or nx2 matrix whose rows are the uncertainty block
%           sizes for which the ssv is to be evaluated; K must satisfy
%           sum(K) == [q,p].If i_th uncertainty is real, set K(i,:) = [-1 -1].
%           If only the first column of K is given then the
%           uncertainty blocks are taken to be square, as if K(:,2)=K(:,1).
%
%     OPTION  -- method for computing MU, one of the following: 'psv' (optimal
%            diagonally scaled Perron, by default), 'osborne', 'perron', and
%            'muopt' (multiplier approach for real/complex uncertainties).
% Outputs:
%     MU      -- the bode plot of MU
%     LOGD    -- the optimal diagonal scaling D, (exp(LOGD) is the value)

% R. Y. Chiang & M. G. Safonov 1/87
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% -------------------------------------------------------------------
%

nag1 = nargin;
nag2 = nargout;
[emsg,nag1,xsflag,Ts,a,b,c,d,w,k,option]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end
       % NAG1 may have been changed

if nag1 == 5
   [rd,cd] = size(d);
   k = ones(cd,2);
   option = 'psv';
end

if isempty(k)
   [rd,cd] = size(d);
   k = ones(cd,2);
end;

fprintf('Executing SSV.');

if nag1 < 7
   option = 'psv';
end

[mg] = freqrc(a,b,c,d,w);
[rmg,cmg] = size(mg);
[rd,cd] = size(d);
gg = ones(rd,cd);
[rk,ck] = size(k);
logd = zeros(rk,cmg);
%
for is = 1 : cmg
     fprintf('.');
     gg(:) = mg(:,is);
     if issame('psv',option),
        [mu(is),junk,logd(:,is)] = psv(gg,k);
     elseif issame('perron',option)
        mu(is) = perron(gg,k);
     else
        eval(['[mu(is),junk,logd(:,is)] = ' option '(gg,k);']);
     end
end
fprintf('.Done SSV\n');
%
% ----- End of SSV.M ---- RYC/MGS 8/88