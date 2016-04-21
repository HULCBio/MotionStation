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

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.7.2.5 $ $Date: 2004/04/08 20:45:43 $

error(nargchk(1,3,nargin));
p_errorif_ccarray(cc);
focusstate = p_getCmdWndFocus;

if ~ishandle(cc),
    error('First Parameter must be a CCSDSP Handle.');
end
if nargin == 1 | (nargin == 2 & isnumeric(optime)),  % Build
    action = 20;
    if nargin == 1,
        timeout = [];  
    else
        timeout = optime;
    end
elseif nargin == 2 | nargin == 3,  % Build all (maybe)
    if ischar(optime) & strcmpi('all',optime)
        action = 21;
        if nargin == 2,
            timeout = []; 
        end
    else
        error('The only supported build option is ''all''');
    end
end
% Parse timeout
if( nargin >= 2) & (~isempty(timeout)),
    if ~isnumeric(timeout) | length(timeout) ~= 1,
        error('TIMEOUT parameter must be a single numeric value.');
    end
    dtimeout = double(timeout);
else
    dtimeout = 1000; % Big Value for timeout
end
if( dtimeout < 0)
    error(['Negative TIMEOUT value "' num2str(dtimeout) '" not permitted.']);
end

callSwitchyard(cc.ccsversion,[action,cc.boardnum,cc.procnum,dtimeout,cc.eventwaitms]);

p_grabCmdWndFocus(focusstate);

% [EOF] build.m
