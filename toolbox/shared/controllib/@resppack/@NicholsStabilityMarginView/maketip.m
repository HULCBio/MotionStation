function str = maketip(this,tip,info)
%MAKETIP  Build data tips for NicholsStabilityMarginView Characteristics.

%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:19:05 $
AxGrid = info.View.AxesGrid;
r = info.Carrier;
% UDDREVISIT
str = maketip_p(this,tip,info,r.Parent.FrequencyUnits,AxGrid.YUnits,AxGrid.XUnits);
