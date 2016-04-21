function str = maketip(this,tip,info)
%MAKETIP  Build data tips for @bodeview curves.
%
%   INFO is a structure built dynamically by the data tip interface
%   and passed to MAKETIP to facilitate construction of the tip text.

%   Author(s): P. Gahinet
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:36 $

r = info.Carrier;
AxGrid = info.View.AxesGrid;

% Create tip text
str{1,1} = sprintf('Response: %s',r.Name);
[iotxt,ShowFlag] = rcinfo(r,info.Row,info.Col);
if any(AxGrid.Size(1:2)>1) | ShowFlag
   % Show if MIMO or non trivial
   str{end+1,1} = iotxt;
end
str{end+1,1} = sprintf('Frequency (%s): %0.3g', AxGrid.XUnits,tip.Position(1));
if info.SubPlot==1
   str{end+1,1} = sprintf('Magnitude (%s): %0.3g',...
      AxGrid.YUnits{1},tip.Position(2));
else
   str{end+1,1} = sprintf('Phase (%s): %0.3g', ...
      AxGrid.YUnits{2},tip.Position(2));
end
