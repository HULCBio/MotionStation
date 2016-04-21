function str = logical2string(log)
%LOGICAL2STRING   Convert the logical to a string.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/01/25 23:11:54 $

if log
    str = 'true';
else
    str = 'false';
end

% [EOF]
