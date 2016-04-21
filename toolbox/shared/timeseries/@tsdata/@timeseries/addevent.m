function addevent(ts,e)
%ADDEVENT Adds events to a time series object
%   ADDEVENT(TS,EVENT) adds event objects EVENT to the time series
%   object. If no event with the same name and time is attached to the time
%   series object a reference to the event object is added to the time series.
%   Otherwise the EVENTDATA property of the existing duplicate event is modified to
%   refelect that of the new event object.
%
%   Author(s): James G. Owen
%   Copyright 1986-2003 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2003/12/22 00:55:06 $

% Check that the event is a valid singleton
if isempty(e) % Ignore empty events
    return
end
if ~isa(e,'tsdata.event')
    error('timeseries:addevent:badtype',...
        'Only event objects can be added')
end
   
% Add events one at a time
for k=1:length(e)
    localAddEvent(ts,e(k))
end

function localAddEvent(ts,e)
% Adds events one at a time
% Check for duplication
if length(ts.Events)>0
    I = find(strcmp(e.Name,get(ts.Events,{'Name'})) & ...
        abs(e.Time-cell2mat(get(ts.Events,{'time'})))<eps);
    if isempty(I)
        set(e,'Parent',ts);
        ts.events = [ts.events, e];
    else
        ts.Events(I(1)).EventData = e.EventData;
    end
else
    set(e,'Parent',ts);
    ts.Events = e;
end
