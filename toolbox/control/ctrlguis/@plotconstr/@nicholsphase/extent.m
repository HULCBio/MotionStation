function Extent = extent(Constr)
%EXTENT  Returns bounding rectangle [Xmin Xmax Ymin Ymax]

%   Author(s): Bora Eryilmaz
%   Revised:
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:09:53 $

RangePha = unitconv(Constr.OriginPha + [-1 1] * Constr.MarginPha, ...
		    'deg', Constr.PhaseUnits);
RangeMag = unitconv([0 0], 'dB', Constr.MagnitudeUnits);
Extent = [RangePha, RangeMag];
