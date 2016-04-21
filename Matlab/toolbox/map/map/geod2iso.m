function latout = geod2iso(varargin)
%GEOD2ISO  Convert geodetic latitude to isometric latitude.
%   GEOD2ISO is obsolete; use CONVERTLAT.
%
%   lat = GEOD2ISO(lat0) computes the isometric latitude given the
%   geodetic latitude, using the default Earth ellipsoid from ALMANAC.
%
%   lat = GEOD2ISO(lat0,ELLIPSOID) uses the ellipsoid definition given in
%   the input vector ellipsoid.  ELLIPSOID can be determined from the ALMANAC
%   function.  If omitted, the default Earth ellipsoid is assumed.
%
%   lat = GEOD2ISO(lat0,'units') uses the units defined by the input string
%   'units'.  If omitted, default units of degrees are assumed.
%
%   lat = GEOD2ISO(lat0,ELLIPSOID,'units') uses the ellipsoid and 'units'
%   definitions provided by the corresponding inputs.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2003/08/01 18:16:23 $

% warnobsolete(mfilename,'convertlat');
latout = doLatitudeConversion(mfilename,'geodetic','isometric',varargin{:});
