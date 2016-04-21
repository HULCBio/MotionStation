function [Status] = pointerlocation(Editor)
% POINTERLOCATION  Returns a string for pointer location info.

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc.
%   $Revision: 1.5 $ $Date: 2002/04/10 05:06:00 $

% Handles
PlotAxes = getaxes(Editor.Axes);

% Get Nichols plot data in current units
[Gain, Magnitude, Phase, Frequency] = nicholsdata(Editor);
    
% Acquire new marker position 
% REMARK: * Convert to working units
%         * Restrict X position to be in Phase range
%         * Restrict Y position to be in Mag range
CP = get(PlotAxes, 'CurrentPoint');
X = max(min(Phase), min(CP(1,1), max(Phase)));
Y = max(min(Magnitude), min(CP(1,2), max(Magnitude)));

% Frequency at the point closest to the mouse, in current units.
W = Editor.project(X, Y, Phase, Magnitude, Frequency);

str1 = sprintf('Magnitude: %0.3g %s', Y, 'dB');
str2 = sprintf('Phase: %0.3g %s',     X, Editor.Axes.XUnits);
str3 = sprintf('Frequency: %0.3g %s', W, Editor.FrequencyUnits);

Spacing = blanks(4);
Status = sprintf('%s%s%s%s%s', str1, Spacing, str2, Spacing, str3);
