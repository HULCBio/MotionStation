function [x,y] = closestvertex(hThis,pos)
%CLOSESTVERTEX return X,Y location of closest Target vertex

% Copyright 2003 The MathWorks, Inc.

% debug(hThis,'@cursorbar\closestvertex.m start closestvertex')

hTarget = hThis.Target;

x = [];
y = [];

if isTargetAxes(hThis)
        %don't need to find closest vertex if the Target is an axes
        return
end

% get X-, and  YData
x = hThis.TargetXData;
y = hThis.TargetYData;

% determine distance in a single dimension, dependent on Orientation
switch hThis.Orientation    
    case 'vertical'
%         debug(hThis,'@cursorbar\closestvertex.m vertical')
        dist = abs(pos(1) - x);
    case 'horizontal'
%         debug(hThis,'@cursorbar\closestvertex.m horizontal')
        dist = abs(pos(2) - y);
end

% get index for minimum distance
[mindist,ind] = min(dist);

x = x(ind);
y = y(ind);

% debug(hThis,'@cursorbar\closestvertex.m end closestvertex')
