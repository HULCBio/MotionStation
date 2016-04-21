function r = rcurve(str,geoid,lat,units)

%RCURVE  Computes various radii of curvature for an ellipsoid
%
%  r = RCURVE(geoid,lat) computes the parallel radius of curvature
%  for an ellipsoid.  The parallel radius of curvature is the radius
%  of the small circle encompassing the globe at the specified latitude.
%  The input geoid is a standard 2 element geoid vector.  The returned
%  radius r is in the units of the first element of a standard geoid vector.
%
%  r = RCURVE(geoid,lat,'units')  defines the 'units' of the input
%  latitude data.  If omitted, 'degrees' are assumed.
%
%  r = RCURVE('parallel',...) also computes the parallel radius of
%  curvature for the ellipsoid.
%
%  r = RCURVE('meridian',...) computes the meridianal radius of
%  curvature for the ellipsoid.  The meridianal radius is the
%  radius of curvature at the specified latitude for the ellipse
%  defined a meridian.
%
%  r = RCURVE('transverse',...) computes the transverse radius of
%  curvature for the ellipsoid.  The transverse radius is the radius
%  of the curve formed by a plane intersecting the ellipsoid at the
%  latitude which is normal to the surface of the ellipsoid.
%
%  See also:  RSPHERE

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.13.4.1 $    $Date: 2003/08/01 18:19:55 $

%  Reference: D. H. Maling, Coordinate Systems and Map Projections, 2nd Edition
%  Pergamon Press, 1992, p. 69.

if nargin < 2 | (nargin == 2 & isstr(str))
    error('Incorrect number of arguments')

elseif (nargin == 2 & ~isstr(str)) | (nargin == 3 & isstr(str))
    if ~isstr(str)       %  Shift inputs since str omitted by user
        lat = geoid;     geoid = str;     str = [];
	end

	units = [];

elseif nargin == 3 & ~isstr(str)

    %  Shift inputs since str omitted by user
    units = lat;   lat = geoid;     geoid = str;     str = [];
end


%  Empty argument tests

if isempty(str)
     str   = 'parallel';
else
     strmat = strvcat('parallel','meridian','transverse');
     indx = strmatch(lower(str),strmat);
     if length(indx) == 1
	      str = deblank(strmat(indx,:));
	 else
	      error('Unrecognized curve string')
	end
end



%  Input tests

if isempty(units);    units = 'degrees';    end
[geoid,msg] = geoidtst(geoid);
if ~isempty(msg);   error(msg);   end

if  ndims(lat) > 2
   error('Latitude limited to 2 dimensions')
end

%  Get the semimajor axis and eccentricity

semimajor = geoid(1);
eccent    = geoid(2);

%  Transform the latitude into radians

lat = angledim(lat,units,'radians');


switch str
case 'parallel'                  %  Parallel radius of curvature

    num = 1-eccent^2;                        %  Compute the distance from
    den = 1 - (eccent * cos(lat)).^2;        %  the center of the geoid to
    rho = semimajor * sqrt(num ./ den);      %  the specified point

    r = rho .* cos(lat);

case 'meridian'                    %  Meridional radius of curvature

    num = semimajor * (1-eccent^2);
    den = 1 - (eccent * sin(lat)).^2;
	r   = num ./ sqrt(den.^3);

case 'transverse'                  %  Transverse radius of curvature

    den = 1 - (eccent * sin(lat)).^2;
	r   = semimajor ./ sqrt(den);

end
