function [varargout] = waitforbuttonpress(varargin)
%WAITFORBUTTONPRESS Wait for key/buttonpress over figure.
%   T = WAITFORBUTTONPRESS stops program execution until a key or
%   mouse button is pressed over a figure window.  Returns 0
%   when terminated by a mouse buttonpress, or 1 when terminated
%   by a keypress.  Additional information about the terminating
%   event is available from the current figure.
%
%   See also GINPUT, GCF.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 5.7.4.2 $  $Date: 2004/04/10 23:34:47 $
%   Built-in function.


if nargout == 0
  builtin('waitforbuttonpress', varargin{:});
else
  [varargout{1:nargout}] = builtin('waitforbuttonpress', varargin{:});
end
