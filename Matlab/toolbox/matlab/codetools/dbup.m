function [varargout] = dbup(varargin)
%DBUP Change local workspace context.
%   The DBUP command allows the user to change the workspace context, 
%   while the user is in the debug mode, to that of the calling M-file 
%   or the base workspace.
%
%   See also DBDOWN, DBSTACK, DBSTEP, DBSTOP, DBCONT, DBCLEAR, 
%            DBTYPE, DBQUIT, DBSTATUS.

%   Steve Bangert, 6-25-91.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/10 23:24:02 $
%   Built-in function.

if nargout == 0
  builtin('dbup', varargin{:});
else
  [varargout{1:nargout}] = builtin('dbup', varargin{:});
end
