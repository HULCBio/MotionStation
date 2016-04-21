function daspectm(zunits,vfac,lat,lon,az,varargin)
%DASPECTM Set the figure DataAspectRatio property for a map. 
%
%   DASPECTM('zunits') sets the figure DataAspectRatio property so that the
%   z axis is in proportion to the x and y projected coordinates. This
%   permits elevation data to be displayed without vertical distortion. The
%   string 'zunits' specifies the units of the elevation data, and can be
%   any string recognized by DISTDIM.
%
%   DASPECTM('zunits',vfac) sets the DataAspectRatio property so that the z
%   axis is vertically exaggerated by the factor vfac. If omitted, the
%   default is no vertical exaggeration.
%   
%   DASPECTM('zunits',vfac,lat,long) sets the aspect ratio based  on the
%   local map scale at the specified geographic location.  If omitted, the
%   default is the center of the map limits.
%
%   DASPECTM('zunits',vfac,lat,long,az) also specifies the direction  along
%   which the scale is computed. If omitted, 90 degrees (west)  is assumed.
%
%   DASPECTM('zunits',vfac,lat,long,az,radius)  uses the last input to
%   determine the radius of the sphere.  If radius is  a string, then it is
%   evaluated as an ALMANAC body to determine the  spherical radius.  If
%   numerical, it is the radius of the desired sphere  in zunits. If
%   omitted, the default radius of the Earth is used.
%
%   See also  DASPECT, PAPERSCALE

%   Copyright 1996-2003 The MathWorks, Inc. 
%   Written by: W. Stumpf, A. Kim, T. Debole

if nargin < 1 || nargin > 7 || nargin == 3
   eid = sprintf('%s:%s:tooManyInputs', getcomp, mfilename);
   error(eid,'%s','Incorrect number of inputs.')
end

% Support old syntax:
%  daspectm(zunits,vfac,lat,lon,az,angleunits,radius)
if nargin == 6

   % radius or unit
   if ischar(varargin{1})
      strlist = {'earth','mercury','venus','moon', ...
                 'mars','jupiter','saturn','uranus', ...
                 'neptune','pluto','sun'};
      indx = strmatch(varargin{1},strlist);
      if ~isempty(indx) && (numel(indx) == 1)
         radius = strlist{indx};
      else
         radius = 'earth';
      end

    else
       radius = varargin{1};
    end

elseif nargin == 7
   radius = varargin{2};
else
   radius = 'earth'; 
end

% fill in values of optional arguments
if nargin < 5 
   az = 90;
end
if nargin < 4;     
   lat = mean(getm(gca,'mapLatLim'));
   lon = mean(getm(gca,'mapLonLim'));
   angleunits = getm(gca,'angleunits');
   lat = angledim(lat,angleunits,'deg');
   lon = angledim(lon,angleunits,'deg');
end
if nargin < 2
   vfac = 1;
end

% check for globe
if strmatch(getm(gca,'mapprojection'),'globe')
   eid = sprintf('%s:%s:invalidAspectRatio', getcomp, mfilename);
   error(eid,'%s','Aspect ratio changes not appropriate for Globe')
end	


% Cartesian coordinates of starting point
[xo,yo] = mfwdtran(lat,lon); 

% Geographical and paper coordinates of a point downrange
sdistdeg = distdim(1,zunits,'deg',radius);

[nlat,nlon] = reckon(lat,lon,sdistdeg,az);
[xn,yn] = mfwdtran(nlat,nlon); % cartesian coordinates

% Distance between two points in cartesian coordinats
cdist = sqrt((xo-xn)^2+(yo-yn)^2);

% Set the DataAspectRatio
zratio = 1/(cdist*vfac);
dataspectratios = [1 1 zratio];
set(gca,'DataAspectRatio',dataspectratios)	% set dataaspectratio


