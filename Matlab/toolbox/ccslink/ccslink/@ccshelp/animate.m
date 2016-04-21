function animate(cc)
%ANIMATE Run application until breakpoint is reached.
%   ANIMATE(CC) is similar to the RUN method. It causes the target 
%   to execute until a breakpoint is reached.  The target is then
%   halted and information in Code Composer Studio(R) is 
%   updated. However, unlike RUN, the ANIMATE method will resume 
%   execution after the information is updated.  The execution will
%   continue to cycle through break/run phases until the target
%   is manually halted.
%
%   Unlike the RUN or RESTART methods, there is no timeout option 
%   for ANIMATE. This method always returns immediately. If the 
%   DSP execution must be stopped, the user should manually invoke
%   the HALT method.
%
%   See also RUN, HALT, RESTART.

% Copyright 2004 The MathWorks, Inc.
