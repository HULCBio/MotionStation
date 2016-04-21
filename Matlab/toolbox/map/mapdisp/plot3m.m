function hndl = plot3m(varargin)

%PLOT3M  Project 3D line objects onto the current map axes
%
%  PLOT3M(lat,lon,z) projects 3D line objects onto the current
%  map axes.  The input latitude and longitude data must be in
%  the same units as specified in the current map axes.
%  PLOT3M will clear the current map if the hold state is off.
%
%  PLOT3M(lat,lon,z,'LineSpec') uses any valid LineSpec string to
%  display the line object.
%
%  PLOT3M(lat,lon,z,'PropertyName',PropertyValue,...) uses
%  the line object properties specified to display the line
%  objects.  Except for xdata, ydata and zdata, all line properties,
%  and styles available through PLOT3 are supported by PLOT3M.
%
%  h = PLOT3M(...) returns the handles to the line objects displayed.
%
%  PLOT3M, without any inputs, will activate a GUI to project line
%  objects onto the current map axes.
%
%  See also PLOTM, PLOT3, LINEM, LINE

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:19:15 $


if nargin == 0
      linem;   return
elseif nargin < 3
      error('Incorrect number of arguments')
end

%  Display the map

nextmap;
[hndl0,msg] = linem(varargin{:});
if ~isempty(msg);  error(msg);  end

%  Set handle return argument if necessary

if nargout == 1;    hndl = hndl0;   end
