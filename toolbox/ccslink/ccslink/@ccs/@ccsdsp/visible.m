function visible(cc,state)
%VISIBLE sets the visibility state of the Code Composer Studio(R) window.
%   VISIBLE(CC,STATE) If STATE is 1 (true), the Code Composer application
%   referenced by CC is forced to open and then becomes available 
%   for direct user interaction.  Conversely, if STATE is set to 0 (false), 
%   the Code Composer application is placed in the background.  In this 
%   case, it runs silently and can only be manipulated with it's 
%   handle (i.e. CC) from MATLAB.
%
%   Note: CC can be a single CCSDSP handle or vector of CCSDSP handles.
%
%  See also ISVISIBLE,INFO.

%     Copyright 2000-2004 The MathWorks, Inc.
%     $Revision: 1.8.2.6 $ $Date: 2004/04/08 20:45:56 $

error(nargchk(2,2,nargin));
callSwitchyard(cc(1).ccsversion,[2,cc(1).boardnum,cc(1).procnum,0,0],double(state));

% [EOF] visible.m