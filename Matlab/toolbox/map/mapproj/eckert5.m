function [out1,out2,savepts] = eckert5(mstruct,in1,in2,object,direction,savepts)

%ECKERT5  Eckert V Pseudocylindrical Projection
%
%  This projection is an arithmetical average of the x and y coordinates
%  of the Sinusoidal and Plate Carree projections.  Scale is true along
%  latitudes 37 deg, 55 min N and S, and is constant along any parallel
%  and between any pair of parallels equidistant from the Equator.  There
%  is no point free of all distortion, but the Equator is free of
%  angular distortion.  This projection is not equal area, conformal
%  or equidistant.
%
%  This projection was presented by Max Eckert in 1906.
%
%  This projection is available for the spherical geoid only.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = 0;
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;          return

elseif nargin == 5
      [out1,out2,savepts] = winkel(mstruct,in1,in2,object,direction);

elseif nargin == 6
      [out1,out2] = winkel(mstruct,in1,in2,object,direction,savepts);

else
      error('Incorrect number of arguments')
end
