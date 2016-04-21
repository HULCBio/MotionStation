function [hndl,msg] = linem(varargin)

%LINEM  Project line objects onto the current map axes
%
%  LINEM(lat,lon) projects the line objects onto the current
%  map axes.  The input latitude and longitude data must be in
%  the same units as specified in the current map axes.
%  Unlike PLOTM and PLOT3M, LINEM will always add lines to
%  the current axes, regardless of the current hold state.
%
%  LINEM(lat,lon,z) projects a 3D line object onto the current
%  map axes.
%
%  LINEM(lat,lon,'LineSpec') and LINEM(lat,lon,z,'LineSpec') uses
%  any valid LineSpec string to display the line object.
%
%  LINEM(lat,lon,'PropertyName',PropertyValue,...) and
%  LINEM(lat,lon,z,'PropertyName',PropertyValue,...) uses
%  the line object properties specified to display the line
%  objects.  Except for xdata, ydata and zdata, all line properties,
%  and styles available through LINE are supported by LINEM.
%
%  h = LINEM(...) returns the handles to the line objects displayed.
%
%  [h,msg] = LINEM(...) returns a string msg indicating any error
%  encountered.
%
%  LINEM, without any inputs, will activate a GUI to project line
%  objects onto the current map axes.
%
%  See also PLOTM, PLOT3M, LINE

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.15.4.1 $  $Date: 2003/08/01 18:18:43 $

if nargin == 0
    linemui;   return

elseif nargin < 2
	error('Incorrect number of arguments.')
else
    lat = varargin{1};    lon = varargin{2};
    if nargin == 2 | isstr(varargin{3})
	    z = zeros(size(lat));      varargin(1:2) = [];
	else
		z = varargin{3};           varargin(1:3) = [];
    end
end

%  Initialize outputs

if nargout ~= 0;  hndl = [];   msg = [];   end

%  Test for scalar z data

if length(z) == 1;   z = z(ones(size(lat)));   end

%  Argument size tests

if any([ndims(lat) ndims(lon) ndims(z)] > 2)
    msg = 'Line data must not contain pages';
	if nargout < 2;  error(msg);  end
	return

elseif ~isequal(size(lat),size(lon),size(z))
    msg = 'Inconsistent dimensions on input data';
	if nargout < 2;  error(msg);  end
	return
end

%  Ensure a column vector if a row vector is given.

if size(lat,1) == 1;   lat = lat';   lon = lon';   z = z';   end

%  Parse the line styles

if rem(length(varargin),2)
    [lstyle,lcolor,lmark,msg] = colstyle(varargin{1});
    if ~isempty(msg)
        if nargout ~= 2;   error(msg)
	        else;          hndl = [];   return;   end
	end

	if isempty(lstyle);    lstyle = 'none';   end
	if isempty(lmark);     lmark = 'none';    end


%  Build up a new property string vector

     varargin(1) = [];    linespec = {};
	 if ~isempty(lcolor)
	       linespec{length(linespec)+1} = 'Color';
	       linespec{length(linespec)+1} = lcolor;
     end

	 if ~strcmp(lstyle,'none') | ~strcmp(lmark,'none')
	       linespec{length(linespec)+1} = 'LineStyle';
	       linespec{length(linespec)+1} = lstyle;
	       linespec{length(linespec)+1} = 'Marker';
	       linespec{length(linespec)+1} = lmark;
	 end

%  Append linespec to front of varargin.  Allows users to
%  override linespec properties

	 varargin = [linespec varargin];
end

%  Test for a map axes

[mstruct,msg] = gcm;
if ~isempty(msg)
    if nargout < 2;  error(msg);   end
	return
end

%  Project the line data

[x,y,z,savepts] = mfwdtran(mstruct,lat,lon,z,'line');

%  Display the map.

hndl0 = line(x,y,z,'ButtonDownFcn','uimaptbx');

%  Set the userdata property for each line

for i = 1:size(x,2)
     if isempty(savepts.clipped)
	     userdata.clipped = [];
	 else
	     cindx = find(savepts.clipped(:,2) == i);
         userdata.clipped = savepts.clipped(cindx,:);
     end

     if isempty(savepts.trimmed)
	     userdata.trimmed = [];
	 else
	     tindx = find(savepts.trimmed(:,2) == i);
         userdata.trimmed = savepts.trimmed(tindx,[1 3 4]);
     end

     set(hndl0(i),'UserData',userdata)
end

%  Set line properties if necessary

if ~isempty(varargin);  set(hndl0,varargin{:});  end

%  Set handle return argument if necessary

if nargout ~= 0;    hndl = hndl0;   end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function linemui

%  LINEMUI creates the dialog box to allow the user to enter in
%  the variable names for a linem command.  It is called when
%  LINEM is executed with no input arguments.


%  Define map for current axes if necessary.  Note that if the
%  user cancels this operation, the display dialog is aborted.

%  Christopher Byrns (age 2) contributed by (get this):
%       One day, MATLAB was open and at the command line when Christopher
%       Byrns decided to bang on the keyboard.  His actions brought
%       up the help window, and ended up on the function ASSIGNIN.M
%       (which was undocumented at the time).  The See Also function
%       for ASSIGNIN.M is EVALIN.M which is key to making these (and
%       similar) dialog boxes work.  Originally, this function
%       used a convoluted hack around with the ChangeFcn property
%       so that the command was executed in the base workspace.
%       EVALIN eliminates this hack.  I had no idea about the
%       existance of ASSIGNIN or EVALIN before the keyboard was smacked.

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

str1 = 'lat';   str2 = 'long';   str3 = '';   str4 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = LinemUIBox(str1,str2,str3,str4);  uiwait(h.fig)

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if ~ishandle(h.fig);   return;   end

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

        if isempty(str3) & isempty(str4)
            plotstr = ['linem(',str1,',',str2,')'];
        elseif isempty(str3) & ~isempty(str4)
            plotstr = ['linem(',str1,',',str2,',',str4,')'];
        elseif ~isempty(str3) & isempty(str4)
		    plotstr = ['linem(',str1,',',str2,',',str3,');'];
        elseif ~isempty(str3) & ~isempty(str4)
            plotstr = ['linem(',str1,',',str2,',',str3,',',str4,');'];
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


function h = LinemUIBox(lat0,lon0,alt0,prop0)

%  LINEMUIBOX creates the dialog box and places the appropriate
%  objects for the LINEMUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Line Map Input',...
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

%  Altitude Text and Edit Box

h.altlabel = uicontrol(h.fig,'Style','Text','String','Altitude variable (optional):', ...
            'Units','Normalized','Position', [0.05  0.532  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altedit = uicontrol(h.fig,'Style','Edit','String', alt0, ...
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
			'CallBack','maphlp1(''initialize'',''linemui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)

