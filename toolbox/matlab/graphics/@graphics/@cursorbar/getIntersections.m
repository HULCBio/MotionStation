function [xIntersect,yIntersect,hIntersect] = getIntersections(hThis,hLines)
%GETINTERSECTIONS return intersection information

% Copyright 2003 The MathWorks, Inc.

% check inputs
if nargin > 1
    hLines = handle(hLines);
    if ~all(isa(hLines,'hg.line'))
        error('Second input must be handles for line objects.');
    end
else
    hLines = hThis.Target;
end

xIntersect = [];
yIntersect = [];
hIntersect = [];

if isTargetAxes(hThis)  && nargin < 2
    % Target is an axes, no additional line handles as input, return early
    return
end

% get lines' XData and YData
xData = get(hLines,'XData');
yData = get(hLines,'YData');

numLines = numel(hLines);

if numLines == 1
    xData = xData(:);
    yData = yData(:);
    hData = repmat(hLines,size(xData));
else
    xSizes = cellfun('prodofsize',xData);
    ySizes = cellfun('prodofsize',yData);
    
    % determine new length for NaN separated data vectors
    newLength = sum(xSizes) + numLines - 1;
    
    new_xData = zeros(newLength,1);
    new_yData = zeros(newLength,1);
    hData = zeros(newLength,1);
    
    startIndex = 1;
    for n = 1:numLines
        finishIndex = startIndex + xSizes(n) - 1;
        new_xData(startIndex:finishIndex) = xData{n};
        new_yData(startIndex:finishIndex) = yData{n};
        hData(startIndex:finishIndex) = hLines(n);
        
        if n < numLines
            new_xData(finishIndex + 1) = NaN;
            new_yData(finishIndex + 1) = NaN;
            hData(finishIndex + 1) = NaN;
        end
        startIndex = finishIndex + 2;        
    end
    xData = new_xData;
    yData = new_yData;
end

xSegs = zeros(length(xData)-1,2);
ySegs = zeros(length(yData)-1,2);

xSegs(:,1) = xData(1:end-1);
xSegs(:,2) = xData(2:end);

ySegs(:,1) = yData(1:end-1);
ySegs(:,2) = yData(2:end);

loc = hThis.Location;

switch hThis.Orientation
    case 'vertical'
        btwn = (xSegs(:,1) < loc & loc <= xSegs(:,2)) | (xSegs(:,2) < loc & loc <= xSegs(:,1));
    case 'horizontal'
        btwn = (ySegs(:,1) < loc & loc <= ySegs(:,2)) | (ySegs(:,2) < loc & loc <= ySegs(:,1));
end

new_xSegs = xSegs(btwn,:);
new_ySegs = ySegs(btwn,:);

numIntersect = length(find(btwn));
xIntersect = zeros(numIntersect,1);
yIntersect = zeros(numIntersect,1);

if numIntersect == 0
    return
end

switch hThis.Orientation
    case 'vertical'
        for n = 1:numIntersect
            xIntersect(n) = loc;
            yIntersect(n) = interp1(new_xSegs(n,:),new_ySegs(n,:),loc);
        end
    case 'horizontal'
        for n = 1:numIntersect
            yIntersect(n) = loc;
            xIntersect(n) = interp1(new_ySegs(n,:),new_xSegs(n,:),loc);
        end
end

hIntersect = hData(btwn);






