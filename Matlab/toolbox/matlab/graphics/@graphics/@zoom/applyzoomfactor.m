function applyzoomfactor(hZoom,hAxes,zoom_factor)
% hAxes is a scalar axes handle
% zoom_factor is a scalar double

% Copyright 2002-2003 The MathWorks, Inc.

if is2D(hAxes)
   localZoomFactor2D(hZoom,hAxes,zoom_factor)
else
  if zoom_factor <= 0
    return;
  end
  localZoomFactor3D(hZoom,hAxes,zoom_factor)
end

%-------------------------------------------%
function localZoomFactor2D(hZoom,hAxes,zoom_factor)
% Most of the code here is from the original zoom function

if zoom_factor >= 1
   m = 1;
else
   m = -1;
end

% Get bounding limits for zooming out.
viewinfo = resetplotview(hAxes,'GetStoredViewStruct');
if ~isempty(viewinfo) 
  maxbounds = [viewinfo.XLim, viewinfo.YLim];
else % Use axes data bounds
  maxbounds = objbounds(hAxes);
  % Use current bounds, g161225, 163055
  if isempty(maxbounds)
     maxbounds = axis(hAxes);
  end
end
boundXLim = maxbounds(1:2);
boundYLim = maxbounds(3:4);

% Current axis limits
currLim = axis(hAxes); currLim = currLim(1:4);
currXLim = currLim(1:2);
currYLim = currLim(3:4);
newXLim = currXLim;
newYLim = currYLim;
   
zoomConstraint = get(hZoom,'Constraint');
   
% Calculate new x-limits
if ~any(isinf(currXLim)) & (strcmpi(zoomConstraint,'horizontal') | strcmp(zoomConstraint,'none'))
   dx = diff(currXLim);
   center_x = currXLim(1) + dx/2;
   newdx = dx * zoom_factor.^(-m-1);
   newXLim(1) = center_x - newdx;   
   newXLim(2) = center_x + newdx;   


   ind_min = 1;
   ind_max = 2;     
   % If candidate limits exceed bounds and current limits
   if newXLim(ind_min) < boundXLim(ind_min) & ...
         newXLim(ind_min) < currXLim(ind_min)
      % Clamp to bounds or current limits
      if currXLim(ind_min) < boundXLim(ind_min) 
         newXLim(ind_min) = currXLim(ind_min);
      else 
         newXLim(ind_min) = boundXLim(ind_min);
      end
   end   
   % If candidate limits exceed bounds
   if newXLim(ind_max) > boundXLim(ind_max) & ...
         newXLim(ind_max) > currXLim(ind_max)
      % Clamp to best bounds
      if currXLim(ind_max) > boundXLim(ind_max) 
         newXLim(ind_max) = currXLim(ind_max);
      else 
         newXLim(ind_max) = boundXLim(ind_max);
      end
   end   
end
   
% Calculate new y-limits
if ~any(isinf(currYLim)) && (strcmpi(zoomConstraint,'vertical') || strcmp(zoomConstraint,'none'))
   dy = diff(currYLim);
   center_y = currYLim(1) + dy/2;
   newdy = dy * zoom_factor.^(-m-1);
   newYLim(1) = center_y - newdy;   
   newYLim(2) = center_y + newdy;   

   ind_min = 1;
   ind_max = 2;
   % If candidate limits exceed bounds and current limits
   if newYLim(ind_min) < boundYLim(ind_min) & ...
         newYLim(ind_min) < currYLim(ind_min)
      % Clamp to bounds or current limits
      if currYLim(ind_min) < boundYLim(ind_min) 
         newYLim(ind_min) = currYLim(ind_min);
      else 
         newYLim(ind_min) = boundYLim(ind_min);
      end
   end   
   
   % If candidate limits exceed bounds
   if newYLim(ind_max) > boundYLim(ind_max) & ...
         newYLim(ind_max) > currYLim(ind_max)
      % Clamp to best bounds
      if currYLim(ind_max) > boundYLim(ind_max) 
         newYLim(ind_max) = currYLim(ind_max);
      else 
         newYLim(ind_max) = boundYLim(ind_max);
      end
   end   
end

% Actual zoom operation
newLim = [newXLim,newYLim];
axis(hAxes,newLim);
   
% Register with undo/redo
create2Dundo(hZoom,hAxes,currLim,newLim);

%-------------------------------------------%
function localZoomFactor3D(hZoom,hAxes,zoom_factor)


% Actual zoom operation
va_deg = camva(hAxes);
origVa = va_deg*pi/360;
%newVa = camva(hAxes)/zoom_factor;
newVa = atan(tan(origVa)*(1/zoom_factor))*360/pi;

% Limit view angle
if newVa<get(hZoom,'MaxViewAngle') 
   camva(hAxes,newVa);
end

% Can't use camzoom since that breaks reverse compatibility
%camzoom(hAxes,zoom_factor); % sets view angle
%newVa = camva(hAxes);

% Register with undo/redo 
%create3Dundo(hAxes,origVa,newVa);







