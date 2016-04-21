function [varargout] = dbstep(varargin)
%DBSTEP Execute one or more lines.
%   The DBSTEP command allows the user to execute one or more lines of
%   executable MATLAB code and upon their completion revert back to the
%   debug mode.  There are four forms to this command.  They are:
%
%   DBSTEP
%   DBSTEP nlines
%   DBSTEP IN
%   DBSTEP OUT
%
%   where nlines is the number of executable lines to step.
%   The first form causes the execution of the next executable line.
%   The second form causes the execution of the next nlines executable
%   lines.  When the next executable line is a call to another M-file
%   function, the third form allows the user to step to the first 
%   executable line in the called M-file function.  The fourth form
%   runs the rest of the function and stops just after leaving the
%   function. For all forms, MATLAB also stops execution at any 
%   breakpoint it encounters.
%
%   See also DBCONT, DBSTOP, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%            DBSTATUS, DBQUIT.

%   Steve Bangert, 6-25-91.
%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2004/04/10 23:23:59 $
%   Built-in function.

if nargout == 0
  builtin('dbstep', varargin{:});
else
  [varargout{1:nargout}] = builtin('dbstep', varargin{:});
end
