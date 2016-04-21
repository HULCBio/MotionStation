function latout = geod2par(varargin)
%GEOD2PAR  Convert geodetic latitude to parametric latitude.
%   GEOD2PAR is obsolete; use CONVERTLAT.
%
%   lat = GEOD2PAR(lat0) converts from the geodetic latitude to the
%   parametric latitude, using the default Earth ellipsoid from ALMANAC.
%
%   lat = GEOD2PAR(lat0,ELLIPSOID) uses the ellipsoid definition given in
%   the input vector ellipsoid.  ELLIPSOID can be determined from the
%   ALMANAC function.
%
%   lat = GEOD2PAR(lat0,'units') uses the units defined by the input string
%   'units'.  If omitted, default units of degrees are assumed.
%
%   lat = GEOD2PAR(lat0,ELLIPSOID,'units') uses the ellipsoid and 'units'
%   definitions provided by the corresponding inputs.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2003/08/01 18:16:24 $

% warnobsolete(mfilename,'convertlat');
latout = doLatitudeConversion(mfilename,'geodetic','parametric',varargin{:});
