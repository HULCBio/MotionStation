function [out1,out2,savepts] = lambcyln(mstruct,in1,in2,object,direction,savepts)

%LAMBCYLN  Lambert Equal Area Cylindrical Projection
%
%  This is an orthographic projection onto a cylinder tangent at the
%  Equator.  It is equal area, but distortion of shape increases with
%  distance from the Equator.  Scale is true along the Equator and
%  constant between two parallels equidistant from the Equator.  This
%  projection is not equidistant.
%
%  This projection is named for Johann Heinrich Lambert, and is a
%  special form of the Equal Area Cylindrical projection tangent
%  at the Equator.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = 0;
      mstruct.nparallels = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;      return

elseif nargin == 5
      [out1,out2,savepts] = eqacylin(mstruct,in1,in2,object,direction);

elseif nargin == 6
      [out1,out2] = eqacylin(mstruct,in1,in2,object,direction,savepts);

else
      error('Incorrect number of arguments')
end
