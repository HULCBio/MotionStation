function str = maketip(this,tip,info)
%MAKETIP  Build data tips for SettleTimeView Characteristics.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): John Glass
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:01 $

r = info.Carrier;
AxGrid = info.View.AxesGrid;

str{1,1} = sprintf('Response: %s',r.Name);

[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col); 
if any(AxGrid.Size(1:2)>1) | ShowFlag 
    % Show if MIMO or non trivial 
    str{end+1,1} = iotxt; 
end

str{end+1,1} = sprintf('Final Value: %0.3g', info.Data.FinalValue(info.Row,info.Col));
