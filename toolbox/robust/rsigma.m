%   SV = SIGMA(A, B, C, D, TY, W) or
%   SV = SIGMA(SS_,TY,W)
%   returns a matrix SV containing the singular value
%   frequency response of the following systems depending
%   on the value of TY:
%      TY = 1   ----   G(jw)
%      TY = 2   ----   inv(G(jw))
%      TY = 3   ----   I + G(jw)
%      TY = 4   ----   I + inv(G(jw))
%   where G(jw) is the frequency response of the system
%                 .
%                 x = Ax + Bu
%                 y = Cx + Du.
%
%   SS_ is a state-space system created by the
%   command  SS_=MKSYS(A,B,C,D) and W is a vector
%   of real frequencies.
%
%   The foregoing syntax is available when the
%   ROBUST CONTROL TOOLBOX is installed and is
%   in addition alternate syntaxes described in
%   the documentation for the function SIGMA.
%
%   See also  SIGMA, DSIGMA, RDSIGMA

% RSIGMA.M for ROBUST CONTROL TOOLBOX
% R. Y. Chiang & M. G. Safonov 9/30/96
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.7.4.3 $
% All Rights Reserved.
% ---------------------------------------------------------------------------
