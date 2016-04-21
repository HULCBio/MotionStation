function [th,len] = vfwdtran(varargin)

%VFWDTRAN  Transforms vector azimuths to a projection space angle
%
%  th = VFWDTRAN(lat,lon,az) transforms the azimuth angle at specified 
%  latitude and longitude points on the sphere into the projection space.
%  The map projection currently displayed is used to define the projection
%  space.  The input angles must be in the same units as specified by
%  the current map projection.  The inputs can be scalars or matrices
%  of the equal size. The angle in the projection space is defined 
%  positive counter-clockwise from the x axis.
%
%  th = VFWDTRAN(mstruct,lat,lon,az) uses the map projection defined by the
%  input mstruct to compute the map projection.
%
%  [th,len] = VFWDTRAN(...) also returns the vector length in the projected 
%  coordinate system. A value of 1 indicates no scale distortion.
%
%  This transformation is limited to the region specified by
%  the frame limits in the current map definition.
%
%  See also VINVTRAN, MFWDTRAN, MINVTRAN, DEFAULTM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, W. Stumpf
%   $Revision: 1.1.6.1 $    $Date: 2003/12/13 02:57:29 $


%  Parse inputs

if nargin == 3 & ~isstruct(varargin{1})
	  mstruct = [];
      lat   = varargin{1};
	  lon   = varargin{2};
	  az    = varargin{3};
elseif nargin == 4 & isstruct(varargin{1})
	  mstruct = varargin{1};
      lat   = varargin{2};
	  lon   = varargin{3};
	  az    = varargin{4};
else
   error('Incorrect number of arguments')	  
end

%  Initialize output

th = [];

if isempty(mstruct)
   [mstruct,msg] = gcm;
   if ~isempty(msg);   error(msg);   end
end

%  Check inputs

if ~isequal(size(lat),size(lon),size(az))
    error('Lat, lon and azimuth inputs must be the same size')
end
if strcmp(mstruct.mapprojection,'globe')
    error('VFWDTRAN does not work on globe projections')
end

%  Transform data to degress

units = mstruct.angleunits;

lat     = angledim(lat,units,'degrees');
lon     = angledim(lon,units,'degrees');

origin  = angledim(mstruct.origin,   units,'degrees');
frmlon  = angledim(mstruct.flonlimit,units,'degrees');
frmlat  = angledim(mstruct.flatlimit,units,'degrees');

%  Rotate the input data to the base coordinate system.
%  This is the same coordinate system as the map frame.

[LatRot,LonRot] = rotatem(lat,lon,origin,'forward','degrees');

%  Check for points outside the map frame

indx = find(LonRot < min(frmlon) | LonRot > max(frmlon) | ...
            LatRot < min(frmlat) | LatRot > max(frmlat) );

if ~isempty(indx)
   warning('Point outside of valid projection region')
   LatRot(indx)=NaN;   LonRot(indx)=NaN;
end

%  Check for points near the edge of the map. Back away from 
%  the edges.

% Back away from the poles to avoid problems reckoning. Convergence of
% the meridians makes east-west movements cross the dateline in longitude, 
% even if we back away by a couple of meters.

latlim = 89.9;dlat = 90-latlim;

indx = find(LatRot <= -latlim);
if ~isempty(indx);    LatRot(indx) = LatRot(indx)+dlat;   end   
indx = find(LatRot >= latlim);
if ~isempty(indx);    LatRot(indx) = LatRot(indx)-dlat;   end   

% Back away from the edges

epsilon = 10000*epsm('degrees');

indx = find(LonRot <= min(frmlon)+epsilon);
if ~isempty(indx);    LonRot(indx) = min(frmlon)+epsilon;   end   
indx = find(LonRot >= max(frmlon)-epsilon);
if ~isempty(indx);    LonRot(indx) = max(frmlon)-epsilon;   end   

indx = find(LatRot <= min(frmlat)+epsilon);
if ~isempty(indx);    LatRot(indx) = min(frmlat)+epsilon;   end   
indx = find(LatRot >= max(frmlat)-epsilon);
if ~isempty(indx);    LatRot(indx) = max(frmlat)-epsilon;   end   

%  Return processed data back to the original space

[LatNew,LonNew] = rotatem(LatRot,LonRot,origin,'inverse','degrees');

%  Reckon a point about 10 centimeters off the starting point

epsilon = 10*epsm('degrees');

rng = epsilon*ones(size(LatNew));
% rng = rng/mstruct.geoid(1);

[Lat2,Lon2] = reckon('rh',LatNew,LonNew,rng,az,mstruct.geoid,'degrees'); %mstruct.geoid,

%  Transform to the projection space

[x1,y1] = mfwdtran(mstruct,LatNew,LonNew);
[x2,y2] = mfwdtran(mstruct,Lat2,Lon2);

%  Compute the angle theta.

th = atan2(y2-y1,x2-x1);
th = npi2pi(th,'radians');
th = angledim(th,'radians',units);

%  Compute the length of the vector

len = sqrt( (y2-y1).^2 + (x2-x1).^2 ) ./ rng ;

