function bivis=isvisible(cc)
%ISVISIBLE returns visibility status of Code Composer window.
%   O = ISVISIBLE(CC) returns true if the Code Composer window is
%   open on the desktop.  Conversely, this method returns false if
%   Code Composer is running but does not have a presence on the 
%   computer desktop (i.e. is running in the background).
%   Note: CC can be a single CCSDSP handle or vector of CCSDSP handles.
%
%   See also VISIBLE,INFO.

%     Copyright 2000-2004 The MathWorks, Inc.
%     $Revision: 1.7.4.4 $ $Date: 2004/04/08 20:45:50 $

error(nargchk(1,1,nargin));
bivis = callSwitchyard(cc(1).ccsversion,[3,cc(1).boardnum,cc(1).procnum,0,0]);

% [EOF] isvisible.m