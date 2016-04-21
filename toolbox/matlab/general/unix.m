function [varargout] = unix(varargin)
%UNIX   Execute UNIX command and return result.
%   [status,result] = UNIX('command'), for UNIX systems, calls upon
%   the operating system to execute the given command.  The resulting
%   status and standard output are returned.
%
%   Examples:
%
%       [s,w] = unix('who')
%
%   returns s = 0 and, in w, a MATLAB string containing a list of
%   the users currently logged in.
%
%       [s,w] = unix('why')
%
%   returns a nonzero value in s to indicate failure and sets w to
%   the null matrix because "why" is not a UNIX command.
%
%       [s,m] = unix('matlab')
%
%   never returns because running the second copy of MATLAB requires
%   interactive user input which cannot be provided.
%
%   See also SYSTEM and ! (exclamation point) under PUNCT.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 5.10.4.1 $  $Date: 2003/06/09 05:58:37 $
%   Built-in function.

if nargout == 0
  builtin('unix', varargin{:});
else
  [varargout{1:nargout}] = builtin('unix', varargin{:});
end
