function setAbsTime(h, timeCells)
%SETABSTIME Assign time an absolutly defined time vector as a string cell array
%
% SETABSTIME(TS) assignes the time vector and time metedata to represent a
% cell array of date strings. 
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/11 00:33:54 $

if (iscell(timeCells) || ischar(timeCells) )&& length(timeCells)>0
    dateVec = sort(datenum(timeCells));
    % Check for duplicate times
    if min(diff(dateVec))<eps
        error('timeseries:setAbsTime:duptimes',...
            'Duplicate times are invalid')
    end
    h.timeInfo.Startdate = datestr(dateVec(1));
    h.Time = tsunitconv(h.timeInfo.Units,'days')*(dateVec-dateVec(1));
    % TO DO: Need to identify the dataform string/number used in timeCells
    % and assign it to h.timeInfo.Format 
    h.timeInfo.Format = 'yyyy-mm-dd HH:MM:SS';
end

