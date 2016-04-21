function [hout,msg] = surflsrm(lat,long,map,s,rgbs,clim)

%SURFLSRM Project 3-D lighted shaded relief of a general matrix map
%
%  SURFLSRM(lat,long,map) displays the general matrix map colored according
%  to elevation and surface slopes.  By default, shading is based on a light
%  to the east (90 deg.)  at an elevation of 45 degrees.  Also by default,
%  the colormap is constructed from 16 colors and 16 grays.  Lighting is
%  applied before the data is projected.  The current axes must have a valid
%  map projection definition.
%
%  SURFLSRM(lat,long,map,[azim elev]) displays the general matrix map with
%  the light coming from the specified azimuth and elevation.  Angles are
%  specified in degrees, with the azimuth measured clockwise from North,
%  and elevation up from the zero plane of the surface.
%
%  SURFLSRM(lat,long,map,[azim elev],cmap) displays the general matrix map
%  using the provided colormap.  The number of grayscales is chosen to keep
%  the size of the shaded colormap below 256. If the vector of azimuth and
%  elevation is empty, the default locations are used. Color axis limits are
%  computed from the data.
%
%  SURFLSRM(lat,long,map,[azim elev],cmap,clim) uses the provided caxis limits.
%
%  h = SURFLSRM(...) returns the handle to the surface drawn.
%
%
%  See also MESHLSRM, SHADEREL, MESHM, SURFLM, SURFM, SURFACEM, PCOLORM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  A. Kim, W. Stumpf
%  $Revision: 1.12.4.1 $  $Date: 2003/08/01 18:22:53 $

%  Initialize outputs

if nargout ~= 0;  hout = [];   msg = [];   end

%  Input argument tests

if nargin == 0;         surflsrmui;    return
    elseif nargin==3;   rgbs = [];     clim = [];    s = [];
    elseif nargin==4;   rgbs = [];     clim = [];
    elseif nargin==5;   clim = [];
    elseif nargin<=2;   error('Incorrect number of arguments')
end

%  Input dimension tests

if any([ndims(lat) ndims(long) ndims(map)] > 2)
    msg = 'Input lat, long and map matrices must not contain any pages';
    if nargout < 2;  error(msg);   end
	return
elseif ~isequal(size(lat),size(long),size(map))
    msg = 'Inconsistent dimensions on input lat, lon and map matrices';
    if nargout < 2;  error(msg);   end
	return
end

%  Get the current map structure

[mstruct,msg] = gcm;
if ~isempty(msg)
    if nargout < 2;  error(msg);   end
	return
end

%  Set the light source azimuth and elevation

if ~isempty(s) & length(s) ~= 2
   msg = 'Light source vector must consist of azimuth and elevation';
   if nargout < 2;  error(msg);   end
	return
end

%  Set the color axis limits

if isempty(clim)
   clim = [min(map(:))   max(map(:))];
elseif length(clim) ~= 2
   msg = 'Color limits must be a two element vector';
   if nargout < 2;  error(msg);   end
	return
end

%  Build shaded relief colormap

if isempty(rgbs);	[rgbs,clim] = demcmap(map);   end

%	[rgbs,clim] = demcmap(map,16,[],...
%	              [hsv2rgb([5/12 1 0.4; 0.25 0.2 1; 5/72 1 0.4]); 1 1 1]);
%end % if

[rgbindx,rgbmap,clim] = shaderel(long,lat,map,rgbs,s,[],clim);

%  Display shaded relief map

[h,msg] = surfacem(lat,long,rgbindx,map); colormap(rgbmap)
if ~isempty(msg)
    if nargout < 2;  error(msg);   end
	return
end
caxis(clim)

%  Set handle return argument if necessary

if nargout ~= 0;   hout = h;   end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function surflsrmui

%  SURFLSRMUI creates the dialog box to allow the user to enter in
%  the variable names for a SURFLSRM command.  It is called when
%  SURFLSRM is executed with no input arguments.


%  Define map for current axes if necessary.  Note that if the
%  user cancels this operation, the display dialog is aborted.

if ~ismap
     cancelflag = axesm;
     if cancelflag;   clma purge;  return;   end
end

%  Initialize the entries of the dialog box

str1 = 'lat';           str2 = 'lon';          str3 = 'map';
str4 = '';              str5 = '';             str6 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = SurflsrmUIBox(str1,str2,str3,str4,str5,str6);  uiwait(h.fig)

    if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
		str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.mapedit,'String');
        str4 = get(h.azeledit,'String');
        str5 = get(h.cmapedit,'String');
		str6 = get(h.climedit,'String');
		delete(h.fig)

%  Construct the appropriate plotting string and assemble the callback string

        str4use = str4;    str5use = str5;    str6use = str6;

        if isempty(str4use);  str4use = '[]';  end
		if isempty(str5use);  str5use = '[]';  end
		if isempty(str6use);  str6use = '[]';  end

        plotstr = ['surflsrm(',str1,',',str2,',',str3,',',...
                    str4use,',',str5use,',',str6use,');']

	    evalin('base',plotstr,...
		        'uiwait(errordlg(lasterr,''Map Projection Error'',''modal''))')
		if isempty(lasterr);   break;   end  %  Break loop with no errors
   else
        delete(h.fig)     %  Close the modal dialog box
		break             %  Exit the loop
   end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************

function h = SurflsrmUIBox(lat0,lon0,map0,azel0,cmap0,clim0)

%  SURFLSRMUIBOX creates the dialog box and places the appropriate
%  objects for the SURFLSRMUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Shaded Relief Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[1.5 1 3.5 4.5], ...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');


%  Latitude Text and Edit Box

h.latlabel = uicontrol(h.fig,'Style','Text','String','Latitude variable:', ...
            'Units','Normalized','Position', [0.05  0.92  0.90  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latedit = uicontrol(h.fig,'Style','Edit','String', lat0, ...
            'Units','Normalized','Position', [0.05  .85  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .85  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.latedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Longitude Text and Edit Box

h.lonlabel = uicontrol(h.fig,'Style','Text','String','Longitude variable:', ...
            'Units','Normalized','Position', [0.05  0.79  0.90  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonedit = uicontrol(h.fig,'Style','Edit','String', lon0, ...
            'Units','Normalized','Position', [0.05  .72  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .72  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lonedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Map Text and Edit Box

h.maplabel = uicontrol(h.fig,'Style','Text','String','Map variable:', ...
            'Units','Normalized','Position', [0.05  0.66  0.91  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.mapedit = uicontrol(h.fig,'Style','Edit','String', map0, ...
            'Units','Normalized','Position', [0.05  .59  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.maplist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .59  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.mapedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Azimuth/Elevation Text and Edit Box

h.azellabel = uicontrol(h.fig,'Style','Text','String','Light Souce [az, el] (optional):', ...
            'Units','Normalized','Position', [0.05  0.53  0.90  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.azeledit = uicontrol(h.fig,'Style','Edit','String', azel0, ...
            'Units','Normalized','Position', [0.05  .46  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.azellist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .46  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.azeledit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Colormap Text and Edit Box

h.cmaplabel = uicontrol(h.fig,'Style','Text','String','Colormap (optional):', ...
            'Units','Normalized','Position', [0.05  0.40  0.90  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.cmapedit = uicontrol(h.fig,'Style','Edit','String', cmap0, ...
            'Units','Normalized','Position', [0.05  .33  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.cmaplist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .33  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.cmapedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Color Axis Limits Text and Edit Box

h.climlabel = uicontrol(h.fig,'Style','Text','String','Color Axis Limits (optional):', ...
            'Units','Normalized','Position', [0.05  0.27  0.90  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.climedit = uicontrol(h.fig,'Style','Edit','String', clim0, ...
            'Units','Normalized','Position', [0.05  .20  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',2,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.climlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .20  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.climedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Buttons to exit the modal dialog

h.apply = uicontrol(h.fig,'Style','Push','String', 'Apply', ...
	        'Units', 'Normalized','Position', [0.06  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'center',...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','uiresume');

h.help = uicontrol(h.fig,'Style','Push','String', 'Help', ...
	        'Units', 'Normalized','Position', [0.37  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'center', 'Interruptible','on',...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','maphlp4(''initialize'',''surflsrmui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)
