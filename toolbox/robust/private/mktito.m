function sys=mktito(sys,nmeas,ncont)
% SYS=MKTITO(SYS,NMEAS,NCONT) adds TITO partitioning to 
%    a system by re-setting its InputGroup and
%    OutputGroup properties, labeling last NMEAS
%    output channels 'measurement' and the last NCONT input
%    channels 'command'.  Other output and input channels 
%    are labeled 'error'  and 'disturbance', respectively. 
%    Any pre-existing partition of SYS is overwritten.

% R. Y. Chiang & M. G. Safonov
% Copyright 1988-2004 The MathWorks, Inc.
% $Revision: 1.5.4.4 $
% All rights reserved.

% Based on Gahinet's 01/98 partitioning specification

[r,c]=size(sys);
if ~isa(sys,'lti'), error('SYS is not an LTI object'), end
if r<nmeas, error('NMEAS exceeds SYS output dimension'), end
if c<ncont, error('NCONT exceeds SYS input dimension'), end

set(sys,'InputGroup',{ 1:c-ncont 'U1'; c-ncont+1:c 'U2' });
set(sys,'OutputGroup',{ 1:r-nmeas 'Y1'; r-nmeas+1:r 'Y2'});

% ----------- End of MKTITO.M --------RYC/MGS 1997

