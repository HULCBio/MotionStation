function [varargout] = drawnow(varargin)
%DRAWNOW Flush pending graphics events.
%   DRAWNOW "flushes the event queue" and forces MATLAB to
%   update the screen. 
%
%   There are four events that cause MATLAB to flush the event
%   queue and draw the screen:
%
%   - a return to the MATLAB prompt
%   - hitting a PAUSE statement
%   - executing a GETFRAME command
%   - executing a DRAWNOW command

%   DRAWNOW('DISCARD') causes the information to be updated as if
%   the queued events were flushed, but doesn't actually flush
%   them.  This is needed for printing hardcopy when the figure
%   property InvertHardcopy is on.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.9.4.2 $  $Date: 2004/04/10 23:28:39 $
%   Built-in function.

if nargout == 0
  builtin('drawnow', varargin{:});
else
  [varargout{1:nargout}] = builtin('drawnow', varargin{:});
end
