function t = now()
%NOW    Current date and time as date number.
%   T = NOW returns the current date and time as a serial date 
%   number.
%
%   FLOOR(NOW) is the current date and REM(NOW,1) is the current time.
%   DATESTR(NOW) is the current date and time as a string.
%
%   See also DATE, DATENUM, DATESTR, CLOCK.

%   Author(s): C.F. Garvin, 2-23-95
%   Copyright 1984-2002 The MathWorks, Inc. 
%   $Revision: 1.16 $  $Date: 2002/04/15 03:20:16 $

% Clock representation of current time
t = datenum(clock);
