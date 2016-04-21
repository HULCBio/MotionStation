function [varargout] = save_system(varargin)
%SAVE_SYSTEM Save a Simulink system.
%   SAVE_SYSTEM saves the current top-level system to a file with its
%   current name.
%   
%   SAVE_SYSTEM('SYS') saves the specified top-level system to a file with
%   its current name.  The system must be currently open.
%   
%   SAVE_SYSTEM('SYS','NEWNAME') saves the specified top-level system to a
%   file with the specified new name.  The system must be currently open.
%
%   SAVE_SYSTEM('SYS','NEWNAME','BreakLinks') saves the specified top-level
%   system to a file with the specified new name.  Any block library links
%   are broken in the new file.  The system must be currently open.
%   
%   SAVE_SYSTEM('SYS','NEWNAME','LINKACTION', 'VERSION') saves the specified
%   top level system to a previous version with the specified NEWNAME. The
%   LINKACTION is one of '' and 'BreakLinks'. The VERSION is one of 'R13SP1',
%   'R13', 'R12P1', and 'R12'.
%
%   Examples:
%   
%       save_system
%   
%   saves the current system
%   
%       save_system('vdp')
%   
%   saves the vdp system.
%   
%       save_system('vdp','myvdp')
%   
%   saves the vdp system to file with name 'myvdp'.
%
%       save_system('vdp','myvdp','BreakLinks')
%
%   saves the vdp system to file with name 'myvdp' and breaks the links to
%   any block libraries
%   
%       save_system('vdp', 'myvdp', '', 'R13SP1')
%
%   saves the 'vdp' system to the R13 (SP1) version of Simulink with name 'myvdp'.
%   It does not break links to any block libraries.
%
%   When saving to previous versions, R14-only Simulink blocks are converted into 
%   empty masked subsystem blocks colored yellow.  The converted model may 
%   produce incorrect results.
%
%   See also OPEN_SYSTEM, CLOSE_SYSTEM, NEW_SYSTEM.

%   Copyright 1990-2004 The MathWorks, Inc.
%   $Revision: 1.11.2.5 $
%   Built-in function

if nargout == 0
  builtin('save_system', varargin{:});
else
  [varargout{1:nargout}] = builtin('save_system', varargin{:});
end
