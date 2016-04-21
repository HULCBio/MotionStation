function pfile = reload(cc,timeout)
%RELOAD Load the most recently used program file into the target.  
%   PFILE = RELOAD(CC,TIMEOUT) - The mostly recently loaded program file
%   is reloaded into the target DSP.  If CC has more than one processor,
%   then each processor is loaded with the most recent program file.
%   RELOAD is useful after a reset or any event that changes the DSP
%   program memory to reinitialize the program for execution.
%   The name of the program file that was loaded is returned in PFILE.  
%   Note: If CC contains more than one processor, each of these 
%   processors will call 'reload' in a sequential order.
%   
%   PFILE = RELOAD(CC) same as above, except the timeout is
%   replaced by the default timeout parameter from the CC object.
%
%   See also LOAD, CD.

% Copyright 2001-2004 The MathWorks, Inc.
% $Revision: 1.8.4.2 $ $Date: 2004/04/01 16:02:44 $

error(nargchk(1,2,nargin));

mcc = cc;
% just a wrapper for multi-proc boards
for k = 1:length(mcc)
    cc = mcc(k);
    pfile{k} = callSwitchyard(cc.ccsversion,[29,cc.boardnum,cc.procnum,0,0]);
    
    if isempty(pfile{k}),
        warning('No action taken - First load a valid Program file before you reload');
    else
        % Parse timeout
        if( nargin >= 2)&(~isempty(timeout)),
            if ~isnumeric(timeout) | length(timeout) ~= 1,
                error('TIMEOUT parameter must be a single numeric value.');
            end
            dtimeout = double(timeout);
        else
            dtimeout = double(get(cc,'timeout'));
        end
        if( dtimeout < 0)
            error(['Negative TIMEOUT value "' num2str(dtimeout) '" not permitted.']);
        end    
        cc.load(pfile{k},dtimeout);
    end
end

% expand output if not a vector
if length(pfile) == 1
    pfile = pfile{1};
end

% [EOF] reload.m
