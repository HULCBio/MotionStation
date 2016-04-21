function L = mpower(L,k)
%MPOWER  Repeated product of LTI models.
%
%   MPOWER(SYS,K) is invoked by SYS^K where SYS is any 
%   LTI model with the same number of inputs and outputs, 
%   and K must be an integer.  The result is the LTI model
%     * if K>0, SYS * ... * SYS (K times) 
%     * if K<0, INV(SYS) * ... * INV(SYS) (K times)
%     * if K=0, the static gain EYE(SIZE(SYS)).
%
%   The syntax SYS^K is useful to specify transfer functions
%   in a pseudo-symbolic manner. For instance, you can specify
%             - (s+2) (s+3)
%      H(s) = ------------
%             s^2 + 2s + 2
%   by typing
%      s = tf('s')
%      H = -(s+2)*(s+3)/(s^2+2*s+2) .
%
%   See also TF, PLUS, MTIMES, LTIMODELS.

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 05:49:28 $

[ny,nu] = size(L.ioDelay(:,:,1));

% Update time delay
if k==0,
   L.InputDelay = zeros(nu,1);
   L.OutputDelay = zeros(ny,1);
   L.ioDelay = zeros(ny,nu);
else
   % Below SYS is always SISO and K>0
   L.ioDelay = ...
      k * (L.ioDelay + L.InputDelay + L.OutputDelay) - (L.InputDelay + L.OutputDelay);
end
