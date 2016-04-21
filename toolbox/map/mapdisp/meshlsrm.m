function hout = meshlsrm(map,maplegend,s,rgbs,clim)

%MESHLSRM Project 3-D lighted shaded relief of a regular matrix map
%
%  MESHLSRM(map,maplegend) displays the regular matrix map colored according
%  to elevation and surface slopes.  By default, shading is based on a light
%  to the east (90 deg.) at an elevation of 45 degrees.  Also by default,
%  the colormap is constructed from 16 colors and 16 grays.  Lighting is
%  applied before the data is projected.  The current axes must have a valid
%  map projection definition.
%
%  MESHLSRM(map,maplegend,[azim elev]) displays the regular matrix map with
%  the light coming from the specified azimuth and elevation.  Angles are
%  specified in degrees, with the azimuth measured clockwise from North,
%  and elevation up from the zero plane of the surface.
%
%  MESHLSRM(map,maplegend,[azim elev],cmap) displays the regular matrix map
%  using the provided colormap.  The number of grayscales is chosen to keep
%  the size of the shaded colormap below 256.  If the vector of azimuth and
%  elevation is empty, the default locations are used.  Color axis limits are
%  computed from the data.
%
%  MESHLSRM(map,maplegend,[azim elev],cmap,clim) uses the provided caxis limits.
%
%  h = MESHLSRM(...) returns the handle to the surface drawn.
%
%
%  See also MESHLSRM, MESHM, SURFLM, SURFM, SURFACEM, PCOLORM, MESHGRAT


%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  A. Kim, W. Stumpf, E. Byrns
%  $Revision: 1.12.4.1 $  $Date: 2003/08/01 18:18:56 $


if nargin == 0;              meshlsrmui;  return
   elseif nargin == 2;       rgbs = [];   clim = [];    s = [];
   elseif nargin == 3;       rgbs = [];   clim = [];
   elseif nargin == 4;       clim = [];
   elseif nargin ~= 5;       error('Incorrect number of arguments')
end

%  Compute the graticule grid

if length(maplegend) ~= 3;  error('Incorrect map legend vector');  end
[lat,long] = meshgrat(map,maplegend);

%  Display the shaded relief map

[h,msg] = surflsrm(lat,long,map,s,rgbs,clim);
if ~isempty(msg);   error(msg);   end

%  Set the output argument if necessary

if nargout==1;     hout = h;     end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function meshlsrmui

%  MESHLSRMUI creates the dialog box to allow the user to enter in
%  the variable names for a MESHLSRM command.  It is called when
%  MESHLSRM is executed with no input arguments.


%  Define map for current axes if necessary.  Note that if the
%  user cancels this operation, the display dialog is aborted.

if ~ismap
     cancelflag = axesm;
     if cancelflag;   clma purge;  return;   end
end

%  Initialize the entries of the dialog box

str1 = 'map';           str2 = 'maplegend';
str3 = '[90 45]';       str4 = '';             str5 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = MeshlsrmUIBox(str1,str2,str3,str4,str5);  uiwait(h.fig)

    if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.mapedit,'String');    %  Get the dialog entries
		str2 = get(h.legedit,'String');
        str3 = get(h.azeledit,'String');
        str4 = get(h.cmapedit,'String');
		str5 = get(h.climedit,'String');
		delete(h.fig)

%  Construct the appropriate plotting string and assemble the callback string

        str3use = str3;    str4use = str4;    str5use = str5;

        if isempty(str3use);  str3use = '[]';  end
		if isempty(str4use);  str4use = '[]';  end
		if isempty(str5use);  str5use = '[]';  end

        plotstr = ['meshlsrm(',str1,',',str2,',',str3use,',',...
                                                 str4use,',',str5use,');'];

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

function h = MeshlsrmUIBox(map0,maplegend0,azel0,cmap0,clim0)

%  MESHLSRMUIBOX creates the dialog box and places the appropriate
%  objects for the MESHLSRMUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Shaded Relief Mesh Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[1.5 1 3.5 4], ...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');


%  Map Text and Edit Box

h.maplabel = uicontrol(h.fig,'Style','Text','String','Map variable:', ...
            'Units','Normalized','Position', [0.05  0.92  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.mapedit = uicontrol(h.fig,'Style','Edit','String', map0, ...
            'Units','Normalized','Position', [0.05  .84  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.maplist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .84  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.mapedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Maplegend Text and Edit Box

h.leglabel = uicontrol(h.fig,'Style','Text','String','Maplegend variable:', ...
            'Units','Normalized','Position', [0.05  0.76  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.legedit = uicontrol(h.fig,'Style','Edit','String', maplegend0, ...
            'Units','Normalized','Position', [0.05  .68  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.leglist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .68  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.legedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Azimuth/Elevation Text and Edit Box

h.azellabel = uicontrol(h.fig,'Style','Text','String','Light Source [az, el] (optional):', ...
            'Units','Normalized','Position', [0.05  0.60  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.azeledit = uicontrol(h.fig,'Style','Edit','String', azel0, ...
            'Units','Normalized','Position', [0.05  .52  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.azellist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .52  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.azeledit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Colormap Text and Edit Box

h.cmaplabel = uicontrol(h.fig,'Style','Text','String','Colormap (optional):', ...
            'Units','Normalized','Position', [0.05  0.44  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.cmapedit = uicontrol(h.fig,'Style','Edit','String', cmap0, ...
            'Units','Normalized','Position', [0.05  .36  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.cmaplist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .36  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.cmapedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Color Axis Limits Text and Edit Box

h.climlabel = uicontrol(h.fig,'Style','Text','String','Color Axis Limits (optional):', ...
            'Units','Normalized','Position', [0.05  0.28  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.climedit = uicontrol(h.fig,'Style','Edit','String', clim0, ...
            'Units','Normalized','Position', [0.05  .20  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',2,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.climlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .20  0.18  0.07], ...
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
			'CallBack','maphlp4(''initialize'',''meshlsrmui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)
