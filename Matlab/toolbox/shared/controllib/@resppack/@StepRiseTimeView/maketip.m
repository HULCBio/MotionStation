function str = maketip(this,tip,info)
%MAKETIP  Build data tips for SettleTimeView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:54 $

r = info.Carrier;
AxGrid = info.View.AxesGrid;

str = {sprintf('Response: %s',r.Name)};
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col); 
if any(AxGrid.Size(1:2)>1) | ShowFlag 
    % Show if MIMO or non trivial 
    str{end+1,1} = iotxt; 
end

Time = info.View.Points(info.Row,info.Col).XData;
TLow = info.Data.TLow(info.Row,info.Col);
THigh = info.Data.THigh(info.Row,info.Col);
RT = Time - TLow;  % rise time estimate
if Time==THigh
   str{end+1,1} = sprintf('Rise Time (%s): %0.3g',AxGrid.XUnits, RT);
elseif Time>TLow
   str{end+1,1} = sprintf('Rise Time > %0.3g (%s)', RT, AxGrid.XUnits);
else
   str{end+1,1} = sprintf('Rise Time: N/A');
end
