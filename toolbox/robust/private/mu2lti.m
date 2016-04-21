function sys=mu2lti(sys)
% SYS1=MU2LTI(SYS) converts obsolete PCK
% systems from Mu Synthesis Toolbox to LTI systems

%     systems to LTI systems.  I

%
% See also:  MKSYS, LTI

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.5.4.3 $
% All rights reserved.

% Quick return if not a PCK system
if ~isequal(class(sys),'double') | min(size(sys))< 2 | ~isequal(sys(end,end),-Inf),
   return
end

info='';
if exist('minfo')==2,
   [info,junk,junk,junk]=feval('minfo',sys);
   if ~strcmp(info,'syst'), return, end
else
   return
end

if any(any(imag(sys))) & exist('sinfo')==2,
   [a,b,c,d,e]=feval('ltiss',sys); % unpacks both old LMITOOLS ltisys.m and pck.m systems
   sys=dss(a,b,c,d,e);
   return
else
   [a,b,c,d]=feval('unpck',sys); % unpack old Mu Synthesis Toolbox pck.m system
   sys=ss(a,b,c,d);
end

% ----------- End of MU2LTI.M --------RYC/MGS 1997
