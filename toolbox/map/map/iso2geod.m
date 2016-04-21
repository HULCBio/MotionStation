function latout = iso2geod(varargin)
%ISO2GEOD  Convert isometric latitude to geodetic latitude.
%   ISO2GEOD is obsolete; use CONVERTLAT.
%
%   lat = ISO2GEOD(lat0) computes the geodetic latitude given the isometric
%   latitude, using the default Earth ellipsoid from ALMANAC.
%
%   lat = ISO2GEOD(lat0,ELLIPSOID) uses the ellipsoid definition given in
%   the input vector ellipsoid.  ELLIPSOID can be determined from the
%   ALMANAC function.
%
%   lat = ISO2GEOD(lat0,'units') uses the units defined by the input string
%   'units'.  If omitted, default units of degrees are assumed.
%
%   lat = ISO2GEOD(lat0,ELLIPSOID,'units') uses the ellipsoid and 'units'
%   definitions provided by the corresponding inputs.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2003/08/01 18:16:45 $

% warnobsolete(mfilename,'convertlat');
latout = doLatitudeConversion(mfilename,'isometric','geodetic',varargin{:});
