function sys = delay2z(sys)
%DELAY2Z  Replaces delays by poles at z=0 or FRD phase shift.  
%
%   For discrete-time TF, ZPK, or SS models SYS,
%      SYSND = DELAY2Z(SYS) 
%   maps all time delays to poles at z=0.  Specifically, a 
%   delay of k sampling periods is replaced by (1/z)^k.
%
%   For state-space models,
%      [SYSND,G] = DELAY2Z(SYS)
%   also returns the matrix G mapping the initial state x0
%   of SYS to the corresponding initial state G*x0 for SYSND.
%   
%   For FRD models, DELAY2Z absorbs all time delays into the 
%   frequency response data, and is applicable to both 
%   continuous- and discrete-time FRDs.
%
%   See also HASDELAY, PADE, LTIMODELS.

%	 P. Gahinet 8-28-96
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.9 $  $Date: 2002/04/10 06:08:07 $

error(nargchk(1,1,nargin));

Td = totaldelay(sys);
if getst(sys.lti)==0,
   error('LTI model SYS must be discrete.')
elseif ~any(Td(:)),
   return
end

% Map the I/O delays to poles at zero
sizes = size(sys.num);
if ndims(Td)<length(sizes), 
   Td = repmat(Td,[1 1 sizes(3:end)]);
end

for k=find(Td(:))',
   Tdk = Td(k);
   sys.num{k} = [zeros(1,Tdk) sys.num{k}];
   sys.den{k} = [sys.den{k} zeros(1,Tdk)];
end

% Set I/O delays to zero
sys.lti = pvset(sys.lti,'InputDelay',zeros(sizes(2),1),...
   'OutputDelay',zeros(sizes(1),1),...
   'ioDelay',zeros(sizes(1:2)));



