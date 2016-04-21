function goto(cc,func,timeout)
% GOTO Places the CCS cursor at the start of the function body.
%   GOTO(CC,FUNC) Locates the file where FUNC is found, opens the file in 
%   Code Composer Studio(R) and places the CCS cursor at the start of the 
%   function body. If the file is not found, it returns a warning.
%
%   GOTO(CC,FUNC,TIMEOUT) Same as above, except it accepts a time out
%   value.

% Copyright 2004 The MathWorks, Inc.
