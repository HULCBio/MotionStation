function  build(cc,optime,timeout)
%BUILD Build a Code Composer Studio(R) project
%   BUILD(CC,TIMEOUT) does an incremental build of the target code. 
%   This will recompile any source files that have been modified, but
%   if the source file has not changed (as indicated by the date), the
%   compilation step will be skipped.  Next, the object files are linked 
%   to create a program file. 
%
%   BUILD(CC,'all',TIMEOUT) does a complete rebuild of the target code. 
%   This option forces a re-compilation of all source files.  Then
%   a link is performed to create a program file. 
%
%   TIMEOUT defines an upper limit (in seconds) on the period this 
%   routine will wait for completion of the specified action.  
%   If this period is exceeded, the routine will immediately return
%   with a timeout error. In general, this method will cause the
%   processor to initiate a restart, even when a timeout is reached
%   The timeout simply indicates the confirmation was not received 
%   before the timeout period expired.
%
%   BUILD(CC,'all') and BUILD(CC) - Same as above, except the default 
%   timeout from the CC object is applied.
%
%   See also ISRUNNING, OPEN.

% Copyright 2004 The MathWorks, Inc.
