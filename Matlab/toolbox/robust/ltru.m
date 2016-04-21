function [af,bf,cf,df,svl] = ltru(varargin)
%LTRU Continuous LQG/LTR control synthesis (at plant input).
%
% [ss_f,svl] = ltru(ss_,Kc,Xi,Th,r,w,svk) or
% [af,bf,cf,df,svl] = ltru(A,B,C,D,Kc,Xi,Th,r,w,svk) produces
%    LQG/LTR at inputs of the plant, such that the LQG loop TF
%    will converge to LQSF's loop TF as the plant noise goes to INF:
%                        -1                  -1
%     GKc(Is-A+B*Kc+Kf*C) Kf -------> Kc(Is-A) B   (as r --> INF)
%
%  Inputs: (A,B,C,D) -- system, or ss_ -- system matrix (built by "mksys")
%          Kc -- LQSF gain
%  (optional) svk(MIMO) -- SV of (Kc inv(Is-A)B)
%  (optional) svk(SISO) -- [re im;re(reverse order) -im(reverse order)]
%                          of complete Nyquist plot
%          w --- frequency points
%          Xi -- plant noise intensity, Th -- sensor noise intensity
%          r --- a row vector containing a set of recovery gains
%               (nr: length of r). At each iteration, Xi <-- Xi + r*B*B';
%  Outputs: svl -- singular value plots of all the recovery points
%           svl(SISO) -- Nyquist loci svl = [re(1:nr) im(1:nr)]
%           final state-space controller (af,bf,cf,df).

% R. Y. Chiang & M. G. Safonov 6/86
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.9.4.3 $
% All Rights Reserved.
% ------------------------------------------------------------------
%

nag1 = nargin;
[emsg,nag1,xsflag,Ts,A,B,C,D,Kc,Xi,Th,r,w,svk]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end
    % NAG1 may have changed
if nag1 == 10
   [af,bf,cf,df,svl] = ltry(A',C',B',D',Kc',Xi,Th,r,w,svk);
else
   [af,bf,cf,df,svl] = ltry(A',C',B',D',Kc',Xi,Th,r,w);
end
%
% ---- Transpose the controller
%
af = af';
bftemp = bf;
bf = cf';
cf = bftemp';
df = df';

if xsflag
   af = mksys(af,bf,cf,df);
   bf = svl;
end
%
% ------- End of LTRU.M -- RYC %