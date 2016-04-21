function setunits(this,property,value)
% SETUNITS is a method that applies the units to the plot. The units are
% obtained from the view preferences. Since this method is plot specific,
% not all fields of the Units structure are used.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:20:28 $

switch property
case 'FrequencyUnits'
    this.AxesGrid.XUnits = value;
case 'MagnitudeUnits'
    this.AxesGrid.YUnits = {value, this.AxesGrid.YUnits{2}};
case 'PhaseUnits'
    this.AxesGrid.YUnits = {this.AxesGrid.YUnits{1},value};
case 'FrequencyScale'
    this.AxesGrid.XScale = {value};
case 'MagnitudeScale'
    this.AxesGrid.YScale = {value, this.AxesGrid.YScale{2}};
end
