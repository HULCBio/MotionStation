function [x,y] = getTargetXYData(hThis)
%GETTARGETXYDATA create vectors of Target XData and YData

% Copyright 2003 The MathWorks, Inc.

% debug(hThis,'@cursorbar\getTargetXYData : start getTargetXYData');

hTarget = hThis.Target;

x = [];
y = [];

if isTargetAxes(hThis)
    % debug(hThis,'@cursorbar\getTargetXYData : end getTargetXYData: axes');
    return
elseif numel(hTarget) == 1
    xData = {get(hTarget,'XData')};
    yData = {get(hTarget,'YData')};
else % should all be lines
    xData = get(hTarget, 'XData');
    yData = get(hTarget, 'YData');
end

% determine how many vertices each line has
numLineVertices = cellfun('prodofsize',xData);

% determine the total number of vertices
numAllVertices = sum(numLineVertices);

% create vectos to hold locations for all vertices
xVertices = zeros(1,numAllVertices);
yVertices = zeros(1,numAllVertices);

%initialize variable to hold the last entered data position
lastDataPos = 0;
for n = 1:length(hTarget)
    lenData = length(xData{n});    
    xVertices(lastDataPos+1:lastDataPos+lenData) = xData{n};
    yVertices(lastDataPos+1:lastDataPos+lenData) = yData{n};
    lastDataPos = lastDataPos + lenData;    
end


% sort the Target's XData and YData based on the Orientaion

switch hThis.Orientation
    case 'vertical'
        [x,ind] = sort(xVertices);
        y = yVertices(ind);        
    case 'horizontal'
        [y,ind] = sort(yVertices);
        x = xVertices(ind);
end


% debug(hThis,'@cursorbar\getTargetXYData : end getTargetXYData: line');
