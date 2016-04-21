function [varargout] = mlock(varargin)
%MLOCK Prevent M-file or MEX-file from being cleared.
%   MLOCK locks the currently running M-file or MEX-file in memory so 
%   that subsequent CLEAR commands do not remove it.
%
%   Use the command MUNLOCK or MUNLOCK(FUN) to return the M-file or 
%   MEX-file to its normal CLEAR-able state.
%
%   Locking an M-file or MEX-file in memory also prevents any PERSISTENT 
%   variables defined in the file from getting reinitialized.
%
%   See also MUNLOCK, MISLOCKED, PERSISTENT.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.8.4.2 $  $Date: 2004/04/10 23:29:52 $
%   Built-in function.

if nargout == 0
  builtin('mlock', varargin{:});
else
  [varargout{1:nargout}] = builtin('mlock', varargin{:});
end
