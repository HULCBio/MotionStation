function sysk = mpower(sys,k)
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

%   Author(s): P. Gahinet, 1-98
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.8 $  $Date: 2002/04/10 06:01:09 $

error(nargchk(1,2,nargin))
sizes = size(sys.d);

% Error checking
if sizes(1)~=sizes(2),
   error('SYS must have the same number of inputs and outputs.')
elseif ~isa(k,'double') | ~isequal(size(k),[1 1]),
   error('Second argument K must be a scalar.')
elseif k~=round(k),
   error('Second argument K must be an integer.')
end

% Preprocessing
if k==0,
   % K=0 -> quick exit
   sysk = ss(repmat(eye(sizes(1)),[1 1 sizes(3:end)]),sys);
   sysk.lti = mpower(sys.lti,k);
   return
elseif k<0,
   % Replace SYS by INV(SYS) and K by -K
   try
      sys = inv(sys);
   catch
      rethrow(lasterror)
   end
   k = -k;
end

% Left with SYS^K with K>0.
sysk = sys;
for j=1:k-1,
   sysk = mtimes(sysk,sys);
end
