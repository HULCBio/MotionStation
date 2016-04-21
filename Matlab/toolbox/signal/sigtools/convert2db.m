function HdB = convert2db(H)
%CONVERT2DB Convert to decibels (dB).

%   Author(s): P. Costa
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 23:52:17 $

ws = warning; % Cache warning state
warning off   % Avoid "Log of zero" warnings
HdB = db(H);  % Call the Convert to decibels engine
warning(ws);  % Reset warning state

% [EOF]
