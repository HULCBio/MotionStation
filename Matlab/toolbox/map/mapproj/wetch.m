function [out1,out2,savepts] = wetch(mstruct,in1,in2,object,direction,savepts)

%WETCH  Wetch Cylindrical Projection
%
%  This is a perspective projection from the center of the Earth onto
%  a cylinder tangent at the central meridian.  It is not equal area,
%  equidistant, or conformal.  Scale is true along the central meridian
%  and constant between two points equidistant in x and y from the
%  central meridian.  There is no distortion along the central meridian,
%  but it increases rapidly away from it in the y-direction.
%
%  This is the transverse aspect of the Central Cylindrical projection
%  discussed by J. Wetch in the early 19th century.
%
%  This projection is available for the spherical geoid only.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -75  75],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
      mstruct.fixedorient = angledim(-90,'degrees',mstruct.angleunits);
	  mstruct.mapparallels = 0;
      mstruct.nparallels   = 0;
	  out1 = mstruct;          return

elseif nargin == 5
      [out1,out2,savepts] = ccylin(mstruct,in1,in2,object,direction);

elseif nargin == 6
      [out1,out2] = ccylin(mstruct,in1,in2,object,direction,savepts);

else
      error('Incorrect number of arguments')
end
