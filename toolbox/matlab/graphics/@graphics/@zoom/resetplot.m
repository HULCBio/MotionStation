function resetplot(hZoom,hAxes)

% Copyright 2002-2004 The MathWorks, Inc.

% For now, only consider one axes 
hAxes = hAxes(1);

if ~all(ishandle(hAxes))
   return;
end

% reset 2-D axes
if is2D(hAxes)
   origLim = axis(hAxes);
   resetplotview(hAxes,'ApplyStoredView');
   newLim = axis(hAxes);
   create2Dundo(hZoom,hAxes,origLim(1:4),newLim(1:4));
   
% reset 3-D axes  
else
   origVa = camva(hAxes);
   origTarget = camtarget(hAxes);
   resetplotview(hAxes,'ApplyStoredView');
   newVa = camva(hAxes);
   newTarget = camtarget(hAxes);
   create3Dundo(hZoom,hAxes,origVa,newVa,origTarget,newTarget);
end


