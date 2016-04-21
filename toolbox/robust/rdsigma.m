%   SV = DSIGMA(A, B, C, D, TY, W, T) or
%   SV = DSIGMA(SS_,TY,W,Ts)
%   returns a matrix SV containing the discrete-time
%   singular value frequency response of the following
%   systems depending on the value of TY:
%      TY = 1   ----   G(exp(jwT))
%      TY = 2   ----   inv(G(exp(jwT))
%      TY = 3   ----   I + G(exp(jwT))
%      TY = 4   ----   I + inv(G(exp(jwT)))
%   where G(z) is the frequency response of the
%   discrete system
%            x[n+1] = Ax[n] + Bu[n]
%              y[n] = Cx[n] + Du[n].
%
%   SS_ is a state-space system created by the
%   command  SS_=MKSYS(A,B,C,D), W is a vector
%   of real frequencies at which the singular
%   values are evaluated, and T is the sampling
%   interval.
%
%   The foregoing syntax is available when the
%   ROBUST CONTROL TOOLBOX is installed and is
%   in addition alternate syntaxes described in
%   the documentation for the function DSIGMA.
%
%   See also  DSIGMA, RSIGMA, SIGMA

% RSIGMA.M for ROBUST CONTROL TOOLBOX
% R. Y. Chiang & M. G. Safonov 9/30/96
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.7.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------------
