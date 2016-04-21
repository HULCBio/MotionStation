function [out1,out2,savepts] = gortho(mstruct,in1,in2,object,direction,savepts)

%GORTHO  Gall Orthographic Cylindrical Projection
%
%  This is an orthographic projection onto a cylinder secant at the
%  45 degree parallels.  It is equal area, but distortion of shape
%  increases with distance from the standard parallels.  Scale is true
%  along the standard parallels and constant between two parallels
%  equidistant from the Equator.  This projection is not equidistant.
%
%  This projection was named for James Gall, who originated it in 1855
%  and is a special form of the Equal Area Cylindrical projection
%  secant at 45 deg N and S. It is also known as the Peters projection.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(45,'degrees',mstruct.angleunits);
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;      return

elseif nargin == 5
      [out1,out2,savepts] = eqacylin(mstruct,in1,in2,object,direction);

elseif nargin == 6
      [out1,out2] = eqacylin(mstruct,in1,in2,object,direction,savepts);

else
      error('Incorrect number of arguments')
end
