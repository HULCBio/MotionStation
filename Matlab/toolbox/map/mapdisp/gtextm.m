function h=gtextm(varargin)

%GTEXTM  Place text on a 2-D map using a mouse
%
%  GTEXTM('string') positions the input string at the location
%  specified by a mouse click.  Unlike GTEXT, this text object is
%  projected on the map and will remain at the corresponding
%  Greenwich coordinates even if the map is reprojected.  If string
%  is a matrix, then each row of the matrix can be placed at different
%  locations.
%
%  GTEXTM('string','PropertyName',PropertyValue,...) uses the properties
%  specified to draw the text object.  Any text object property can
%  be supplied.
%
%  h = GTEXTM(...) returns the handles of the text objects placed on
%  the map.
%
%  See also TEXTM, INPUTM, GTEXT

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown



if nargin < 1
    error('Incorrect number of arguments')
else
    textstr = varargin{1};   varargin(1) = [];
end

%  Place the text on the map

hndl = gtext(textstr);

%  Set the map properties

userdata.clipped = [];
userdata.trimmed = [];
set(hndl,'ButtonDownFcn','uimaptbx','UserData',userdata);

%  Set any properties which were supplied

if ~isempty(varargin);    set(hndl,varargin{:});   end

%  Set handle return argument if necessary

if nargout == 1;    h = hndl;   end
