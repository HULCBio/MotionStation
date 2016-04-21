function [varargout] = beep(varargin)
%BEEP Produce beep sound.
%    BEEP produces a beep sound.
%    BEEP ON turns the beep on.
%    BEEP OFF turns the beep off.
%    S = BEEP returns the beep status: 'on' or 'off'.
%
%    See also ERROR.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.6.4.2 $

%   Built-in function.

if nargout == 0
  builtin('beep', varargin{:});
else
  [varargout{1:nargout}] = builtin('beep', varargin{:});
end
