function resp=tconf(cc,command)
%TCONF  accepts Javascript commands for DSP/BIOS configuration
%  STDOUT = TCONF(CC,CMD) - Provides a gateway to the DSP/BIOS
%  configuration tool: 'TCONF'.  The TCONF utility accepts 
%  Javascript commands to dynamically configure DSP/BIOS objects.
%
%  See Also PROFILE.

%  Copyright 2001-2004 The MathWorks, Inc.
%  $Revision: 1.5.4.2 $  $Date: 2004/04/01 16:02:54 $

error(nargchk(2,2,nargin));

if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle.');
end

temp = callSwitchyard(cc.ccsversion,[51,cc.boardnum,cc.procnum,0,0],command);

if ~isempty(temp),
    resp = temp;
end 

% [EOF] tconf.m