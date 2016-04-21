function [r,c,refvec] = sizem(latlim,lonlim,scale)

%SIZEM  Row and column dimensions needed for a regular data grid.
%
%   [R,C] = SIZEM(LATLIM,LONLIM,SCALE) computes the row and column
%   dimensions needed for a regular data grid aligned with geographic
%   coordinates.  LATLIM and LONLIM are two-element vectors defining the
%   latitude and longitude limits in degrees. SCALE is a scalar specifying
%   the number of data samples per unit of latitude and longitude (e.g. 10
%   entries per degree).
%
%   SZ = SIZEM(...) returns a single output, where SZ = [R C].
%
%   [R,C,REFVEC] = SIZEM(...) returns the referencing vector for the data
%   grid.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.2 $    $Date: 2004/02/01 21:58:15 $

if nargin ~= 3;  error('Incorrect number of arguments');  end

%  Argument tests

if ~isequal(sort(size(latlim)),sort(size(lonlim)),[1 2])
    error('Lat and long limits must be 2 element vectors')

elseif max(size(scale)) ~= 1
    error('Scale input must be scalar')

elseif any([~isreal(latlim) ~isreal(lonlim) ~isreal(scale)])
    warning('Imaginary parts of complex arguments ignored')
	latlim = real(latlim);    lonlim = real(lonlim);    scale = real(scale);
end


%  Determine the starting and ending latitude and longitude

startlat = min(latlim);
endlat   = max(latlim);
startlon = lonlim(1);
endlon   = lonlim(2);
if endlon < startlon
    endlon = endlon + 360;
end

%  Compute the number of rows and columns needed

rows = ceil((endlat - startlat)*scale);
cols = ceil((endlon - startlon)*scale);

%  Set the output arguments

if nargout == 1
    r = [rows cols];

elseif nargout == 2
    r = rows;   c = cols;

elseif nargout == 3
    r = rows;   c = cols;  refvec = [scale endlat startlon];

end
