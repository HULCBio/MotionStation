function javasend(h,eventname,eventData)

% Author(s): 
% Revised:
% Copyright 1986-2003 The MathWorks, Inc.
% $Revision: 1.1.8.2 $ $Date: 2004/04/10 23:37:45 $

% (hack) fire event with an eventData object set to the java String eventData

eventDatain = ctrluis.dataevent(h,eventname,eventData);
h.send(eventname,eventDatain);
