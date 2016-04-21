function [varargout] = mislocked(varargin)
%MISLOCKED True if M-file or MEX-file cannot be cleared.
%   MISLOCKED(FUN) returns logical 1 (TRUE) if the function named FUN 
%   is locked in memory and logical 0 (FALSE) otherwise.  Locked M-files 
%   or MEX-files cannot be CLEARED.
%
%   MISLOCKED, by itself, returns logical 1 (TRUE) if the currently 
%   running M-file or MEX-file is locked and logical 0 (FALSE) otherwise.
%
%   See also MLOCK, MUNLOCK.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.7.4.2 $  $Date: 2004/04/10 23:29:51 $
%   Built-in function.

if nargout == 0
  builtin('mislocked', varargin{:});
else
  [varargout{1:nargout}] = builtin('mislocked', varargin{:});
end
