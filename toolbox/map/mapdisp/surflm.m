function hndl = surflm(varargin)

%SURFLM  Display a lighted matrix map warped to a projected graticule
%
%  SURFLM(lat,lon,map) is the same as SURFM(...) except that it
%  projects the surface with highlights from a light surface.
%  The light source is 45 degrees counterclockwise from the
%  current view direction.  The shading is based on a combination
%  of diffuse, specular and ambient lighting models.  The inputs
%  lat and lon must be in the angle units specified in the map
%  structure.
%
%  SURFLM(lat,lon,map,s) uses the input s to control the position
%  of the light source.  The input s is a three element vector,
%  s = [Sx Sy Sz], that specifies the coordinates of the light
%  sources.  This input can also be specified in spherical
%  coordinates, s = [Az, El].
%
%  SURFLM(lat,lon,map,S,K) where K=[ka,kd,ks,spread] is used to
%  control the relative contributions due to ambient light, diffuse
%  reflection, specular reflection, and the specular spread
%  coefficient.
%
%  SURFLM activates a Graphical User Interface to project a lighted
%  map surface onto the current map axes.
%
%  SURFLM(map) and SURFLM(map,s) project the matrix map by constructing
%  a map graticule to span the MapLatLimit and MapLonLimit specified
%  in the map structure.
%
%  h = SURFLM(...) returns the handle to the projected surface object.
%
%  See also SURFL, SURFM, SURFACEM, SURFACE

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.15.4.1 $  $Date: 2003/08/01 18:22:52 $
%  Written by:  E. Byrns, E. Brown


%  Deal with inputs

if nargin == 0
     surflmui;  return
elseif nargin == 1 | nargin == 2

     [mstruct,msg] = gcm;
     if ~isempty(msg);   error(msg);   end
     latlim = mstruct.maplatlimit;
     lonlim = mstruct.maplonlimit;

     map = varargin{1};
     [lat,lon] = meshgrat(latlim,lonlim,size(map));
     varargin(1) = [];
else
    lat = varargin{1};   lon = varargin{2};   map = varargin{3};
    varargin(1:3) = [];
end

%  Test for map axes

if ~ismap;   error('Map axes are not current');   end

%  Test the lat and lon inputs

if length(lat) == 2 & length(lon) == 2    %  Assume limits of map
    [lat,lon] = meshgrat(lat,lon,size(map));
end


%  Test for consistent dimensions

if ~isequal(size(lat),size(lon),size(map))
    error('Inconsistent dimensions on lat, lon and map arguments')
end

%  Test for a map axes

[mstruct,msg] = gcm;
if ~isempty(msg);   error(msg);   end

%  Project the surface data

if ~strcmp(mstruct.mapprojection,'globe')
    [x,y,z,savepts] = mfwdtran(mstruct,lat,lon,[],'surface');
else
    error('Surflm inappropriate for globes');
end

%  Display the map

nextmap;
if ~isempty(varargin)
      hndl0 = surfl(x,y,map,varargin{:});
else
      hndl0 = surfl(x,y,map);
end

%  Set map properties

set(hndl0,'ButtonDownFcn','uimaptbx','UserData',savepts,...
          'EdgeColor','none');

%  Set handle return argument if necessary

if nargout ~= 0;    hndl = hndl0;   end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function surflmui

%  SURFLMUI creates the dialog box to allow the user to enter in
%  the variable names for a surflm command.  It is called when
%  SURFLM is executed with no input arguments.


%  Define map for current axes if necessary.  Note that if the
%  user cancels this operation, the display dialog is aborted.

%  Create axes if none found

if isempty(get(get(0,'CurrentFigure'),'CurrentAxes'))
    Btn = questdlg('Create Map Axes in Current Figure?','No Map Axes',...
	                'Yes','No','Yes');
    if strcmp(Btn,'No');    return;   end
	 axes;
end

%  Create map definition if necessary

if ~ismap
     cancelflag = axesm;
     if cancelflag;   clma purge;  return;   end
end

%  Initialize the entries of the dialog box

str1 = 'lat';           str2 = 'long';
str3 = 'map';           str4 = '';             str5 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = SurflmUIBox(str1,str2,str3,str4,str5);  uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.mapedit,'String');
        str4 = get(h.lgtedit,'String');
		str5 = get(h.cofedit,'String');
        delete(h.fig)

%  Construct the appropriate plotting string and assemble the callback string

        if isempty(str4) & isempty(str5)
            plotstr = ['surflm(',str1,',',str2,',',str3,')'];
        elseif isempty(str4) & ~isempty(str5)
            plotstr = ['surflm(',str1,',',str2,',',str3,',[],',str5,')'];
        elseif ~isempty(str4) & isempty(str5)
            plotstr = ['surflm(',str1,',',str2,',',str3,',',str4,')'];
        elseif ~isempty(str4) & ~isempty(str5)
            plotstr = ['surflm(',str1,',',str2,',',str3,',',str4,',',str5,');'];
        end

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

function h = SurflmUIBox(lat0,lon0,map0,s0,k0)

%  SURFLMUIBOX creates the dialog box and places the appropriate
%  objects for the SURFLMUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Surfl Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 3.7], ...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');


% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  Latitude Text and Edit Box

h.latlabel = uicontrol(h.fig,'Style','Text','String','Latitude variable:', ...
            'Units','Normalized','Position', [0.05  0.915  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latedit = uicontrol(h.fig,'Style','Edit','String', lat0, ...
            'Units','Normalized','Position', [0.05  .84  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .84  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.latedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Longitude Text and Edit Box

h.lonlabel = uicontrol(h.fig,'Style','Text','String','Longitude variable:', ...
            'Units','Normalized','Position', [0.05  0.745  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonedit = uicontrol(h.fig,'Style','Edit','String', lon0, ...
            'Units','Normalized','Position', [0.05  .67  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .67  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lonedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Map Text and Edit Box

h.maplabel = uicontrol(h.fig,'Style','Text','String','Map variable:', ...
            'Units','Normalized','Position', [0.05  0.575  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.mapedit = uicontrol(h.fig,'Style','Edit','String', map0, ...
            'Units','Normalized','Position', [0.05  .50  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.maplist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .50  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.mapedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Light Text and Edit Box

h.lgtlabel = uicontrol(h.fig,'Style','Text','String','Light Location (optional):', ...
            'Units','Normalized','Position', [0.05  0.405  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lgtedit = uicontrol(h.fig,'Style','Edit','String', s0, ...
            'Units','Normalized','Position', [0.05  .33  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lgtlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .33  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lgtedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Coefficients Text and Edit Box

h.coflabel = uicontrol(h.fig,'Style','Text','String','Coefficients:', ...
            'Units','Normalized','Position', [0.05  0.235  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.cofedit = uicontrol(h.fig,'Style','Edit','String', k0, ...
            'Units','Normalized','Position', [0.05  .16  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',2,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.coflist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .16  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.cofedit,...
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
			'CallBack','maphlp1(''initialize'',''surflmui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)
