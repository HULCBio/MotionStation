function [hThis] = datacursor

%   Copyright 1984-2004 The MathWorks, Inc. 

hThis = graphics.datacursor;
h  = handle.listener(hThis,findprop(hThis,'Target'),...
                           'PropertyPostSet',@localSetTarget);
set(hThis,'InternalListeners',h);

%-------------------------------------------------------------%
function localSetTarget(obj,evd)
% Update cache. This is a performance optmization that avoids
% excessive calls to ismethod and behavior objects.

hTarget = handle(evd.NewValue);
hDataCursorInfo = evd.AffectedObject;

if isempty(hTarget) || ~ishandle(hTarget)
   return;
end

set(hDataCursorInfo,'Target',hTarget);

if ismethod(hTarget,'getDatatipText')
   set(hDataCursorInfo,'TargetHasGetDatatipTextMethod',true);
else
   set(hDataCursorInfo,'TargetHasGetDatatipTextMethod',false);    
end

if ismethod(hTarget,'updateDataCursor')
  set(hDataCursorInfo,'TargetHasUpdateDataCursorMethod',true);
else
  set(hDataCursorInfo,'TargetHasUpdateDataCursorMethod',false);
end

hBehavior = hggetbehavior(hTarget,'DataCursor','-peek');
if ~isempty(hBehavior) 
  fcn = get(hBehavior,'UpdateFcn');
  set(hDataCursorInfo,'UpdateFcnCache',fcn);
else
    set(hDataCursorInfo,'UpdateFcnCache',[]);
end


