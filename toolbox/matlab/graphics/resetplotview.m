function [retval] = resetplotview(hAxes,varargin)
% Internal use only. This function may be removed in a future release.

% Copyright 2003-2004 The MathWorks, Inc.

% This helper is used by zoom, pan, and tools menu
%
% RESETPLOTVIEW(AX,'InitializeCurrentView') 
%     Saves current view only if no view information already exists. 
% RESETPLOTVIEW(AX,'BestDataFitView') 
%     Reset plot view to fit all applicable data
% RESETPLOTVIEW(AX,'SaveCurrentView') 
%     Stores view state (limits, camera) 
% RESETPLOTVIEW(AX,'GetStoredViewStruct') 
%     Retrieves view information in the form of a structure. 
% RESETPLOTVIEW(AX,'ApplyStoredView') 
%     Apply stored view state to axes
% RESETPLOTVIEW(AX,'ApplyStoredViewLimitsOnly') 
%     Apply axes limit in stored state to axes
% RESETPLOTVIEW(AX,'ApplyStoredViewViewAngleOnly') 
%     Apply axes camera view angle in stored state to axes

if any(isempty(hAxes)) || ...
      ~any(ishandle(hAxes)) || ...
      ~any(isa(handle(hAxes), 'hg.axes'))
  return;
end

for n = 1:length(hAxes)
    retval = localResetPlotView(hAxes(n),varargin{:});
end

%--------------------------------------------------%
function [retval] = localResetPlotView(hAxes,varargin)

retval = [];
if nargin<2
  localAuto(hAxes);
  return;
end

KEY = 'matlab_graphics_resetplotview';

switch varargin{1}
    case 'InitializeCurrentView'
        viewinfo = getappdata(hAxes,KEY);
        if isempty(viewinfo)
            viewinfo = localCreateViewInfo(hAxes);
            setappdata(hAxes,KEY,viewinfo);                
        end
    case 'SaveCurrentView'
        viewinfo = localCreateViewInfo(hAxes);
        setappdata(hAxes,KEY,viewinfo);  
    case 'GetStoredViewStruct'
        retval = getappdata(hAxes,KEY);
    case 'ApplyStoredView'
        viewinfo = getappdata(hAxes,KEY);
        localApplyViewInfo(hAxes,viewinfo);
    case 'ApplyStoredViewLimitsOnly'
        viewinfo = getappdata(hAxes,KEY);
        localApplyLimits(hAxes,viewinfo);
    case 'ApplyStoredViewViewAngleOnly'
        viewinfo = getappdata(hAxes,KEY);
        localApplyViewAngle(hAxes,viewinfo);
    otherwise
        error('Invalid Input');
end

%----------------------------------------------------%
function [viewinfo] = localApplyViewAngle(hAxes,viewinfo)

if ~isempty(viewinfo)
    set(hAxes,'CameraViewAngle',viewinfo.CameraViewAngle);
end

%----------------------------------------------------%
function [viewinfo] = localApplyLimits(hAxes,viewinfo)

if ~isempty(viewinfo)
    
    set(hAxes,'XLim',viewinfo.XLim,...
              'YLim',viewinfo.YLim,...
              'ZLim',viewinfo.ZLim);
    set(hAxes,'XLimMode',viewinfo.XLimMode,...
              'YLimMode',viewinfo.YLimMode,...
              'ZLimMode',viewinfo.ZLimMode);
end

%----------------------------------------------------%
function [viewinfo] = localApplyViewInfo(hAxes,viewinfo)

if ~isempty(viewinfo)
     % Set state properties, this will force all corresponding modes
     % to manual
     set(hAxes,'DataAspectRatio',viewinfo.DataAspectRatio,...
             'PlotBoxAspectRatio',viewinfo.PlotBoxAspectRatio,...
             'XLim',viewinfo.XLim,...
             'YLim',viewinfo.YLim,...
             'ZLim',viewinfo.ZLim,...
             'CameraViewAngle',viewinfo.CameraViewAngle,...
             'CameraPosition',viewinfo.CameraPosition,...
             'CameraTarget',viewinfo.CameraTarget,...
             'CameraUpVector',viewinfo.CameraUpVector);
     % Force HG to update internal state of axes by querying.  
     % We could also use a drawnow here, but that will cause
     % a "flash" on the figure window
     junk = get(hAxes,'XLim');
     %drawnow;
     % Now set mode properties so that any auto modes are building
     % off of previous state.
     
     set(hAxes,'DataAspectRatioMode',viewinfo.DataAspectRatioMode,...
             'PlotBoxAspectRatioMode',viewinfo.PlotBoxAspectRatioMode,...
             'XLimMode',viewinfo.XLimMode,...
             'YLimMode',viewinfo.YLimMode,...
             'ZLimMode',viewinfo.ZLimMode,...
             'CameraViewAngleMode',viewinfo.CameraViewAngleMode,...
             'CameraTargetMode',viewinfo.CameraTargetMode,...
             'CameraUpVectorMode',viewinfo.CameraUpVectorMode);
      
    set(hAxes,'CameraPositionMode',viewinfo.CameraPositionMode);    
    
    % work around for geck 
    set(hAxes,'View',viewinfo.View);  
end
    
%----------------------------------------------------%
function [viewinfo] = localCreateViewInfo(hAxes)         

% Store axes view state
viewinfo.DataAspectRatio = get(hAxes,'DataAspectRatio');
viewinfo.DataAspectRatioMode = get(hAxes,'DataAspectRatioMode');
viewinfo.PlotBoxAspectRatio = get(hAxes,'PlotBoxAspectRatio');
viewinfo.PlotBoxAspectRatioMode = get(hAxes,'PlotBoxAspectRatioMode');
viewinfo.XLim = get(hAxes,'xLim');
viewinfo.XLimMode = get(hAxes,'XLimMode');
viewinfo.YLim = get(hAxes,'yLim');
viewinfo.YLimMode = get(hAxes,'YLimMode');
viewinfo.ZLim = get(hAxes,'zLim');
viewinfo.ZLimMode = get(hAxes,'ZLimMode');
viewinfo.CameraPosition = get(hAxes,'CameraPosition');
viewinfo.CameraViewAngleMode = get(hAxes,'CameraViewAngleMode');
viewinfo.CameraTarget = get(hAxes,'CameraTarget');
viewinfo.CameraPositionMode = get(hAxes,'CameraPositionMode');
viewinfo.CameraUpVector = get(hAxes,'CameraUpVector');
viewinfo.CameraTargetMode = get(hAxes,'CameraTargetMode');
viewinfo.CameraViewAngle = get(hAxes,'CameraViewAngle');
viewinfo.CameraUpVectorMode = get(hAxes,'CameraUpVectorMode');
viewinfo.View = get(hAxes,'View');

%----------------------------------------------------%
function localAuto(hAxes)

% reset 2-D axes
if is2D(hAxes)
  
   % If only axes child is an image, then set limits
   % to be tight
   h = get(hAxes,'children');
   h = handle(h);
   if ~isempty(h) && length(h)==1 && isa(h,'hg.image')
       axis(hAxes,'image');
   else
       
       % Breaks tzoom test point
       %axis(hAxes,'tight');
      
       axis(hAxes,'auto');
   end
      %set(hAxes,'XLimMode','auto','YLimMode','auto','ZLimMode','auto');
      
   % Otherwise, let the HG limit picker choose the best 
   % size   
 %  else
 %    set(hAxes,'XLimMode','auto',...
 %           'YLimMode','auto',...
 %           'ZLimMode','auto');   
 %  end  
   
% reset 3-D axes  
else
   camva(hAxes,'auto');
   camtarget(hAxes,'auto');
end


