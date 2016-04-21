function createtdtlisteners(hThisClass)
%  Create DeviceType listeners

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/15 02:59:18 $

% NOTE: Listeners are stored in the property objects to ensure that
%       they do not get disconnected when RTWInfo object is copied

% TDTListener - updates Attributes based on DeviceType selected
hTDTProp = findprop(hThisClass, 'DeviceType');
hTDTListener = handle.listener(hThisClass, hTDTProp, ...
  'PropertyPostSet', @TDTListener);
schema.prop(hTDTProp, 'TDT_Listener', 'handle');
hTDTProp.TDT_Listener = hTDTListener;


% TargetDeviceType listener subfunction
function TDTListener(src, eventData)
TargetDeviceTypeListener(eventData.AffectedObject);

