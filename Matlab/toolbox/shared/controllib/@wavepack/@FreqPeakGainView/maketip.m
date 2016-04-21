function str = maketip(this,tip,info)
%MAKETIP  Build data tips for FreqPeakRespView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:25:26 $

r = info.Carrier;
cData = info.Data;
AxGrid = info.View.AxesGrid;
MagUnits = AxGrid.YUnits;
if iscell(MagUnits)
   MagUnits = MagUnits{1};  % for mag/phase plots
end

str{1,1} = sprintf('Response: %s',r.Name);
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col); 
if any(AxGrid.Size(1:2)>1) | ShowFlag 
    % Show if MIMO or non trivial 
    str{end+1,1} = iotxt; 
end

% Note: Characteristic data expressed in same units as carrier's response data
XData = unitconv(cData.Frequency(info.Row,info.Col),cData.Parent.FreqUnits,AxGrid.XUnits);
YData = unitconv(cData.PeakGain(info.Row,info.Col),cData.Parent.MagUnits,MagUnits);
str{end+1,1} = sprintf('Peak gain (%s): %0.3g', MagUnits, YData);
str{end+1,1} = sprintf('At frequency (%s): %0.3g', AxGrid.XUnits, XData);
