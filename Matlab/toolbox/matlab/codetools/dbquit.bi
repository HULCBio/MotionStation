function [varargout] = dbquit(varargin)
%DBQUIT Quit debug mode.
%   The DBQUIT command immediately terminates debug mode and returns
%   control to the base workspace prompt.  The M-file being processed
%   is NOT completed and no results are returned.
%   
%   See also DBSTOP, DBCONT, DBSTEP, DBCLEAR, DBTYPE, DBSTACK, DBUP,
%   DBDOWN, and DBSTATUS.

%   Steve Bangert, 1-3-92.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/10 23:23:58 $
%   Built-in function.

if nargout == 0
  builtin('dbquit', varargin{:});
else
  [varargout{1:nargout}] = builtin('dbquit', varargin{:});
end
