function [out1,out2,savepts] = balthsrt(mstruct,in1,in2,object,direction,savepts)

%BALTHSRT  Balthasart Cylindrical Projection
%
%  This is an orthographic projection onto a cylinder secant at the
%  50 degree parallels.  It is equal area, but distortion of shape
%  increases with distance from the standard parallels.  Scale is true
%  along the standard parallels and constant between two parallels
%  equidistant from the Equator.  This projection is not equidistant.
%
%  The Balthasart Cylindrical projection was presented in 1935 and is
%  a special form of the Equal Area Cylindrical projection secant
%  at 50 degrees N and S.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(50,'degrees',mstruct.angleunits);
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
