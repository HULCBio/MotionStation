function propout = PrivateSetIncrement(eventSrc, eventData)
%Resets the End property when changing the increment

% Copyright 2003-2004 The MathWorks, Inc.

% If a positive length is defined and the increment is non trivial update the end 
% time to keep the length constant
propout = eventData;
if isfinite(propout) && ~isempty(eventSrc.getlength) && isfinite(eventSrc.getlength) && eventSrc.getlength>0 
   set(eventSrc,'End',eventSrc.start+propout*(eventSrc.getlength-1));
end