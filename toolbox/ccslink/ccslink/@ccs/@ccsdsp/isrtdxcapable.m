function birtdx = isrtdxcapable(mcc)
%ISRTDXCAPABLE Returns RTDX capability of target DSP.
%   B = ISRTDXCAPABLE(CC) returns true if the target DSP referenced by the
%   CC handle supports Real-Time Data Exchange(tm). 
%
%   Note: If CC contains more than one processor, this method returns an
%   array containing the RTDX capability of each processor. 
%     
%   See also RTDX.

%     Copyright 2001-2004 The MathWorks, Inc.
%     $Revision: 1.6.4.4 $ $Date: 2004/04/06 01:04:47 $

error(nargchk(1,1,nargin));

for k = 1:length(mcc)
    cc = mcc(k);
    birtdx(k) = callSwitchyard(cc.ccsversion,[23,cc.boardnum,cc.procnum,0,0]);
end

% [EOF] isrtdxcapable.m