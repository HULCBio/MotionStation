function [varargout] = dbstatus(varargin)
%DBSTATUS List all breakpoints.
%   DBSTATUS, by itself, displays a list of all the breakpoints the debugger
%   knows about including ERROR, CAUGHT ERROR, WARNING, and NANINF.
%
%   DBSTATUS MFILE displays the breakpoints set for the specified M-file. MFILE
%   must be the name of an m-file function or a MATLABPATH relative partial
%   pathname (see PARTIALPATH).
%
%   S = DBSTATUS(...) returns the breakpoint information in an M-by-1
%   structure with the fields:
%       name -- function name.
%       line -- vector of breakpoint line numbers.
%       expression -- cell vector of breakpoint conditional expression strings
%                     corresponding to lines in the 'line' field.
%       cond -- condition string ('error', 'caught error', 'warning', or 
%               'naninf').
%       identifier -- when cond is one of 'error', 'caught error', or
%                     'warning', a cell vector of MATLAB Message Identifier
%                     strings for which the particular cond state is set.
%
%   See also DBSTEP, DBSTOP, DBCONT, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%            DBQUIT, ERROR, PARTIALPATH, WARNING.

%   Steve Bangert, 6-25-91.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.4 $  $Date: 2003/10/30 18:39:55 $
%   Built-in function.

if nargout == 0
  builtin('dbstatus', varargin{:});
else
  [varargout{1:nargout}] = builtin('dbstatus', varargin{:});
end
