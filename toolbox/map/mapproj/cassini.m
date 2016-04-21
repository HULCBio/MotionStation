function [out1,out2,savepts] = cassini(mstruct,in1,in2,object,direction,savepts)

%CASSINI  Cassini Cylindrical Projection
%
%  This is a projection onto a cylinder tangent at the central
%  meridian.  Distortion of both shape and area are functions of distance
%  from the central meridian.  Scale is true along the central meridian
%  and along any straight line perpendicular to the central meridian
%  (i.e., it is equidistant).
%
%  This projection is the transverse aspect of the Plate Carree projection,
%  developed by Cesar Francois Cassini de Thury (1714-84).  It is still
%  used for the topographic mapping of a few countries.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
      mstruct.fixedorient = angledim(-90,'degrees',mstruct.angleunits);
	  mstruct.mapparallels = 0;
      mstruct.nparallels   = 0;
	  out1 = mstruct;      return

elseif nargin == 5
      [out1,out2,savepts] = eqdcylin(mstruct,in1,in2,object,direction);

elseif nargin == 6
      [out1,out2] = eqdcylin(mstruct,in1,in2,object,direction,savepts);

else
      error('Incorrect number of arguments')
end
