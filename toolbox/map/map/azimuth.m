function az = azimuth(varargin)

%AZIMUTH  Azimuth between points on a sphere/ellipsoid.
%
%   AZ = AZIMUTH(LAT1,LON1,LAT2,LON2) computes the great circle bearing AZ,
%   the azimuth from point 1 to point 2, for pairs of points on the surface
%   of a sphere.  The input latitudes and longitudes, LAT1, LON1, LAT2,
%   LON2, can be scalars or arrays of matching size.  Azimuths are
%   expressed in degrees clockwise from north, ranging from 0 to 360.
%
%   AZ = AZIMUTH(LAT1,LON1,LAT2,LON2,ELLIPSOID) computes the azimuth(s)
%   assuming that the points lie on the ellipsoid defined by the input
%   ELLIPSOID.  The ellipsoid vector is of the form [semimajor axis,
%   eccentricity].
%
%   AZ = AZIMUTH(LAT1,LON1,LAT2,LON2,UNITS) uses the input string UNITS to
%   define the angle units used for AZ and the latitude-longitude
%   coordinates.  UNITS may equal 'degrees' (the default value) or
%   'radians'.  Azimuths range from 0 to 2*pi when 'radians' are specified.
%
%   AZ = AZIMUTH(LAT1,LON1,LAT2,LON2,ELLIPSOID,UNITS) specify both an
%   ellipsoid vector and the units of AZ and the latitude-longitude
%   coordinates. 
%   
%   AZ = AZIMUTH(TRACK,...) uses the input string TRACK to specify either
%   a great circle/geodesic or a rhumb line azimuth calculation.  If TRACK
%   equals 'gc' (the default value), then great circle azimuths are
%   computed on a sphere and geodesic azimuths are computed on an
%   ellipsoid. If TRACK equals 'rh', then rhumb line azimuths are computed
%   on either a sphere or ellipsoid.
%
%   AZ = AZIMUTH(PT1,PT2) accepts N-by-2 coordinate arrays PT1 and PT2
%   such that PT1 = [LAT1 LON1] and PT2 = [LAT2 LON2] where LAT1, LON1,
%   LAT2, and LON2 are column vectors.  It is equivalent to
%   AZ = AZIMUTH(PT1(:,1),PT1(:,2),PT2(:,1),PT2(:,2)).
%
%   AZ = AZIMUTH(PT1,PT2,ELLIPSOID)
%   AZ = AZIMUTH(PT1,PT2,UNITS),
%   AZ = AZIMUTH(PT1,PT2,ELLIPSOID,UNITS) and
%   AZ = AZIMUTH(TRACK,PT1,...) are all valid calling forms.
%
%   Remark on Eccentricity
%   ----------------------
%   Geodesic azimuths on an ellipsoid are valid only for small
%   eccentricities typical of the Earth (e.g., 0.08 or less).
%
%   Remark on Long Geodesics
%   ------------------------
%   The azimuth calculated for a geodesic on an ellipsoid degrades slowly
%   with increasing distance and may break down for points that are nearly
%   antipodal, and/or when both points are very close to the equator.
%
%   See also DISTANCE, RECKON.

%   Copyright 1996-2004 The MathWorks, Inc.
%   $Revision: 1.9.4.3 $  $Date: 2004/04/19 01:13:32 $

[dist, az] = distance(varargin{:});
