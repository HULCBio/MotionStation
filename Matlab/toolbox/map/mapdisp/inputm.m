function [out1, out2] = inputm(npts,hndl)

%INPUTM  Return mouse click positions from displayed map
%
%  [lat,lon] = INPUTM returns the latitudes and longitudes in Greenwich
%  frame of points selected by mouse clicks on a displayed map.
%  The point selection continues until the return key is pressed.
%
%  [lat,lon] = INPUTM(n) returns n points specified by mouse clicks.
%
%  [lat,lon] = INPUTM(n,h) prompts for points from the map axes specified
%  by the handle h.  If omitted, the current axes (gca) is assumed.
%
%  mat = INPUTM(...) returns a single matrix, where mat = [lat lon].
%
%  See also GINPUT

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.1 $
%  Written by:  E. Byrns, E. Brown



if nargin == 0;                    npts = [];      hndl = [];
   elseif nargin == 1;            hndl = [];
end

if isempty(hndl)
    hndl = get(get(0,'CurrentFigure'),'CurrentAxes');
    if isempty(hndl);  error('No axes in current figure');  end
end

%  Ensure that handle object is an axes.

[mflag,msg] = ismap(hndl);
if ~mflag;  error(msg);   end
axes(hndl)

%  Test if a window down function needs to be toggled off to
%  allow user to click on display without existing button
%  down function execute.

fighndl   = get(hndl,'Parent');
windowfcn = get(fighndl, 'WindowButtonDownFcn');
set(fighndl,'WindowButtonDownFcn','')

%  Test for 2D view.  Does not work on 3D views.

if any(get(gca,'view') ~= [0 90])
    btn = questdlg( strvcat('Must be in 2D view for operation.',...
	                        'Change to 2D view?'),...
				    'Incorrect View','Change','Cancel','Change');

    switch btn
	    case 'Change',      view(2);
		case 'Cancel',      out1 = [];  out2 = [];  return
    end
end

%  Select a points on the map

if isempty(npts);     [x,y] = ginput;
    else;             [x,y] = ginput(npts);
end

%  Compute the inverse transformation for the selected projection
%  Use text as an object to represent a point calculation

[lat,long] = minvtran(x,y,[]);

%  Reset window down function if necessary

set(fighndl,'WindowButtonDownFcn',windowfcn);

%  Set output arguments

if nargout ~= 2;     out1 = [lat long];
     else;           out1 = lat;   out2 = long;
end
