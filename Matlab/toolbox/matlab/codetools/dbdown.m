function [varargout] = dbdown(varargin)
%DBDOWN Change local workspace context.
%   The DBDOWN command is used in conjunction with the DBUP command to
%   change the workspace context when in the debug mode.  The DBDOWN
%   command reverses the context shift done by DBUP. 
%
%   See also DBSTEP, DBSTOP, DBCONT, DBCLEAR, DBTYPE, DBSTACK, DBUP,
%            DBSTATUS, DBQUIT.

%   Steve Bangert, 6-25-91.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/10 23:23:57 $
%   Built-in function.

if nargout == 0
  builtin('dbdown', varargin{:});
else
  [varargout{1:nargout}] = builtin('dbdown', varargin{:});
end
