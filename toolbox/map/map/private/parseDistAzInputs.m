function [useGeodesic, lat1, lon1, lat2, lon2, ellipsoid, ...
    units, insize, useAngularDistance] = parseDistAzInputs(varargin)

%   Adapted from procedures originally replicated in DISTANCE and AZIMUTH.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/19 01:13:42 $

% Handle optional first input argument
if (nargin >= 1) && ischar(varargin{1})
    trackstr = varargin{1};
    varargin(1) = [];
else
    trackstr = 'gc';
end

% Check TRACKSTR
switch(lower(trackstr))
    case {'g','gc'}
        useGeodesic = true;
    case {'r','rh'}
        useGeodesic = false;
    otherwise
        error('Unrecognized track string')
end

% Check argument counting after stripping off first argument
n = numel(varargin);
error(nargchk(2,6,n))
 
in1 = varargin{1};
in2 = varargin{2};

if (n > 2)
    in3 = varargin{3};
end
if (n > 3)
    in4  = varargin{4};
end
if (n > 4)
    in5  = varargin{5};
end
if (n > 5)
    in6  = varargin{6};
end

lat1 = [];
lon1 = [];
lat2 = [];
lon2 = [];
ellipsoid = [];
units = 'degrees';
useAngularDistance = false;

if (n == 2) || (n == 3) || ((n == 4) && ischar(in4))
    if size(in1,2) == 2 && ndims(in1) == 2 && ...
	   size(in2,2) == 2 && ndims(in2) == 2
        lat1 = in1(:,1);
        lon1 = in1(:,2);
        lat2 = in2(:,1);
        lon2 = in2(:,2);
	else
        error('Incorrect latitude and longitude data matrices');
	end

    if (n == 3)
	    if ischar(in3)
	        units  = in3;
	    else
            ellipsoid = in3;
        end
    end

    if (n == 4)
	    ellipsoid = in3;
	    units     = in4;
	end

else % (n == 4) || (n == 5) || (n == 6)

    lat1 = in1;
    lon1 = in2;
    lat2 = in3;
    lon2 = in4;
    
    if (n == 5)
	    if ischar(in5)
	        units = in5;
	    else
            ellipsoid = in5;
        end
    end
    
    if (n == 6)
	    ellipsoid = in5;
	    units     = in6;
    end
end

% If ELLIPSOID was omitted, use a unit sphere and express
% distance as an angle
if isempty(ellipsoid)
    ellipsoid = [1 0];
    useAngularDistance = true;
end

% Check for matching dimensions
if ~isequal(size(lat1),size(lon1),size(lat2),size(lon2))
    error('Inconsistent dimensions for latitude and longitude');
end

% Make sure angles are in radians and convert the
% input coordinates to column vectors
insize = size(lat1);
lat1 = angledim(lat1(:),units,'radians');
lon1 = angledim(lon1(:),units,'radians');
lat2 = angledim(lat2(:),units,'radians');
lon2 = angledim(lon2(:),units,'radians');

%  Check the ellipsoid
if ellipsoid(1) <= 0
    % Ensure a nonzero semimajor axis (note: should be an error)
    % warning('Semimajor axis of ELLIPSOID must be positive, reset to 1.');
    ellipsoid(1) = 1;
end
[ellipsoid,msg] = geoidtst(ellipsoid);
error(msg)
