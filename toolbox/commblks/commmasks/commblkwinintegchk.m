function emsg = commblkwinintegchk(bh, errmsg)
%COMMBLKWININTEGCHK Error callback function for Windowed Integrator block.
%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/06/03 15:51:19 $

% Throw error for sample based vector or matrix processing.
lerr = sllastdiagnostic;
emsg = lerr.Message;

% Capture the error and rethrow it with an appropriate error message
msg = lerr(1).Message;
if findstr(msg, 'Dimensions and frame status both match specified criteria')
    emsg = ['In sample based mode, the block accepts only 1D or 2D scalars'];
end

% [EOF]
