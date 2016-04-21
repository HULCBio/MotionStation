function propout = PrivateSetStart(eventSrc, eventData)
%Resets the End property when changing the start

% Copyright 2003-2004 The MathWorks, Inc.

% Vector valued start values are not allowed. See the comment on derived
% class requirements in the schema
if length(eventData)>1
    error('timemetadata:PrivateSetStart:novecstart',...
        'Vector valued start times are no allowed')
end
% If the length is undefined allow independent setting of the start time so
% that timemetadata can be initialized
if isempty(eventSrc.getlength) || isnan(eventSrc.getlength) || eventSrc.getlength==0 
    propout = eventData;
    return
% If the incrment is not NaN this is a uniform time series and the end time
% should be adjusted to keep the length constant
elseif isfinite(eventSrc.Increment)
    propout = eventData;
    eventSrc.End = propout+eventSrc.Increment*(eventSrc.getlength-1);
    return
else
    error('timemetadata:PrivateSetStart:readonlystart', ...
        'Start is read-only for non-uniformly sampled time series')
end
