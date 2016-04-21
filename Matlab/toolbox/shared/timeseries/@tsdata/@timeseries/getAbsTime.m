function outtimes = getAbsTime(h)
%GETABSTIME Extract an absolutly defined time vector as a string cell array
%
% GETABSTIME(TS) extracts the time vector as a cell array of datestrs if
% the time vector is defined absolutely, i.e., a valid start time is
% defined. If in addiiton the format is defined as a valid date format
% string the output datestrs will conform to the specified format.
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.1 $  $Date: 2003/12/04 02:35:50 $

% Only work if the timu vector is absolute
if isempty(h.timeInfo.Startdate)
    error('The time vector is relative')
end

% Get numeric time vector in days
t = datenum(h.timeInfo.Startdate) + h.Time * tsunitconv('days',h.timeInfo.Units);

% If a valid datestr format is specified then use it
if tsIsDateFormat(h.timeInfo.Format)
    outtimes = cellstr(datestr(t,h.timeInfo.Format));
else
    outtimes = cellstr(datestr(t));
end
