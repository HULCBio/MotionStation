function [varargout] = dbstop(varargin)
%DBSTOP Set breakpoint.
%   The DBSTOP command is used to temporarily stop the execution of an M-file
%   and give the user an opportunity to examine the local workspace. There are
%   several forms to this command. They are:
%
%   (1)  DBSTOP IN MFILE AT LINENO
%   (2)  DBSTOP IN MFILE AT LINENO@
%   (3)  DBSTOP IN MFILE AT LINENO@N
%   (4)  DBSTOP IN MFILE AT SUBFUN
%   (5)  DBSTOP IN MFILE
%   (6)  DBSTOP IN MFILE AT LINENO IF EXPRESSION
%   (7)  DBSTOP IN MFILE AT LINENO@ IF EXPRESSION
%   (8)  DBSTOP IN MFILE AT LINENO@N IF EXPRESSION
%   (9)  DBSTOP IN MFILE AT SUBFUN IF EXPRESSION
%   (10) DBSTOP IN MFILE IF EXPRESSION
%   (11) DBSTOP IF ERROR 
%   (12) DBSTOP IF CAUGHT ERROR 
%   (13) DBSTOP IF WARNING 
%   (14) DBSTOP IF NANINF  or  DBSTOP IF INFNAN
%   (15) DBSTOP IF ERROR IDENTIFIER
%   (16) DBSTOP IF CAUGHT ERROR IDENTIFIER
%   (17) DBSTOP IF WARNING IDENTIFIER
%
%   MFILE must be the name of an M-file or a MATLABPATH-relative partial
%   pathname (see PARTIALPATH). LINENO is a line number within MFILE, N is an
%   integer specifying the Nth anonymous function on the line, and SUBFUN
%   is the name of a subfunction within MFILE. EXPRESSION is a string containing
%   a evaluatable conditional expression. IDENTIFIER is a MATLAB Message
%   Identifier (see help for ERROR for a description of message
%   identifiers). The AT and IN keywords are optional.
% 
%   The forms behave as follows:
%
%   (1)  Stops at the specified line number in MFILE.
%   (2)  Stops just after any call to the first anonymous function
%        in the specified line number in MFILE.
%   (3)  As (2), but just after any call to the Nth anonymous function.
%   (4)  Stops at the specified subfunction of MFILE.
%   (5)  Stops at the first executable line in MFILE.
%   (6-10) As (1)-(5), except only stops if EXPRESSION evaluates to
%        true. EXPRESSION is evaluated (as if by EVAL) in MFILE's workspace
%        when the breakpoint is encountered, and must evaluate to a scalar
%        logical value (true or false).
%   (11) Causes a stop in any M-file function causing a run-time error that
%        would not be detected within a TRY...CATCH block.
%        You cannot resume M-file execution after an uncaught run-time error.
%   (12) Causes a stop in any M-file function causing a run-time error that
%        would be detected within a TRY...CATCH block. You can resume M-file
%        execution after a caught run-time error.
%   (13) Causes a stop in any M-file function causing a run-time warning. 
%   (14) Causes a stop in any M-file function where an infinite value (Inf)
%        or Not-a-Number (NaN) is detected.
%   (15-17) As (11)-(13), except that MATLAB only stops on an error or warning
%        whose message identifier is IDENTIFIER. (If IDENTIFIER is the special
%        string 'all', then these uses behave exactly like (11)-(13).)
%
%   When MATLAB reaches a breakpoint, it enters debug mode. The prompt changes
%   to a K>> and, depending on the "Open M-Files when Debugging" setting in the
%   Debug menu, the debugger window may become active. Any MATLAB command is
%   allowed at the prompt. To resume M-file execution, use DBCONT or DBSTEP. To
%   exit from the debugger, use DBQUIT.
%
%   See also DBCONT, DBSTEP, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN,
%            DBSTATUS, DBQUIT, ERROR, EVAL, LOGICAL, PARTIALPATH, TRY, WARNING.

%   Steve Bangert, 6-25-91. Revised, 1-3-92.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.6 $  $Date: 2004/04/23 19:09:43 $
%   Built-in function.

[varargout{1:nargout}] = builtin('dbstop', varargin{:});
