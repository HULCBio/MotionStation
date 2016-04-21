function [varargout] = dos(varargin)
%DOS Execute DOS command and return result.
%   [status, result] = DOS('command', '-echo'), for Windows systems, calls upon
%   the shell to execute the given command.  Both console (DOS) programs and
%   Windows programs may be executed, but the syntax causes different results
%   based on the type of programs.  Console programs have stdout and their
%   output is returned to the result variable.  They are always run in an
%   iconified DOS or Command Prompt Window except as noted below.  Console
%   programs never execute in the background.  Also, MATLAB will always wait for
%   the stdout pipe to close before continuing execution.  Windows programs may
%   be executed in the background as they have no stdout.
%   
%   The DOS command takes an optional second argument, '-echo'.  This
%   forces the output to the Command Window, even if it is also being
%   assigned into a variable.
%
%   The following trailing character has special meaning:
%           '&' - For console programs this causes the console to
%                 open.  Omitting this character will cause console
%                 programs to run iconically.
%                 For Windows programs, appending this character will
%                 cause the application to run in the background.
%                 MATLAB will continue processing.
%
%   Note: On Windows 95, Windows 98, and Windows ME, built-in DOS
%   commands (such as "dir" and "echo") and DOS batch scripts
%   (scripts whose filenames end with ".bat") always return a
%   status of 0. Only Windows applications and DOS console
%   applications can return nonzero status codes on these operating
%   systems.
%
%   Examples:
%
%       [s, w] = dos('dir')
%
%   does a directory listing and returns s = 0, and the string
%   containing the listing in w.
%
%       dos('edit &')
%
%   opens the DOS 5.0 editor in a DOS Window.
%
%       dos('notepad file.m &')
%
%   opens the notepad editor and returns control immediately to MATLAB.
%
%       [s, w] = dos('net xxx')
%
%   returns a nonzero value for s and an error message in w because
%   "xxx" is not a valid option to net.exe.
%
%       [s, w] = dos('dir', '-echo');
%   
%   will echo the results of the 'dir' command to the Command Window as
%   it executes as well as assigning the results to w.
%   
%
%   See also SYSTEM and ! (exclamation point) under PUNCT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.15.4.1 $  $Date: 2003/06/09 05:57:57 $
%   Built-in function.

if nargout == 0
  builtin('dos', varargin{:});
else
  [varargout{1:nargout}] = builtin('dos', varargin{:});
end
