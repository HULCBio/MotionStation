function str = sf_date_str(dateNum)
%%% STR = SF_DATE_STR(DATENUM)
%%% A safe wrapper around datestr which is known to be
%%% brittle. All calls to datestr(now) in our code
%%% will now use sf_date_str without any arguments.
%%% All calls to datestr(dateNum) will now use
%%% sf_date_str(dateNum)

%   Copyright 1995-2002 The MathWorks, Inc.
%   $Revision: 1.3.2.1 $  $Date: 2004/04/15 00:59:22 $

if(nargin<1)
    try,
        dateNum = now;
    catch,
        str = 'Unknown';
        return;
    end
end

try,
    str = datestr(dateNum);
catch,
    str = 'Unknown';
    return;
end
