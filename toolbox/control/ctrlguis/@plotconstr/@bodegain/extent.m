function Extent = extent(Constr)
%EXTENT  Returns bounding rectangle [Xmin Xmax Ymin Ymax]

%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.4 $  $Date: 2002/04/10 05:08:04 $
Extent = [unitconv(Constr.Frequency,'rad/sec',Constr.FrequencyUnits) , ...
		unitconv(Constr.Magnitude,'dB',Constr.MagnitudeUnits)];