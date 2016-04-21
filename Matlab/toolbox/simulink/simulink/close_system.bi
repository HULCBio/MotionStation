function [varargout] = close_system(varargin)
%CLOSE_SYSTEM Close a Simulink system window or a block dialog box.
%   CLOSE_SYSTEM closes the current system or subsystem window.  If the
%   system being closed has been modified, CLOSE_SYSTEM will issue an error.
%
%   CLOSE_SYSTEM('SYS') closes the specified system or subsystem window.
%
%   CLOSE_SYSTEM('SYS',SAVEFLAG), if SAVEFLAG is 1, saves the specified
%   top-level system to a file with its current name, then closes the system
%   and removes it from memory.  If SAVEFLAG is 0, this command closes the
%   system without saving it.
%
%   CLOSE_SYSTEM('SYS','NEWNAME') saves the specified top-level system to a
%   file with the specified new name, then closes the system.
%
%   CLOSE_SYSTEM('BLK'), where 'BLK' is a full block path name, closes the
%   dialog box associated with the specified block.
%
%   Examples:
%
%       close_system
%
%   closes the current system
%
%       close_system('vdp')
%
%   closes the vdp system.
%
%       close_system('engine',1)
%
%   saves the engine system to file with its current name, then closes it.
%
%       close_system('vdp','myvdp')
%
%   saves the vdp system to file with name 'myvdp', then closes it.
%
%       close_system('engine/Combustion/Unit Delay')
%
%   closes the dialog box of the Unit Delay block in the Combustion
%   subsystem of the engine system.
%
%   See also OPEN_SYSTEM, SAVE_SYSTEM, NEW_SYSTEM, BDCLOSE.

%   Copyright 1990-2003 The MathWorks, Inc.
%   $Revision: 1.15.2.2 $
%   Built-in function.

if nargout == 0
  builtin('close_system', varargin{:});
else
  [varargout{1:nargout}] = builtin('close_system', varargin{:});
end
