function latout = rec2geod(varargin)
%REC2GEOD  Convert rectifying latitude to geodetic latitude.
%   REC2GEOD is obsolete; use CONVERTLAT.
%
%   lat = REC2GEOD(lat0) converts from the rectifying latitude to the
%   geodetic latitude, using the default Earth ellipsoid from ALMANAC.
%
%   lat = REC2GEOD(lat0,ELLIPSOID) uses the ellipsoid definition given in
%   the input vector ellipsoid.  ELLIPSOID can be determined from the
%   ALMANAC function.
%
%   lat = REC2GEOD(lat0,'units') uses the units defined by the input string
%   'units'.  If omitted, default units of degrees are assumed.
%
%   lat = REC2GEOD(lat0,ELLIPSOID,'units') uses the ellipsoid and 'units'
%   definitions provided by the corresponding inputs.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2003/08/01 18:19:56 $

% warnobsolete(mfilename,'convertlat');
latout = doLatitudeConversion(mfilename,'rectifying','geodetic',varargin{:});
