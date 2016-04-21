function emsg = commblktimrecechk(bh, errmsg)
%COMMBLKTIMRECECHK Error callback function for Squaring Timing 
% Recovery block.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/10 05:15:32 $

% Throw the error if not changing it.
lerr = sllastdiagnostic;
emsg = lerr.Message;

% Capture the error and rethrow it with an appropriate error message
msg = lerr(1).Message;
if findstr(msg, 'Error in port widths or dimensions.')
    emsg = ['The input frame length must be equal to the product of the ',...
            'samples per symbol and the symbols per frame parameters.'];
end

% [EOF]
