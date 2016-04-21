function [varargout] = dbtype(varargin)
%DBTYPE List M-file with line numbers.
%   The DBTYPE command is used to list an M-file function with 
%   line numbers to aid the user in setting breakpoints.  There are
%   two forms to this command.  They are:
%
%   DBTYPE MFILE
%   DBTYPE MFILE start:end
%
%   where MFILE is the name of the M-file function in question and 
%   start and end are line numbers.
%
%   DBTYPE FILENAME lists the contents of the file given a fullpath name
%   or a MATLABPATH relative partial pathname (see PARTIALPATH).
%
%   See also DBSTEP, DBSTOP, DBCONT, DBCLEAR, DBSTACK, DBUP, DBDOWN,
%            DBSTATUS, DBQUIT, PARTIALPATH.

%   Steve Bangert, 6-25-91.
%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/10 23:24:01 $
%   Built-in function.

if nargout == 0
  builtin('dbtype', varargin{:});
else
  [varargout{1:nargout}] = builtin('dbtype', varargin{:});
end
