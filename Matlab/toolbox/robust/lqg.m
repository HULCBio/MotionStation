function [af,bf,cf,df] = lqg(varargin)
%LQG Continuous linear-quadratic-Gaussian control synthesis.
%
% [SS_F] = LQG(SS_,W,V) or
% [AF,BF,CF,DF] = LQG(A,B,C,D,W,V) computes Linear-Quadratic-Gaussian
%    optimal controller via the "separation principle", such that the
%    cost function
%                     T
%    J    = lim E{ int   |x' u'| W |x| dt} , W = |Q  Nc|, is minimized
%     LQG   T-->inf   0            |u|           |Nc' R|
%    and subject to the plant
%                       dx/dt = Ax + Bu + xi
%                           y = Cx + Du + th
%
%    where the white noises {xi} and {th} have the cross-correlation
%    function with intensity V, i.e.
%
%           E{|xi| |xi th|'} = V delta(t-tau), V =  |Xi  Nf|.
%             |th|                                  |Nf' Th|
%
%    The LQG optimal controller F(s) is returned in SS_F or (af,bf,cf,df).
%    The standard state-space can be recovered by "branch".

% R. Y. Chiang & M. G. Safonov 8/86
% Copyright 1988-2004 The MathWorks, Inc.
%       $Revision: 1.10.4.3 $
% All Rights Reserved.
% -------------------------------------------------------------------------

% Disable LTI support to preserve future options for
% possible future LTI-specific syntax changes in LQG
if isa(varargin{1},'lti'),
   error('LTI input is not allowed.  Consider using syntax LQG(A,B,C,D,W,V) or LQG(MKSYS(A,B,C,D),W,V)'),
end


nag1=nargin;
[emsg,nag1,xsflag,Ts,A,B,C,D,W,V]=mkargs5x('ss',varargin); error(emsg);
if Ts, error('LTI inputs must be continuous time (Ts=0)'), end

%
[ns,ns] = size(A);
[nout,nin]= size(D);
%
% ------- Regular LQG problem:
%
Kf = lqrc(A',C',V); Kf = Kf';
Kc = lqrc(A,B,W);
%
% ------- Final Controller:
%
af = A - B*Kc - Kf*C + Kf*D*Kc;
bf = Kf;
cf = Kc;
df = zeros(nin,nout);
%
if xsflag
   af = mksys(af,bf,cf,df);
end
%
% ------- End of LQG.M -- RYC/MGS %