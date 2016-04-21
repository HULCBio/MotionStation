function hndl = fill3m(varargin)

%FILL3M  Project 3D patch objects onto the current map axes
%
%  FILL3M(lat,lon,z,cdata) projects 3D patch objects onto the current
%  map axes.  The input latitude and longitude data must be in the same
%  units as specified in the current map axes.  The input cdata defines
%  the patch face color.  If the input vectors are NaN clipped, then
%  a single patch is drawn with multiple faces.  FILL3M will clear the
%  current map if the hold state is off.
%
%  FILLM(lat,lon,z,'PropertyName',PropertyValue,...) uses the patch
%  properties supplied to display the patch.  Except for xdata, ydata
%  and zdata, all patch properties available through FILL3 are supported
%  by FILL3M.
%
%  h = FILL3M(...) returns the handles to the patch objects drawn.
%
%  FILL3M, without any inputs, activates a GUI for projecting patches
%  onto the current axes.
%
%  See also FILLM, FILL, PATCHM, PATCH

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.9.4.1 $
%  Written by:  E. Byrns, E. Brown



if nargin == 0
	patchm;  return
elseif nargin < 4
    error('Incorrect number of arguments')
else
	lat = varargin{1};  lon = varargin{2};   z = varargin{3};
	varargin(1:3) = [];
end

%  Display the map

nextmap;
[hndl0,msg] = patchm(lat,lon,z,varargin{:});
if ~isempty(msg);  error(msg);  end

%  Set handle return argument if necessary

if nargout == 1;   hndl = hndl0;   end
