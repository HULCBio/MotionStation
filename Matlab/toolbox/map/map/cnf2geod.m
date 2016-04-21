function latout = cnf2geod(varargin)
%CNF2GEOD  Convert conformal latitude to geodetic latitude.
%   CNF2GEOD is obsolete; use CONVERTLAT.
%
%   lat = CNF2GEOD(lat0) converts from the conformal latitude to the
%   geodetic latitude, using the default Earth ellipsoid from ALMANAC.
%
%   lat = CNF2GEOD(lat0,ELLIPSOID) uses the ellipsoid definition given in
%   the input vector ellipsoid.  ELLIPSOID can be determined from the
%   ALMANAC function.
%
%   lat = CNF2GEOD(lat0,'units') uses the units defined by the input string
%   'units'.  If omitted, default units of degrees are assumed.
%
%   lat = CNF2GEOD(lat0,ELLIPSOID,'units') uses the ellipsoid and 'units'
%   definitions provided by the corresponding inputs.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2003/08/01 18:15:38 $

% warnobsolete(mfilename,'convertlat');
latout = doLatitudeConversion(mfilename,'conformal','geodetic',varargin{:});
