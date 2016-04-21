function [out1,out2,savepts] = ups(mstruct,in1,in2,object,direction,savepts)

%UPS Universal Polar Stereographic Projection
% 
%  This is a perspective projection on a plane tangent to the north or south 
%  pole This projection has two significant properties.  It is conformal, 
%  being free from angular distortion.  Additionally, all great and small 
%  circles are either straight lines or circular arcs on this projection.  
%  
%  This projection has two zones, 'north' and 'south'.  In the northern zone 
%  scale is true along latitude 87 degrees, 7 minutes N, and is constant 
%  along any other parallel.  In the southern zone the latitude of true scale 
%  is 87 degrees, 7 minutes S. This projection is not equal area.
% 
%  This projection is a special case of the stereographic projection in the 
%  polar aspect.  It is used as part of the Universal Transverse Mercator 
%  (UTM) system to extend coverage to the poles.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.5.4.1 $  $Date: 2003/08/01 18:24:37 $

if nargin == 1                  %  Set the default structure entries (See Snyder, working manual)
	if isempty(mstruct.zone)
		mstruct.zone = 'north';
		mstruct.geoid = [];
		mstruct.maplatlimit = [];
		mstruct.maplonlimit = [];
		mstruct.flatlimit = [];
		mstruct.flonlimit = [];
		mstruct.origin = [];
		mstruct.mlinelocation = [];
		mstruct.plinelocation = [];
		mstruct.mlabellocation = [];
		mstruct.plabellocation = [];
		mstruct.mlabelparallel = [];
		mstruct.plabelmeridian = [];
	end
	
	if strmatch(mstruct.zone,'north')
		mstruct.trimlat = angledim([-Inf 6],'degrees',mstruct.angleunits);
	elseif strmatch(mstruct.zone,'south')
		mstruct.trimlat = angledim([-Inf 10],'degrees',mstruct.angleunits);
	end

	mstruct.trimlon = angledim([-180 180],'degrees',mstruct.angleunits);
	mstruct.mapparallels = [];
	mstruct.nparallels   = 0;
	mstruct.fixedorient  = [];
	mstruct.falseeasting = 2000000; % meters
	mstruct.falsenorthing = 2000000; % meters
	mstruct.scalefactor = 0.994;

	out1 = mstruct;     return
elseif nargin ~= 5 & nargin ~= 6
      error('Incorrect number of arguments')
end

if nargin==5
	[out1,out2,savepts] = stereo(mstruct,in1,in2,object,direction);
elseif nargin==6
	[out1,out2,savepts] = stereo(mstruct,in1,in2,object,direction,savepts);
end

