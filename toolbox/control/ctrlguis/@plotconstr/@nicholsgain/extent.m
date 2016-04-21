function Extent = extent(Constr)
%EXTENT  Returns bounding rectangle [Xmin Xmax Ymin Ymax]

%   Author(s): Bora Eryilmaz
%   Copyright 1986-2002 The MathWorks, Inc. 
%   $Revision: 1.5 $  $Date: 2002/04/10 05:11:21 $

RangePha = unitconv([1 1]*Constr.OriginPha,  'deg', Constr.PhaseUnits);
RangeMag = unitconv([-1 1]*Constr.MarginGain, 'dB', Constr.MagnitudeUnits);
Extent = [RangePha, RangeMag];
