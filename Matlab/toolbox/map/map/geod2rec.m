function latout = geod2rec(varargin)
%GEOD2REC  Convert geodetic latitude to rectifying latitude.
%   GEOD2REC is obsolete; use CONVERTLAT.
%
%   lat = GEOD2REC(lat0) converts from the geodetic latitude to the
%   rectifying latitude, using the default Earth ellipsoid from ALMANAC.
%
%   lat = GEOD2REC(lat0,ELLIPSOID) uses the ellipsoid definition given in
%   the input vector ellipsoid.  ELLIPSOID can be determined from the
%   ALMANAC function.
%
%   lat = GEOD2REC(lat0,'units') uses the units defined by the input string
%   'units'.  If omitted, default units of degrees are assumed.
%
%   lat = GEOD2REC(lat0,ELLIPSOID,'units') uses the ellipsoid and 'units'
%   definitions provided by the corresponding inputs.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.11.4.1 $  $Date: 2003/08/01 18:16:25 $

% warnobsolete(mfilename,'convertlat');
latout = doLatitudeConversion(mfilename,'geodetic','rectifying',varargin{:});
