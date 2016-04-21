function [out1,out2,savepts] = bsam(mstruct,in1,in2,object,direction,savepts)

%BSAM  Bolshoi Sovietskii Atlas Mira Cylindrical Projection
%
%  This is a perspective projection from a point on the Equator
%  opposite a given meridian onto a cylinder secant at the 30 degree
%  parallels.  It is not equal area, equidistant, or conformal.
%  Scale is true along the standard parallels and constant between
%  two parallels equidistant from the Equator.  There is no distortion
%  along the standard parallels, but it increases moderately away from
%  these parallels, becoming severe at the poles.
%
%  This projection was first described in 1937, when it was used for
%  maps in the Bolshoi Sovietskii Atlas Mira (Great Soviet World Atlas).
%  It is commonly abbreviated as the BSAM projection.  It is a special
%  form of the Braun Perspective Cylindrical projection, secant at
%  30 degrees N and S.
%
%  This projection is available for the spherical geoid only.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.10.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(30,'degrees',mstruct.angleunits);
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;      return

elseif nargin == 5
      [out1,out2,savepts] = braun(mstruct,in1,in2,object,direction);

elseif nargin == 6
      [out1,out2] = braun(mstruct,in1,in2,object,direction,savepts);

else
      error('Incorrect number of arguments')
end

