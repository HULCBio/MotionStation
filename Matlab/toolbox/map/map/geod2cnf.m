function latout = geod2cnf(varargin)
%GEOD2CNF  Convert geodetic latitude to conformal latitude.
%   GEOD2CNF is obsolete; use CONVERTLAT.
%
%   lat = GEOD2CNF(lat0) converts from the geodetic latitude to the
%   conformal latitude, using the default Earth ellipsoid from ALMANAC.
%
%   lat = GEOD2CNF(lat0,ELLIPSOID) uses the ellipsoid definition given in
%   the input vector ellipsoid.  ELLIPSOID can be determined from the
%   ALMANAC function.
%
%   lat = GEOD2CNF(lat0,'units') uses the units defined by the input string
%   'units'.  If omitted, default units of degrees are assumed.
%
%   lat = GEOD2CNF(lat0,ellipsoid,'units') uses the ellipsoid and 'units'
%   definitions provided by the corresponding inputs.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2003/08/01 18:16:22 $

% warnobsolete(mfilename,'convertlat');
latout = doLatitudeConversion(mfilename,'geodetic','conformal',varargin{:});
