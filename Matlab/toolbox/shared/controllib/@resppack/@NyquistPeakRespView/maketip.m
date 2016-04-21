function str = maketip(this,tip,info)
%MAKETIP  Build data tips for NyquistPeakRespView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:11 $

r = info.Carrier;
cData = info.Data;
AxGrid = info.View.AxesGrid;

% Response info
str{1,1} = sprintf('Response: %s',r.Name);
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col); 
if any(AxGrid.Size(1:2)>1) | ShowFlag 
    % Show if MIMO or non trivial 
    str{end+1,1} = iotxt; 
end

FreqUnits = r.Parent.FrequencyUnits;  % plot-wide frequency units
Frequency = unitconv(cData.Frequency(info.Row,info.Col),cData.Parent.FreqUnits,FreqUnits);
MagUnits = r.Parent.MagnitudeUnits;
Peak = unitconv(abs(cData.PeakResponse(info.Row,info.Col)),'abs',MagUnits);

str{end+1,1} = sprintf('Peak gain (%s): %0.3g',MagUnits,Peak);
str{end+1,1} = sprintf('Frequency (%s): %0.3g',FreqUnits,Frequency);
