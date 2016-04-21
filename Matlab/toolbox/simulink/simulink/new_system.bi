function [varargout] = new_system(varargin)
%NEW_SYSTEM Create a new empty Simulink system.
%   NEW_SYSTEM('SYS') creates a new empty system with the specified name.
%
%   An optional second argument can be used to specify the system type.
%   NEW_SYSTEM('SYS','Library') creates a new empty library,
%   and NEW_SYSTEM('SYS','Model') creates a new empty system.
%
%   An optional third argument can be used to specify a subsystem
%   whose contents should be copied into the new model. This third
%   argument can only be used when the second argument is 'Model'.
%   NEW_SYSTEM('SYS','MODEL','FULL_PATH_TO_SUBSYSTEM') creates a new
%   model populated with the blocks in the subsytem.
%
%   Note that NEW_SYSTEM does not open the system or library window.
%
%   Examples:
%   
%       new_system('mysys')
%   
%   creates, but does not open, a new system named 'mysys'.
%   
%       new_system('mysys','Library')
%
%   creates, but does not open, a new library named 'mysys'.
%  
%       load_system('f14')
%       new_system('mysys','Model','f14/Controller')
%
%   creates, but does not open, a new model named 'mysys' that is
%   populated with the same blocks in the subsystem named 'Controller'
%   in the 'f14' demo model.
%   
%   See also OPEN_SYSTEM, CLOSE_SYSTEM, SAVE_SYSTEM.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.17.2.3 $
%   Built-in function


if nargout == 0
  builtin('new_system', varargin{:});
else
  [varargout{1:nargout}] = builtin('new_system', varargin{:});
end
