function setunits(this,property,value)
% SETUNITS is a method that applies the units to the plot. The units are
% obtained from the view preferences. Since this method is plot specific,
% not all fields of the Units structure are used.

%   Authors: Kamesh Subbarao
%   Copyright 1986-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/11 00:23:20 $

switch property
case 'FrequencyUnits'
    set(this.AxesGrid,'XUnits',value);
case 'MagnitudeUnits'
    set(this.AxesGrid,'YUnits',value);
case 'FrequencyScale'
    set(this.AxesGrid,'XScale',{value});
case 'MagnitudeScale'
    set(this.AxesGrid,'YScale',{value});
end

