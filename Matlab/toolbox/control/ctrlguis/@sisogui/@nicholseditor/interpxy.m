function interpxy(Editor, Magnitude, Phase)
%INTERPXY  Sets the X and Y coordinates of zero/pole markers of 
%          plant/compensator overlayed on Nichols plot.
%          Magnitude and Phase should be in Current Units.
%
%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.7 $ $Date: 2002/04/10 05:04:30 $

% Get HG handle
HG = Editor.HG;

% Convert frequency data to current units
Frequency = unitconv(Editor.Frequency, 'rad/sec', Editor.FrequencyUnits);

% Get handles of Nichols plot objects (zero/pole markers for plant/compensator)
hPZ = [HG.System ; HG.Compensator];

% Get frequency data of corresponding objects in current units
FreqPZ = get(hPZ, {'UserData'});
FreqPZ = unitconv(cat(1, FreqPZ{:}), 'rad/sec', Editor.FrequencyUnits);

% Compute interpolated Magnitude and Phase locations (in current units)
MagPZ = interp1(Frequency, Magnitude, FreqPZ);
PhaPZ = interp1(Frequency, Phase, FreqPZ);

% Set X and Y coordinates of object handles
for ct = 1:length(FreqPZ)
  set(hPZ(ct), 'XData', PhaPZ(ct), 'YData', MagPZ(ct));
end
