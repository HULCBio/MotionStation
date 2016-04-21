function [varargout] = gcbh(varargin)
%GCBH Get the handle to the current Simulink block.
%   GCBH returns the handle to the current block in the current
%   system.  During editing, the current block is the one most recently
%   clicked upon.  During simulation of a system containing S-function
%   blocks, the current block is the S-function block currently executing
%   its corresponding MATLAB function.  During callbacks, the current block
%   is the one whose callback is being executed.  During evaluation of the
%   MaskInitialization string, the current block is the one whose mask is
%   being evaluated.
%   
%   See also GCB, GCS.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.5.2.2 $
%   Built-in function.

if nargout == 0
  builtin('gcbh', varargin{:});
else
  [varargout{1:nargout}] = builtin('gcbh', varargin{:});
end
