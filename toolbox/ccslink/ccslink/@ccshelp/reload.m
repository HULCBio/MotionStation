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

% Copyright 2004 The MathWorks, Inc.
