function [out1,out2,savepts] = werner(mstruct,in1,in2,object,direction,savepts)

%WERNER  Werner Pseudoconic Projection
%
%  This is an equal area projection.  It is a Bonne projection with
%  of the poles as its standard parallel.  The central meridian
%  is free of distortion.  This projection is not conformal.
%  Its heart shape gives it the additional descriptor "cordiform".
%
%  This projection was developed by Johannes Stabius (Stab) about
%  1500 and was promoted by Johannes Werner in 1514.  It is also
%  called the Stab-Werner projection.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1                  %  Set the default structure entries
	  mstruct.trimlat = angledim([ -90  90],'degrees',mstruct.angleunits);
      mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	  mstruct.mapparallels = angledim(90,'degrees',mstruct.angleunits);
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
