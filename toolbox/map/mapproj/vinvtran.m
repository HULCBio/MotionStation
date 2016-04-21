function [az,len] = vinvtran(varargin)

%VINVTRAN  Transforms azimuths from a projection space angle
%
%  az = VINVTRAN(x,y,th) transforms an angle in the projection space at
%  the point specified by x and y  into an azimuth angle in Greenwich
%  coordinates. The map projection currently displayed is used to 
%  define the projection space.  The input angles must be in the same 
%  units as specified by the current map projection.  The inputs can be 
%  scalars or matrices of the equal size. The angle in the projection space
%  angle th is defined positive counter-clockwise from the x axis.
%
%  az = VINVTRAN(struct,x,y,th) uses the map projection defined by the
%  input struct to compute the map projection.
% 
%  [az,len] = VINVTRAN(...) also returns the vector length in the 
%  Greenwich coordinate system. A value of 1 indicates no scale distortion
%  for that angle.
%
%  This transformation is limited to the region specified by
%  the frame limits in the current map definition.
%
%  See also VFWDTRAN, MFWDTRAN, MINVTRAN, DEFAULTM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, W. Stumpf
%   $Revision: 1.1.6.1 $    $Date: 2003/12/13 02:57:30 $



%  Parse inputs

if nargin == 3 & ~isstruct(varargin{1})
	  mstruct = [];
      x   = varargin{1};
	  y   = varargin{2};
	  th    = varargin{3};
elseif nargin == 4 & isstruct(varargin{1})
	  mstruct = varargin{1};
      x   = varargin{2};
	  y   = varargin{3};
	  th    = varargin{4};
else
   error('Incorrect number of arguments')	  
end

%  Initialize output

az = [];

if isempty(mstruct)
   [mstruct,msg] = gcm;
   if ~isempty(msg);   error(msg);   end
end

%  Check inputs

if ~isequal(size(x),size(y),size(th))
    error('x, y and theta inputs must be the same size')
end
if strcmp(mstruct.mapprojection,'globe')
    error('VINVTRAN does not work on globe projections')
end
		
   
epsilon = 100*epsm('degrees');
units = mstruct.angleunits;

%  Transform x and y to lat and long

[lat,lon] = minvtran(mstruct,x,y);

%  Transform data to degrees

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

%  Check for points near the edge of the map

% Back away from the poles to avoid problems reckoning. Convergence of
% the meridians makes east-west movements cross the dateline in longitude, 
% even if we back away by a couple of meters.

latlim = 89.9;dlat = 90-latlim;

indx = find(LatRot <= -latlim);
if ~isempty(indx);    LatRot(indx) = LatRot(indx)+dlat;   end   
indx = find(LatRot >= latlim);
if ~isempty(indx);    LatRot(indx) = LatRot(indx)-dlat;   end   

% Back away from the edges

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

%  Transform input data to the projection space

[x,y] = mfwdtran(mstruct,LatNew,LonNew);

%  Compute a new point off the starting point

rng = 7E-2*abs(x);
rng(rng==0) = 1000000*epsm('radians');
th = angledim(th,units,'radians');

x2 = x + rng .* cos(th);
y2 = y + rng .* sin(th);

%  Compute the second point in Greenwich coordinates

[Lat2,Lon2] = minvtran(mstruct,x2,y2);

%  Compute the azimuth

az = azimuth('rh',LatNew,LonNew,Lat2,Lon2,mstruct.geoid,'degrees');

%  Transform back to output units

az = angledim(az,'degrees',units);

%  Compute the length of the vector

if nargout == 2
	dist = distance('rh',LatNew,LonNew,Lat2,Lon2,mstruct.geoid,'degrees');
	len = dist ./  rng  ;

end


