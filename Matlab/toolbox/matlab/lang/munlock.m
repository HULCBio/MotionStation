function [varargout] = munlock(varargin)
%MUNLOCK Allow M-file or MEX-file to be cleared.
%   MUNLOCK(FUN) unlocks the M-file or MEX-file named FUN from memory.
%   so that subsequent CLEAR commands can remove it.  These files are, 
%   unlocked by default so that changes to the file are picked up.  
%   Calls to MUNLOCK are only needed to unlock M-files or MEX-files 
%   that have been locked with the MLOCK function.
%
%   MUNLOCK, by itself, unlocks the currently running M-file or MEX-file.
%
%   See also MLOCK, MISLOCKED.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.2 $  $Date: 2004/04/10 23:29:53 $
%   Built-in function.

if nargout == 0
  builtin('munlock', varargin{:});
else
  [varargout{1:nargout}] = builtin('munlock', varargin{:});
end
