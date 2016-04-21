function [varargout] = system(varargin)
%SYSTEM   Execute system command and return result.
%   [status,result] = SYSTEM('command') calls upon the operating system
%   to execute the given command.  The resulting status and standard
%   output are returned.
%
%   Examples:
%
%       [s,w] = system('dir')
%
%   returns s = 0 and, in w, a MATLAB string containing a list of
%   files in the current directory (assuming your operating system
%   knows about the "dir" command).  If the "dir" command fails or
%   does not exist on your system, a nonzero value is returned in s,
%   and an empty matrix is returned in w. 
%
%       [s,w] = system('ls')
%
%   returns s = 0 and, in w, a MATLAB string containing a list of
%   files in the current directory (assuming your operating system
%   knows about the "ls" command).  If the "ls" command fails or
%   does not exist on your system, a nonzero value is returned in s,
%   and an empty matrix is returned in w. 
%
%   See also DOS, UNIX, and ! (exclamation point) under PUNCT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.3.4.1 $  $Date: 2003/06/09 05:58:35 $
%   Built-in function.



if nargout == 0
  builtin('system', varargin{:});
else
  [varargout{1:nargout}] = builtin('system', varargin{:});
end
