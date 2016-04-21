function [out1,out2,savepts] = giso(mstruct,in1,in2,object,direction,savepts)

%GISO  Gall Isographic Cylindrical Projection
%
%  This is a projection onto a cylinder secant at 45 degree parallels.
%  Distortion of both shape and area increase with distance from the
%  standard parallels.  Scale is true along all meridians (i.e. it is
%  equidistant) and the standard parallels, and is constant along
%  any parallel and along the parallel of opposite sign.
%
%  This projection is a specific case of the Equidistant Cylindrical
%  projection, with standard parallels at 45 deg N and S.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(45,'degrees',mstruct.angleunits);
      mstruct.nparallels   = 0;
	  mstruct.fixedorient  = [];
	  out1 = mstruct;      return

elseif nargin == 5
      [out1,out2,savepts] = eqdcylin(mstruct,in1,in2,object,direction);

elseif nargin == 6
      [out1,out2] = eqdcylin(mstruct,in1,in2,object,direction,savepts);

else
      error('Incorrect number of arguments')
end
