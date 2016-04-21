function hndl = fillm(varargin)

%FILLM  Project 2D patch objects onto the current map axes
%
%  FILLM(lat,lon,cdata) projects 2D patch objects onto the current
%  map axes.  The input latitude and longitude data must be in the same
%  units as specified in the current map axes.  The input cdata defines
%  the patch face color.  If the input vectors are NaN clipped, then
%  a single patch is drawn with multiple faces.  FILLM will clear the
%  current map if the hold state is off.
%
%  FILLM(lat,lon,'PropertyName',PropertyValue,...) uses the patch
%  properties supplied to display the patch.  Except for xdata, ydata
%  and zdata, all patch properties available through FILL are supported
%  by FILLM.
%
%  h = FILLM(...) returns the handles to the patch objects drawn.
%
%  FILLM, without any inputs, activates a GUI for projecting patches
%  onto the current axes.
%
%  See also FILL3M, FILL, PATCHM, PATCH

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:18:22 $


if nargin == 0
	patchm;  return
elseif nargin < 3
    error('Incorrect number of arguments')
else
	lat = varargin{1};  lon = varargin{2};   varargin(1:2) = [];
end

%  Display the map

nextmap;
[hndl0,msg] = patchm(lat,lon,varargin{:});
if ~isempty(msg);  error(msg);  end

%  Set handle return argument if necessary

if nargout == 1;   hndl = hndl0;   end
