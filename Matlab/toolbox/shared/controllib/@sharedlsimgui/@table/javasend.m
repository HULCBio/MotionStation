function javasend(h,eventname,eventData)

% Author(s): James G. Owen
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:25:00 $

% (workaround) fire event with an eventData object set to the java String eventData

eventDatain = ctrluis.dataevent(h,eventname,eventData);
h.send(eventname,eventDatain);
