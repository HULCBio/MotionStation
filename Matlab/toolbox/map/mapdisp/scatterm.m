function hh = scatterm(varargin)
%SCATTERM Scatter map.
%
%   SCATTERM(LAT,LON,S,C) displays colored circles at the locations specified
%   by the vectors LAT and LON (which must be the same size).  The area of
%   each marker is determined by the values in the vector S (in points^2)
%   and the colors of each marker are based on the values in C. S can be a
%   scalar, in which case all the markers are drawn the same size, or a
%   vector the same length as LAT and LON.
%   
%   When C is a vector the same length as LAT and LON, the values in C
%   are linearly mapped to the colors in the current colormap.  
%   When C is a LENGTH(LAT)-by-3 matrix, the values in C specify the
%   colors of the markers as RGB values.  C can also be a color string.
%
%   SCATTERM(LAT,LON) draws the markers in the default size and color.
%   SCATTERM(LAT,LON,S) draws the markers with a single color.
%   SCATTERM(...,M) uses the marker M instead of 'o'.
%   SCATTERM(...,'filled') fills the markers.
%
%   SCATTERM, without any inputs, will activate a GUI to project point
%   data onto the current map axes.
%
%   H = SCATTERM(...) returns handles the PATCHES created.
%
%   Use PLOTM for single color, single marker size scatter plots.
%
%   Example
%     load seamount
%     worldmap([-49 -47.5],[-150 -147.5],'none')
%     scatterm(y,x,5,z)
%     scaleruler
%
%   See also SCATTER, PLOT, PLOTMATRIX.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by:  E. Byrns, E. Brown
%   $Revision: 1.11.4.2 $  $Date: 2003/08/01 18:22:37 $

if nargin == 0
	scattermui;   return
else
	error(nargchk(2,6,nargin))
end

%  Test for a map axes

[mstruct,msg] = gcm;
if ~isempty(msg)
    error(msg)
	return
end
	
% extract the minimum required data from the input arguments
lat = varargin{1};
lon = varargin{2};

% Transform the lat and long to x and y. Trim manually to avoid
% complications introduced by clipping. Point data doesn't need
% to be cut across the dateline. Trimming as a surface doesn't 
% introduce any extra points. Can't just clip and trim as a 
% surface

[x,y,z,savepts] = mfwdtran(lat,lon,[],'point');

% put the modified values back
varargin{1} = x;
varargin{2} = y;

% Call MATLAB's scatter command
if ~isempty(findstr(version,'R14'))
   h = scatter('v6',varargin{:});
else
   h = scatter(varargin{:});
end


% Add savepts field to make the scatter points mapped
thissavepts.clipped = [];
thissavepts.trimmed = [];

set(h,'UserData',thissavepts)
if ~isempty(savepts.trimmed)
		
	for i=1:size(savepts.trimmed,1)
		thissavepts.trimmed = [ 1 1 savepts.trimmed(i,2:3)];
		set(h(savepts.trimmed(i,1)),'Userdata',thissavepts)
	end
end
% keyboard

if nargout == 1;
	hh = h;
end

%*************************************************************************
%*************************************************************************
%*************************************************************************


function scattermui

%  SCATTERMUI creates the dialog box to allow the user to enter in
%  the variable names for a scatterm command.  It is called when
%  SCATTERM is executed with no input arguments.


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
str3 = '';         str4 = '';		str5 ='''o''';    str6 = 'notfilled';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

   h = scattermUIBox(str1,str2,str3,str4,str5,str6);  uiwait(h.fig)

	if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.altedit,'String');
        str4 = get(h.coloredit,'String');
		
	
		str5 = ['''' popupstr(h.markpopup) ''''];
		str6 = ''; if get(h.fillcheck,'Value'); str6 = '''filled'''; end
        delete(h.fig)

%  Construct the appropriate plotting string and assemble the callback string

		str = [ str1 ',' str2 ];
		if isempty(str3) & ~isempty(str4); 
			str = [str ',20,' str4];  % provide a default markers size
		elseif ~isempty(str3) & isempty(str4);
			 str = [str ',' str3 ];
		elseif isempty(str3) & isempty(str4);
			 
		else
			str = [str ',' str3 ',' str4];  
	 	end
			 
		str = [str ',' str5];
		if ~isempty(str6); str = [str ',' str6]; end
		
        plotstr = ['scatterm(' str ');'];

		if isempty(lasterr)
		    evalin('base',plotstr,...
		        'uiwait(errordlg(lasterr,''Map Projection Error'',''modal''))')
		end
		if isempty(lasterr);   break;   end  %  Break loop with no errors
   else
        delete(h.fig)     %  Close the modal dialog box
		break             %  Exit the loop
   end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************

function h = scattermUIBox(lat0,lon0,z0,color0,style0,fill0)

%  SCATTERMUIBOX creates the dialog box and places the appropriate
%  objects for the SCATTERMUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Scatter Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 3.7], ...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');


% shift window if it comes up partly offscreen

shiftwin(h.fig)

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

%  Count Data Text and Edit Box

h.altlabel = uicontrol(h.fig,'Style','Text','String','Marker size (optional):', ...
            'Units','Normalized','Position', [0.05  0.625  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altedit = uicontrol(h.fig,'Style','Edit','String', z0, ...
            'Units','Normalized','Position', [0.05  .55  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .55  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.altedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Color Data Text and Edit Box

h.colorlabel = uicontrol(h.fig,'Style','Text','String','Marker color (optional):', ...
            'Units','Normalized','Position', [0.05 0.475  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.coloredit = uicontrol(h.fig,'Style','Edit','String', color0, ...
            'Units','Normalized','Position', [0.05  .40  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.colorlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .40  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.coloredit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Marker Style Text and Edit Box

h.marklabel = uicontrol(h.fig,'Style','Text','String','Marker Style:', ...
            'Units','Normalized','Position', [0.05  0.3  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

strings={'+','o','*','.','x','v','^','>','<'};

indx = findstr(style0,''''); style0(indx) = []; % strip quotes
indx = strmatch(style0,strings,'exact');

h.markpopup = uicontrol(h.fig,'Style','popup','String', strings, 'Value',indx, ...
            'Units','Normalized','Position', [0.2  .25-0.025  0.25  0.07], ...
			'FontSize',FontScaling*10,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Fill labels checkbox

fvalue = 0;
if strmatch('filled',fill0); fvalue = 1; end

h.fillcheck = uicontrol(h.fig,'Style','check',  'Value',fvalue,'String','Filled',...
            'Units','Normalized','Position', [0.55  .245-0.025  0.25  0.075], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Min',0,'Max',1,...
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
         'CallBack','maphlp1(''initialize'',''scattermui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)
