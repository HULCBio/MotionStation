function varargout = checklatlon(varargin)
%CHECKLATLON Check validity of latitude and longitude vectors.
%   CHECKLATLON(LAT, LON, FUNCTION_NAME, LAT_VAR_NAME, LON_VAR_NAME,
%   LAT_ARG_POS, LON_ARG_POS) ensures that LAT and LON are real,
%   double-valued vectors of matching size.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2003/12/13 02:52:27 $

% Input arguments are not checked for validity.

fcn = @do_checklatlon;

[varargout, needRethrow] = ...
    checkfunction(fcn, nargout, varargin{:});

if needRethrow
   rethrow(lasterror);    
end

%----------------------------------------------------------------------

function do_checklatlon(component, lat, lon,...
    function_name, lat_var_name, lon_var_name, lat_pos, lon_pos)

checkinput(lat,{'double'},{'real','2d'},function_name,lat_var_name,lat_pos);
checkinput(lon,{'double'},{'real','2d'},function_name,lon_var_name,lon_pos);

if ~isequal(size(lat),size(lon))
    eid = sprintf('%s:%s:latlonSizeMismatch',component,function_name);
    msg1 = sprintf('Function %s expected its %s and %s input arguments,', ...
             upper(function_name), num2ordinal(lat_pos), num2ordinal(lon_pos));
    msg2 = sprintf('%s and %s, to match in size.', lat_var_name, lon_var_name);
    throwerr(eid, '%s\n%s', msg1, msg2);
end
