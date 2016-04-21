function [out1,out2,savepts] = sinusoid(mstruct,in1,in2,object,direction,savepts)

%SINUSOID  Sinusoidal Pseudocylindrical Projection
%
%  This projection is equal area.  Scale is true along every parallel
%  and along the central meridian.  There is no distortion along the
%  Equator or along the central meridian, but it becomes severe near
%  the outer meridians at high latitudes.
%
%  This projection was developed in the 16th century.  It was used
%  by Jean Cossin in 1570 and by Jodocus Hondius in Mercator atlases
%  of the early 17th century.  It is the oldest pseudocylindrical
%  projection currently in use, and is sometimes called the
%  Sanson-Flamsteed or the Mercator Equal Area projections.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = 0;
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;      return

elseif nargin == 5
      [out1,out2,savepts] = bonne(mstruct,in1,in2,object,direction);

elseif nargin == 6
      [out1,out2] = bonne(mstruct,in1,in2,object,direction,savepts);

else
      error('Incorrect number of arguments')
end
