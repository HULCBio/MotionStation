function [varargout] = delete_block(varargin)
%DELETE_BLOCK Delete a block from a Simulink system.
%   DELETE_BLOCK('BLK'), where 'BLK' is a full block path name, deletes the
%   specified block from a system.
%   
%   Example:
%   
%       delete_block('vdp/Out1')
%   
%   removes block 'Out1' from the vdp system.

%   See also ADD_BLOCK.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.15.2.2 $
%   Built-in function.

if nargout == 0
  builtin('delete_block', varargin{:});
else
  [varargout{1:nargout}] = builtin('delete_block', varargin{:});
end
