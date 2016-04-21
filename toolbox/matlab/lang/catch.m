%CATCH  Begin CATCH block.
%   The general form of a TRY statement is:
% 
%      TRY statement, ..., statement, CATCH statement, ..., statement END
%
%   Normally, only the statements between the TRY and CATCH are executed.
%   However, if an error occurs while executing any of the statements, the
%   error is captured into LASTERR and the statements between the CATCH
%   and END are executed.  If an error occurs within the CATCH statements,
%   execution will stop unless caught by another TRY...CATCH block.  The
%   error string produced by a failed TRY block can be obtained with
%   LASTERR.
%
%   See also TRY, LASTERR, EVAL, EVALIN, END.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.6.4.1 $  $Date: 2004/01/28 23:11:07 $
%   Built-in function.
