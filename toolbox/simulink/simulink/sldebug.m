function [varargout] = sldebug(varargin)
%SLDEBUG Simulate a Simulink model under the Simulink debugger.
%   SLDEBUG('model') will run the Simulink model in the Simulink debugger.
%   You can obtain help for the Simulink debugger by typing help at the
%   debugger prompt.
%
%   The SLDEBUG command is equivalent to the SIM command with
%   SIMSET('Debug','on') always specified.
%
%   See also SIM, SIMSET.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.7.2.2 $
%   Built-in function.

if nargout == 0
  builtin('sldebug', varargin{:});
else
  [varargout{1:nargout}] = builtin('sldebug', varargin{:});
end
