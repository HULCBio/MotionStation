function [x,y] = getMarkerLocations(hThis)
%GETMARKERLOCATIONS return x,y position of the cursorbar's intersection markers

% Copyright 2003 The MathWorks, Inc.

hMarker = hThis.TargetMarkerHandle;

x = get(hMarker,'XData');
y = get(hMarker,'YData');