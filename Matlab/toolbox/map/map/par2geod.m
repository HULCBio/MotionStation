function latout = par2geod(varargin)
%PAR2GEOD  Convert parametric latitude to geodetic latitude.
%   PAR2GEOD is obsolete; use CONVERTLAT.
%
%   lat = PAR2GEOD(lat0) converts from the parametric latitude to the
%   geodetic latitude, using the default Earth ellipsoid from ALMANAC.
%
%   lat = PAR2GEOD(lat0,ELLIPSOID) uses the ellipsoid definition given in
%   the input vector ellipsoid.  ELLIPSOID can be determined from the
%   ALMANAC function.
%
%   lat = PAR2GEOD(lat0,'units') uses the units defined by the input string
%   'units'.  If omitted, default units of degrees are assumed.
%
%   lat = PAR2GEOD(lat0,ELLIPSOID,'units') uses the ellipsoid and 'units'
%   definitions provided by the corresponding inputs.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2003/08/01 18:17:30 $

% warnobsolete(mfilename,'convertlat');
latout = doLatitudeConversion(mfilename,'parametric','geodetic',varargin{:});
