function [varargout] = dbcont(varargin)
%DBCONT Continue execution.
%   The DBCONT command resumes execution of an M-file following a stop in
%   execution caused by either a DBSTOP or DBSTEP command.  Execution will
%   continue until either another breakpoint is encountered, an error
%   occurs, or MATLAB returns to the base workspace prompt.
%
%   See also DBQUIT, DBSTEP, DBSTOP, DBCLEAR, DBTYPE, DBSTACK, DBUP,
%            DBDOWN, DBSTATUS.

%   Steve Bangert, 6-25-91.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/10 23:23:56 $
%   Built-in function.

if nargout == 0
  builtin('dbcont', varargin{:});
else
  [varargout{1:nargout}] = builtin('dbcont', varargin{:});
end
