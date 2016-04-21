function [varargout] = pause(varargin)
%PAUSE Wait for user response.
%   PAUSE(n) pauses for n seconds before continuing, where
%   n can also be a fraction. The resolution of the clock 
%   is platform specific. Fractional pauses of 0.01 seconds
%   should be supported on most platforms.
%
%   PAUSE causes a procedure to stop and wait for the user to 
%   strike any key before continuing.
%
%   PAUSE OFF indicates that any subsequent PAUSE or PAUSE(n)
%   commands should not actually pause.  This allows normally
%   interactive scripts to run unattended.
%
%   PAUSE ON indicates that subsequent PAUSE commands should pause.
%
%   See also KEYBOARD, INPUT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.12.4.3 $  $Date: 2004/04/16 22:08:59 $
%   Built-in function.


if nargout == 0
  builtin('pause', varargin{:});
else
  [varargout{1:nargout}] = builtin('pause', varargin{:});
end
