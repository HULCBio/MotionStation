function A = getData(h, data)
%GETDATA Extracts data from the time ValueArray storage object
%
%   Author(s): James G. Owen
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $ $Date: 2004/04/11 00:33:38 $

% Gets data from the ValueArray data property 
if ~isempty(h.Start) && ~isempty(h.End)
	if isfinite(h.Increment)
       A = (h.Start:h.Increment:h.End)';
       % Add one more increment if doing so would get closer to the end
       % time. This is needed to prevent small round off errors in the
       % increment causing the last time instant to 'vanish'
       if (h.End-A(end))>(A(end)+h.Increment-h.End)
           A = [A; A(end)+h.Increment];
       end
	else
       A = data;  
       % If data is suplied sync the start and end times
       % This is useful when time data sources may have changed
       if length(data)>=2
            h.Start = data(1);
            h.End = data(end);
       end
	end    
else
    A = [];
end
