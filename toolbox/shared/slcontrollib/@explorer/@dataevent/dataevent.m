function this = dataevent(eventSrc, propertyName, oldValue, newValue)
% DATAEVENT  Subclass of EVENTDATA to handle string-valued event data.

% Author(s): Bora Eryilmaz
% Revised:
% Copyright 1986-2004 The MathWorks, Inc.
% $Revision: 1.1.6.2 $ $Date: 2004/04/11 00:30:32 $

% Create class instance
if isa(eventSrc, 'explorer.node')
  this = explorer.dataevent(eventSrc, 'PropertyChange');
else
  error('Event source must be an explorer.node object or a subclass of it.')
end

% Assign data
this.propertyName = propertyName;
this.oldValue     = oldValue;
this.newValue     = newValue;
