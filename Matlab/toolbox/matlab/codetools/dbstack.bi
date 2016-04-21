function [varargout] = dbstack(varargin)
%DBSTACK Display function call stack.
%   The DBSTACK command displays the M-file function name and line number
%   where the breakpoint occurred, the name and line number of the M-file 
%   caller, the caller's caller, etc., until the top-most M-file function
%   is reached.
%
%   DBSTACK(N) omits from the display the first N frames.  This is useful
%   when issuing a dbstack from within, say, an error handler.
%
%   DBSTACK('-completenames') outputs the "complete name" of each
%   function in the stack, which means the absolute file name and the
%   entire sequence of functions that nest the function in the stack frame.
%
%   Either none, one, or both of the N and '-completenames' may appear.
%   If both appear, the order is irrelevant.
%
%   [ST,I] = DBSTACK returns the stack trace information in an M-by-1
%   structure ST with the fields:
%       file -- the file in which the function appears;
%               this field will be the empty string if there is no file.
%       name -- function name within the file
%       line -- function line number
%   The current workspace index is returned in I.
%
%   If you step past the end of an M-file, then DBSTACK returns a negative
%   line number value to identify that special case.  For example, if the
%   last line to be executed is line 15, then the DBSTACK line number is
%   15 before you execute that line and -15 afterwards.
%
%   See also DBSTEP, DBSTOP, DBCONT, DBCLEAR, DBTYPE, DBUP, DBDOWN,
%            DBSTATUS, DBQUIT.

%   Steve Bangert, 6-25-91.
%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.3 $  $Date: 2004/01/28 23:10:49 $
%   Built-in function.

[varargout{1:nargout}] = builtin('dbstack', varargin{:});
