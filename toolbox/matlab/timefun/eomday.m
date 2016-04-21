function d = eomday(y,m)
%EOMDAY End of month.
%   D = EOMDAY(Y,M) returns the last day of the month for the given
%   year, Y, and month, M. 
%   Algorithm:
%      "Thirty days hath September, ..."
%
%   See also WEEKDAY, DATENUM, DATEVEC.

%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.12 $  $Date: 2002/04/15 03:20:40 $

% Number of days in the month.
dpm = [31 28 31 30 31 30 31 31 30 31 30 31]';

% Make result the right size and orientation.
d = y - m;

d(:) = dpm(m);
d((m == 2) & ((rem(y,4) == 0 & rem(y,100) ~= 0) | rem(y,400) == 0)) = 29;
