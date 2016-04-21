function [Gain, Mag, Pha, Freq] = nicholsdata(Editor)
%NICHOLSDATA  Gain, Magnitude, Phase, and Frequency data in current units

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.9 $  $Date: 2002/04/10 05:05:18 $

% Convert Nichols data to current units
Gain = getzpkgain(Editor.EditedObject,'mag'); 
Mag  = mag2dB(Editor.Magnitude * Gain);
Pha  = unitconv(Editor.Phase, 'deg', Editor.Axes.XUnits);
Freq = unitconv(Editor.Frequency, 'rad/sec', Editor.FrequencyUnits);
