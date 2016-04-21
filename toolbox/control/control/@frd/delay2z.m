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

%	 P. Gahinet, S. Almy
%	 Copyright 1986-2002 The MathWorks, Inc. 
%	 $Revision: 1.10.4.1 $  $Date: 2002/11/11 22:21:22 $

error(nargchk(1,1,nargin));

Td = totaldelay(sys);
if ~any(Td(:)),
   return
end
sizeSys = size(sys.ResponseData);

% convert Td to sec for discrete time
L = sys.lti;
Ts = get(L,'Ts');
if Ts ~= 0
   Td = Td * abs(Ts);
end

if strncmpi(sys.Units,'h',1)
   factor = 2*pi;
else
   factor = 1;
end

hTd = delayfr(Td,sqrt(-1)*factor*sys.Frequency);
if prod(size(hTd))<prod(sizeSys)
   hTd = repmat(hTd,[1 1 1 sizeSys(4:end)]);
end
sys.ResponseData = hTd .* sys.ResponseData;

% Set I/O delays to zero
sys.lti = pvset(sys.lti,'InputDelay',zeros(sizeSys(2),1),...
   'OutputDelay',zeros(sizeSys(1),1),...
   'ioDelay',zeros(sizeSys(1:2)));
                   
                   
                   
                   
                   

