function updateMarkers(hThis)
%UPDATEMARKERS

% Copyright 2003 The MathWorks, Inc.

% debug(hThis,'@cursorbar\updateMarkers.m : start updateMarkers');

% get line handles
hTarget = hThis.Target;

% get current position
pos = get(hThis,'Position');

% determine which vertices will be intersected
switch hThis.Orientation
    case 'vertical'
        ind = find(hThis.TargetXData == pos(1));
    case 'horizontal'
        ind = find(hThis.TargetYData == pos(2));
end



if ~isempty(hTarget) || ~isa(hTarget,'hg.axes')       
    set(hThis.TargetMarkerHandle,'Visible','on',...
                                                'XData',hThis.TargetXData(ind),...
                                                'YData',hThis.TargetYData(ind));    
else
    % 
    set(hThis.TargetMarkerHandle,'Visible','off',...
                                                          'XData',[],...
                                                          'YData',[]);
end

% debug(hThis,'@cursorbar\updateMarkers.m : end updateMarkers');