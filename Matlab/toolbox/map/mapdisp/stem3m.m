function hndl = stem3m(varargin)

%STEM3M  Construct a thematic map with proportional stem heights
%
%  STEM3M(lat,lon,z) constructs a thematic map where a stem of height
%  z is drawn at each lat/lon data point.
%
%  STEM3M(lat,lon,z,'LineSpec') draws each stem using the LineSpec
%  string.  Any LineSpec string supported by PLOT can be used.
%
%  STEM3M(lat,lon,z,'PropertyName',PropertyValue,...) uses the
%  specified line properties to draw the stems.
%
%  STEM3M activates a Graphical User Interface for projecting a
%  stem plot onto the current map axes.
%
%  h = STEM3M(...) returns the handle of the stem plot.  The stems
%  are drawn as a single NaN clipped line.
%
%  See also SYMBOLM, PLOTM, PLOT

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.14.4.1 $  $Date: 2003/08/01 18:22:49 $
%  Written by:  E. Byrns, E. Brown



if nargin == 0
    stem3mui;   return
elseif nargin < 3
	error('Incorrect number of arguments.')
else
    lat = varargin{1};    lon = varargin{2};     z = varargin{3};
	varargin(1:3) = [];
end

%  Input dimension tests

if ~isequal(size(lat),size(lon),size(z))
    error('Inconsistent dimensions on lat, lon and z inputs')
else
    lat = lat(:);    lon = lon(:);    z = z(:);
end

%  Test for a valid symbol string

symbolcell = [];   stylecell = [];

if rem(length(varargin),2)
    [lstyle,lcolor,lmark,msg] = colstyle(varargin{1});
    if ~isempty(msg);  error(msg);   end

    varargin(1) = [];    symbolcell= {};    stylecell= {};

	if ~isempty(lstyle)
        stylecell{1} = 'LineStyle';      stylecell{2} = lstyle;
    end

    if ~isempty(lmark)
        symbolcell{1} = 'Marker';        symbolcell{2} = lmark;
    end

	 if ~isempty(lcolor)
	       stylecell{length(stylecell)+1} = 'Color';
	       stylecell{length(stylecell)+1} = lcolor;
	       symbolcell{length(symbolcell)+1} = 'Color';
	       symbolcell{length(symbolcell)+1} = lcolor;
     end
end


% Construct the spatial bar chart

latmat = [lat             lat]';   latmat(3,:) = NaN;
lonmat = [lon             lon]';   lonmat(3,:) = NaN;
altmat = [zeros(size(z))  z  ]';   altmat(3,:) = NaN;

%  Display the vertical bar portion of the map

hndl1 = plot3m(latmat(:),lonmat(:),altmat(:));
if ~isempty(stylecell);  set(hndl1,stylecell{:});  end
if ~isempty(varargin);   set(hndl1,varargin{:});   end
set(hndl1,'Marker','none');

%  Display the symbol portion of the map

hndl2 = plot3m(lat,lon,z);
if ~isempty(symbolcell);  set(hndl2,symbolcell{:});  end
if ~isempty(varargin);    set(hndl2,varargin{:});   end
set(hndl2,'LineStyle','none');

%  Set handle return argument if necessary

if nargout == 1;    hndl = [hndl1; hndl2];   end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function stem3mui

%  STEM3MUI creates the dialog box to allow the user to enter in
%  the variable names for a stem3m command.  It is called when
%  STEM3M is executed with no input arguments.


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

str1 = 'lat';   str2 = 'long';   str3 = 'z';   str4 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = Stem3mUIBox(str1,str2,str3,str4);  uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') ~= h.cancel
        str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.altedit,'String');
		str4 = get(h.propedit,'String');
		delete(h.fig)

%  Make the other property string into a single row vector.
%  Eliminate any padding 0s since they mess up a string

		str4 = str4';   str4 = str4(:)';   str4 = str4(find(str4));

%  Construct the appropriate plotting string and assemble the callback string

        if isempty(str4)
		    plotstr = ['stem3m(',str1,',',str2,',',str3,');'];
        else
            plotstr = ['stem3m(',str1,',',str2,',',str3,',',str4,');'];
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

function h = Stem3mUIBox(lat0,lon0,z0,prop0)

%  STEM3MUIBOX creates the dialog box and places the appropriate
%  objects for the STEM3MUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Stem Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 3.3],...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  Latitude Text and Edit Box

h.latlabel = uicontrol(h.fig,'Style','Text','String','Latitude variable:', ...
            'Units','Normalized','Position', [0.05  0.91  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latedit = uicontrol(h.fig,'Style','Edit','String', lat0, ...
            'Units','Normalized','Position', [0.05  .82  0.70  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .82  0.18  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.latedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Longitude Text and Edit Box

h.lonlabel = uicontrol(h.fig,'Style','Text','String','Longitude variable:', ...
            'Units','Normalized','Position', [0.05  0.722  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonedit = uicontrol(h.fig,'Style','Edit','String', lon0, ...
            'Units','Normalized','Position', [0.05  .63  0.70  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .63  0.18  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lonedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Count Text and Edit Box


h.altlabel = uicontrol(h.fig,'Style','Text','String','Stem Height Variable:', ...
            'Units','Normalized','Position', [0.05  0.532  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altedit = uicontrol(h.fig,'Style','Edit','String', z0, ...
            'Units','Normalized','Position', [0.05  .44  0.70  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .44  0.18  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.altedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Other Properties Text and Edit Box

h.proplabel = uicontrol(h.fig,'Style','Text','String','Other Properties:', ...
            'Units','Normalized','Position', [0.05  0.343  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.propedit = uicontrol(h.fig,'Style','Edit','String', prop0, ...
            'Units','Normalized','Position', [0.05  .19  0.90  0.15], ...
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
			'CallBack','maphlp1(''initialize'',''stem3mui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)

