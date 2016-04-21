function runto(cc,func,runtoopt,timeout)
% RUNTO (Private) Runs the target until the entry location of a function is
%   reached.
%   
%   RUNTO(CC,FUNC,OPT,TIMEOUT) - 
%   a. A breakpoint is placed at the entry point of the function FUNC.
%   b. If OPT='restart', the program is restarted. If OPT is empty, the
%      next step is performed.
%   c. The program is run until it the PC hits a breakpoint.
%
%   If successful, RUNTO will set the target's program counter (PC) to 
%   the beginning of FUNC. 
%   Note: RUNTO will return upon reaching the first breakpoint that
%   it encounters during program execution. Therefore, it is possible that
%   RUNTO will stop at a location other than the expected function location
%   if a breakpoint exists within its path.

% Copyright 2002-2004 The MathWorks, Inc.
% $Revision: 1.3.6.4 $  $Date: 2004/04/01 16:02:49 $

error(nargchk(4,4,nargin));
p_errorif_ccarray(cc);

if ~ishandle(cc),
    errId = generateccsmsgid('InvalidHandle');
    error(errId,'First parameter must be a valid CCSDSP handle.');
end

% Restart program first, if specified
if strcmp(runtoopt,'restart')
    restart(cc);
end

% Get address of function
funcAddress = address(cc,func);
if isempty(funcAddress)
    errId = generateccsmsgid('FunctionNotFound');
    error(errId,['Location of function ''' func ''' cannot be found. It may not be loaded on the target.']);
end
    
% Insert a breakpoint at the start of func
insert(cc,funcAddress,'break');

% Run program until a breakpoint is reached
callSwitchyard(cc.ccsversion,[14,cc.boardnum,cc.procnum,timeout,cc.eventwaitms],'runtohalt');

% Check if PC stopped at the expected location/address
if ~isequal( regread(cc,'pc','binary'),funcAddress(1))
	warning(generateccsmsgid('ExecutionDiverged'),sprintf('%s ''%s'' %s ''%s'' %s \n%s ''%s'' %s', ...
		'Function',func,'is not reached. Please make sure that a call to',func, ...
		'exists within the program','         and that all breakpoints created before the call to',func,'are removed.'));
else
	% Delete the breakpoint
	delete(cc,funcAddress,'break');
end

% [EOF] runto.m