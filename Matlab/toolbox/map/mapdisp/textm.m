function [hndl,msg] = textm(varargin)

%TEXTM	Project text onto the current map axes
%
%  TEXTM(lat,lon,'string') projects the text string onto the
%  current map axes.  The latitude and longitude locations are
%  supplied in the same units as the current map axes.  Multiple
%  text entries can be defined by multiple rows in the lat, lon and
%  string matrix inputs.
%
%  TEXTM(lat,lon,z,'string') draws the text at the altitude
%  specified by the z data input.
%
%  TEXTM(...,'PropertyName',PropertyValue,...) uses the text
%  properties supplied to draw the text.
%
%  h = TEXTM(...) returns the handles to the text objects drawn.
%
%  [h,msg] = TEXTM(...) returns an optional second output which
%  contains a string indicating any errors encountered.
%
%  See also GTEXTM, TEXT

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.16.4.1 $    $Date: 2003/08/01 18:22:57 $


%  Argument error tests

if nargin == 0
    textmui;   return
elseif nargin < 3
	error('Incorrect number of arguments.')
else
    lat = varargin{1};    lon = varargin{2};
    if isstr(varargin{3})
	    z = zeros(size(lat));    textstr = varargin{3};  varargin(1:3) = [];
    else
	    z = varargin{3};         textstr = varargin{4};  varargin(1:4) = [];
	end
end

%  Initialize outputs

if nargout ~= 0;  hndl = [];   msg = [];   end

%  Argument size tests

if any([ndims(lat) ndims(lon) ndims(z)] > 2)
    msg = 'Location data must not contain pages';
	if nargout < 2;  error(msg);  end
	return

elseif ~isequal(size(lat),size(lon),size(z))
    msg = 'Inconsistent dimensions on lat, lon and z arguments';
	if nargout < 2;  error(msg);  end
	return

elseif min(size(lat)) ~= 1
    msg = 'Input locations must be vectors';
	if nargout < 2;  error(msg);  end
	return

elseif length(lat) > 1 & length(lat) ~= size(textstr,1)
    msg = 'Inconsistent location and text strings';
	if nargout < 2;  error(msg);  end
	return
end

%  Ensure vectors for the data points

lat = lat(:);    lon = lon(:);   z = z(:);

%  Test for a map axes

[mstruct,msg] = gcm;
if ~isempty(msg)
    if nargout < 2;  error(msg);   end
	return
end

%  Project the text location data

[x,y,z,savepts] = mfwdtran(mstruct,lat,lon,z,'text');

%  Display the text

hndl0 = text(x,y,z,textstr,'ButtonDownFcn','uimaptbx',...
			   'Clipping','on');

%  Set the userdata property for each line

for i = 1:length(x)
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

%  Set text properties if necessary

if ~isempty(varargin);  set(hndl0,varargin{:});  end

%  Set return handles if necessary

if nargout ~= 0;    hndl = hndl0;   end

%*************************************************************************
%*************************************************************************
%*************************************************************************


function textmui

%  TEXTMUI creates the dialog box to allow the user to enter in
%  the variable names for a surfacem command.  It is called when
%  TEXTM is executed with no input arguments.


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

str1 = '';        str2 = 'lat';    str3 = 'long';
str4 = '';        str5 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = TextmUIBox(str1,str2,str3,str4,str5);  uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.txtedit,'String');    %  Get the dialog entries
        str2 = get(h.latedit,'String');
		str3 = get(h.lonedit,'String');
        str4 = get(h.altedit,'String');
		str5 = get(h.propedit,'String');
        delete(h.fig)

%  Make the other property string into a single row vector.
%  Eliminate any padding 0s since they mess up a string

		str5 = str5';   str5 = str5(:)';   str5 = str5(find(str5));

%  Construct the appropriate plotting string and assemble the callback string

        if isempty(str4) & isempty(str5)
            plotstr = ['textm(',str2,',',str3,',',str1,')'];
        elseif isempty(str4) & ~isempty(str5)
            plotstr = ['textm(',str2,',',str3,',',str1,',',str5,')'];
        elseif ~isempty(str4) & isempty(str5)
            plotstr = ['textm(',str2,',',str3,',',str4,',',str1,')'];
        elseif ~isempty(str4) & ~isempty(str5)
            plotstr = ['textm(',str2,',',str3,',',str4,',',str1,',',str5,');'];
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

function h = TextmUIBox(text0,lat0,lon0,alt0,prop0)

%  TEXTMUIBOX creates the dialog box and places the appropriate
%  objects for the TEXTMUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Text Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 3.7], ...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  Text Variable Text and Edit Box

h.txtlabel = uicontrol(h.fig,'Style','Text','String','Text variable/string:', ...
            'Units','Normalized','Position', [0.05  0.925  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.txtedit = uicontrol(h.fig,'Style','Edit','String', text0, ...
            'Units','Normalized','Position', [0.05  .85  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.txtlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .85  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.txtedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Latitude Text and Edit Box

h.latlabel = uicontrol(h.fig,'Style','Text','String','Latitude variable:', ...
            'Units','Normalized','Position', [0.05  0.775  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latedit = uicontrol(h.fig,'Style','Edit','String', lat0, ...
            'Units','Normalized','Position', [0.05  .70  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .70  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.latedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Longitude Text and Edit Box

h.lonlabel = uicontrol(h.fig,'Style','Text','String','Longitude variable:', ...
            'Units','Normalized','Position', [0.05  0.625  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonedit = uicontrol(h.fig,'Style','Edit','String', lon0, ...
            'Units','Normalized','Position', [0.05  .55  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .55  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lonedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Altitude Text and Edit Box

h.altlabel = uicontrol(h.fig,'Style','Text','String','Scalar Altitude (optional):', ...
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
			'CallBack','maphlp1(''initialize'',''textmui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)

