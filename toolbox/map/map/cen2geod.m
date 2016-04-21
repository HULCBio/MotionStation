function latout = cen2geod(varargin)
%CEN2GEOD  Convert geocentric latitude to geodetic latitude.
%   CEN2GEOD is obsolete; use CONVERTLAT.
%
%   lat = CEN2GEOD(lat0) converts from the geocentric latitude to the
%   geodetic latitude, using the default Earth ellipsoid from ALMANAC.
%
%   lat = CEN2GEOD(lat0,ELLIPSOID) uses the ellipsoid definition given in
%   the input vector ellipsoid.  ELLIPSOID can be determined from the ALMANAC
%   function.
%
%   lat = CEN2GEOD(lat0,'units') uses the units defined by the input string
%   'units'.  If omitted, default units of degrees are assumed.
%
%   lat = CEN2GEOD(lat0,ELLIPSOID,'units') uses the ellipsoid and 'units'
%   definitions provided by the corresponding inputs.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2003/08/01 18:15:27 $

% warnobsolete(mfilename,'convertlat');
latout = doLatitudeConversion(mfilename,'geocentric','geodetic',varargin{:});
