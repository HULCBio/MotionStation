function addDataCursor(hThis,hDataCursor)

% Copyright 2003 The MathWorks, Inc.

if(hThis.Debug)
  disp('addDataCursor')
end

% Update Z-stacking if necessary since the application
% might have created the datatip manually (i.e. calling
% constructor) and not through this object's createdatatip
% method.That means we need to update its state and call 
% movetofront to refresh the z-position.
if get(hThis,'EnableZStacking') 
  set(hDataCursor,'EnableZStacking',true);
  zstackmin = get(hThis,'ZStackMinimum');
  if ~isequal(get(hDataCursor,'ZStackMinimum'),zstackmin)
     set(hDataCursor,'ZStackMinimum',zstackmin);   
     %movetofront(hDataCursor);
  end
end

set(hDataCursor,'EnableAxesStacking',get(hThis,'EnableAxesStacking'));

% Set current data cursor to be last added
set(hThis,'CurrentDataCursor',hDataCursor);

% Add to list
hList = get(hThis,'DataCursors');
set(hThis,'DataCursors',[hList; hDataCursor]);

% Add deletion listener
hListener = handle.listener(hDataCursor,...
                    'ObjectBeingDestroyed', ...
                    {@localDeleteDataCursor,hDataCursor,hThis});
addlistener(hDataCursor,hListener);

%---------------------------------------------%
function localDeleteDataCursor(obj,evd,hDataCursor,hTool)

% Delete datatip
removeDataCursor(hTool,hDataCursor);





