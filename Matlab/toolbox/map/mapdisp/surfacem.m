function [hndl,msg] = surfacem(varargin)

%SURFACEM  Display a matrix map warped to a projected graticule
%
%  SURFACEM(lat,lon,map) will warp a matrix map to a projected
%  graticule mesh, thus allowing matrix surfaces to be displayed
%  in a map projection.  The graticule mesh is specified by the lat
%  and lon inputs.  Unlike MESHM and SURFM, SURFACEM will always
%  add surfaces to the current axes, regardless of the current
%  hold state.
%
%  SURFACEM(lat,lon,map,alt) uses the input alt as the zdata to
%  draw the graticule mesh.  In this case, size(alt) and size(lat)
%  must be the same.  If the alt input is not supplied, then the
%  graticule zdata is dependent on size(lat).  If size(lat) and
%  size(map) are not the same, then the graticule mesh is drawn
%  at the z = 0 plane.  However, if size(lat) and size(map) are
%  equal, then the graticule mesh is drawn with zdata = map,
%  thus producing a 3D surface map.
%
%  SURFACEM(lat,lon,map,'PropertyName',PropertyValue,...) and
%  SURFACEM(lat,lon,map,alt,'PropertyName',PropertyValue,...) display
%  general matrix map using the specified surface properties.
%
%  SURFACEM(map) and SURFACEM(map,npts) computes a default graticule mesh 
%  with MESHGRAT using the latitude and longitude limits in the current map 
%  axes definition.  If npts is supplied, then MESHGRAT is executed using 
%  npts and the map latitude and longitude limits in the current map axes.
%
%  h = SURFACEM(...) returns the handle to the surface object displayed.
%
%  [h,msg] = SURFACEM(...) returns a string indicating any error encountered.
%
%  SURFACEM, without any inputs, activates a GUI for projecting general
%  surfaces onto the current axes.
%
%  See also MESHM, SURFM, PCOLORM, IMAGEM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.15.4.1 $  $Date: 2003/08/01 18:22:50 $


%  Initialize outputs

if nargout ~= 0;  hndl = [];   msg = [];   end

%  Test for a map axes

if nargin == 0
     surfacemui;  return
end

[mstruct,msg] = gcm;
if ~isempty(msg)
    if nargout < 2;  error(msg);   end
	return
end

latlim = mstruct.maplatlimit;
lonlim = mstruct.maplonlimit;

if nargin == 1
     map = varargin{1};
     [lat,lon] = meshgrat(latlim,lonlim,[]);
     alt = zeros(size(lat));
     varargin(1) = [];

elseif nargin == 2
     map = varargin{1};     npts = varargin{2};
     varargin(1:2) = [];

     [lat,lon] = meshgrat(latlim,lonlim,npts);
     if all(size(lat) == size(map))
	    alt = map;
	 else
	    alt = zeros(size(lat));
     end

else

    lat = varargin{1};   lon = varargin{2};   map = varargin{3};

	if isequal(sort(size(lat)),sort(size(lon)),[1 2])
	    [lat,lon] = meshgrat(lat,lon,[]);
	end

    if nargin == 3 | isstr(varargin{4})
	    alt = zeros(size(lat));      varargin(1:3) = [];
	else
	    alt = varargin{4};           varargin(1:4) = [];
    end
end

%  Test for scalar altitude

if length(alt) == 1;   alt = alt(ones(size(lat)));   end

%  Input dimension tests

if any([ndims(lat) ndims(lon) ndims(alt)] > 2)
    msg = 'Input lat, lon and alt matrices must not contain any pages';
    if nargout < 2;  error(msg);  end
	return

elseif ~isequal(size(lat),size(lon),size(alt))
    msg = 'Inconsistent dimensions on input lat, lon and alt matrices';
    if nargout < 2;  error(msg);  end
	return
end


%  Project the surface data

[x,y,z,savepts] = mfwdtran(mstruct,lat,lon,alt,'surface');

%  Display the map

if isequal(size(x),size(map))
    hndl0 = surface(x,y,z,'Cdata',map,...
                'LineStyle','none',...
                'ButtonDownFcn','uimaptbx',...
				    'UserData',savepts);
else
    hndl0 = surface(x,y,z,'Cdata',map,...
                'FaceColor','TextureMap','LineStyle','none',...
                'ButtonDownFcn','uimaptbx',...
				    'UserData',savepts);
end

%  Set properties if necessary

if ~isempty(varargin);  set(hndl0,varargin{:});  end

%  Set handle return argument if necessary

if nargout ~= 0;    hndl = hndl0;   end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function surfacemui

%  SURFACEMUI creates the dialog box to allow the user to enter in
%  the variable names for a surfacem command.  It is called when
%  SURFACEM is executed with no input arguments.


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

str1 = 'lat';       str2 = 'long';
str3 = 'map';       str4 = '';        str5 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = SurfmUIBox(str1,str2,str3,str4,str5);  uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.mapedit,'String');
        str4 = get(h.altedit,'String');
		str5 = get(h.propedit,'String');
        delete(h.fig)

%  Make the other property string into a single row vector.
%  Eliminate any padding 0s since they mess up a string

		str5 = str5';   str5 = str5(:)';   str5 = str5(find(str5));

%  Construct the appropriate plotting string and assemble the callback string

        if isempty(str4) & isempty(str5)
            plotstr = ['surfacem(',str1,',',str2,',',str3,')'];
        elseif isempty(str4) & ~isempty(str5)
            plotstr = ['surfacem(',str1,',',str2,',',str3,',',str5,')'];
        elseif ~isempty(str4) & isempty(str5)
            plotstr = ['surfacem(',str1,',',str2,',',str3,',',str4,')'];
        elseif ~isempty(str4) & ~isempty(str5)
            plotstr = ['surfacem(',str1,',',str2,',',str3,',',str4,',',str5,');'];
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

function h = SurfmUIBox(lat0,lon0,map0,alt0,prop0)

%  SURFMUIBOX creates the dialog box and places the appropriate
%  objects for the SURFMUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Surface Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 3.7], ...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

%  Latitude Text and Edit Box

h.latlabel = uicontrol(h.fig,'Style','Text','String','Latitude variable:', ...
            'Units','Normalized','Position', [0.05  0.925  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latedit = uicontrol(h.fig,'Style','Edit','String', lat0, ...
            'Units','Normalized','Position', [0.05  .85  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .85  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.latedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Longitude Text and Edit Box

h.lonlabel = uicontrol(h.fig,'Style','Text','String','Longitude variable:', ...
            'Units','Normalized','Position', [0.05  0.775  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonedit = uicontrol(h.fig,'Style','Edit','String', lon0, ...
            'Units','Normalized','Position', [0.05  .70  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .70  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lonedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Map Text and Edit Box

h.maplabel = uicontrol(h.fig,'Style','Text','String','Map variable:', ...
            'Units','Normalized','Position', [0.05  0.625  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.mapedit = uicontrol(h.fig,'Style','Edit','String', map0, ...
            'Units','Normalized','Position', [0.05  .55  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.maplist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .55  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.mapedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Altitude Text and Edit Box

h.altlabel = uicontrol(h.fig,'Style','Text','String','Altitude variable (optional):', ...
            'Units','Normalized','Position', [0.05  0.475  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altedit = uicontrol(h.fig,'Style','Edit','String', alt0, ...
            'Units','Normalized','Position', [0.05  .40  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .40  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.altedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Other Properties Text and Edit Box

h.proplabel = uicontrol(h.fig,'Style','Text','String','Other Properties:', ...
            'Units','Normalized','Position', [0.05  0.325  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.propedit = uicontrol(h.fig,'Style','Edit','String', prop0, ...
            'Units','Normalized','Position', [0.05  .16  0.90  0.16], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',2,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

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
			'CallBack','maphlp1(''initialize'',''surfacemui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)
