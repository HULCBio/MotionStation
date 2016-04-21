function hndl = symbolm(varargin)

%SYMBOLM  Construct a thematic map with proportional symbol size
%
%  SYMBOLM(lat,lon,z,'MarkerType') constructs a thematic map where 
%  the symbol size of each data point (lat, lon) is proportional to 
%  it weighting factor (z).  The point corresponding to min(z) is 
%  drawn at the default marker size, and all other points are 
%  plotted with proportionally larger markers.  The MarkerType
%  string is a LineSpec string specifying a marker and optionally
%  a color.
%
%  SYMBOLM(lat,lon,z,'MarkerType','PropertyName',PropertyValue,...)
%  applies the line properties to all the symbols drawn.
%
%  SYMBOLM activates a Graphical User Interface to project a symbol
%  plot onto the current map axes.
%
%  h = SYMBOL(...) returns a vector of handles to the projected
%  symbols.  Each symbol is projected as an individual line object.
%
%  See also STEM3M, PLOTM, PLOT

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.12.4.1 $
%  Written by:  E. Byrns, E. Brown
%  Revision 1.0:  11/08/96


warning('SYMBOLM is obsolete and will be removed in a future version. Use SCATTERM instead.')

if nargin == 0
    symbolmui;   return
elseif nargin < 4
	error('Incorrect number of arguments.')
else
    lat = varargin{1};    lon = varargin{2};
	z   = varargin{3};    sym = varargin{4};
	varargin(1:4) = [];
end

%  Input dimension tests

if ~isequal(size(lat),size(lon),size(z))
    error('Inconsistent dimensions on lat, lon and z')
else
    lat = lat(:);    lon = lon(:);    z = z(:);
end

%  Test for a valid symbol string

[lstyle,lcolor,lmark,msg] = colstyle(sym);
if ~isempty(msg);   error(msg);   end
if isempty(lmark);     error('Valid symbol must be specified');    end

%  Build up a new property string vector

symbolcell{1} = 'Marker';     symbolcell{2} = lmark;
if ~isempty(lcolor)
      symbolcell{length(symbolcell)+1} = 'Color';
	  symbolcell{length(symbolcell)+1} = lcolor;
end


% Construct the data points vector

latmat = [lat   lat]';
lonmat = [lon   lon]';
altmat = zeros(size(latmat));

%  Display the map

h = plot3m(latmat,lonmat,altmat,symbolcell{:});
if ~isempty(varargin);   set(h,varargin{:});   end

%  Determine if it is necessary to apply default colors to the symbols
%  All symbols will be the same color in this plot

needcolors = 0;
firstclr   = get(h(1),'Color');
for i = 2:length(h)
      currentclr = get(h(i),'Color');
	  if any(firstclr ~= currentclr)
	       needcolors = 1;   break
	  end
end

%  Set the symbol size proportional to the number of occurances
%  Ensure uniform symbol color if needcolors == true

minmarker = get(h(1),'MarkerSize');
markervec = minmarker * z / min(z(:));       %  Proportional marker size

for i = 1:length(h)
      if needcolors
	       set(h(i),'MarkerSize',markervec(i),'Color',firstclr);
	  else
	       set(h(i),'MarkerSize',markervec(i));
	  end
end


%  Set handle return argument if necessary

if nargout == 1;    hndl = h;   end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function symbolmui

%  SYMBOLMUI creates the dialog box to allow the user to enter in
%  the variable names for a symbolm command.  It is called when
%  SYMBOLM is executed with no input arguments.


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
str3 = 'z';         str4 = '''.''';    str5 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = SymbolmUIBox(str1,str2,str3,str4,str5);  uiwait(h.fig)

	if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.altedit,'String');
        str4 = get(h.markedit,'String');
		str5 = get(h.propedit,'String');
        delete(h.fig)
		
%  Make the other property string into a single row vector.
%  Eliminate any padding 0s since they mess up a string

		str5 = str5';   str5 = str5(:)';   str5 = str5(find(str5));

%  Construct the appropriate plotting string and assemble the callback string

		w = warning; warning off
		
        if isempty(str5)
            plotstr = ['symbolm(',str1,',',str2,',',str3,',',str4,')'];
        else
            plotstr = ['symbolm(',str1,',',str2,',',str3,',',str4,',',str5,');'];
        end
	
		warning(w)
		
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

function h = SymbolmUIBox(lat0,lon0,z0,style0,prop0)

%  SYMBOLMUIBOX creates the dialog box and places the appropriate
%  objects for the SYMBOLMUI function.

%  Compute the Pixel and Font Scaling Factors so 
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Symbol Map Input',...
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

h.altlabel = uicontrol(h.fig,'Style','Text','String','Marker size variable:', ... 
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

%  Marker Style Text and Edit Box

h.marklabel = uicontrol(h.fig,'Style','Text','String','Marker Style:', ... 
            'Units','Normalized','Position', [0.05  0.475  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.markedit = uicontrol(h.fig,'Style','Edit','String', style0, ...
            'Units','Normalized','Position', [0.05  .40  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'left', 'Max',1, ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

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
			'CallBack','maphlp1(''initialize'',''symbolmui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)



