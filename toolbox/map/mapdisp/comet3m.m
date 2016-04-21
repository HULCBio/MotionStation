function comet3m(lat,lon,z,p)
%COMET3M Three dimensional comet plot projected on a map axes.
%
%  COMET3M(lat,lon,z) projects a comet plot in three dimensions
%  on the current map axes.  A comet plot is an animated graph
%  in which a circle (the comet head) traces the data points on the
%  screen.  The comet body is a trailing segment that follows the head.
%  The tail is a solid line that traces the entire function.  The
%  lat and lon vectors must be in the same units as specified in
%  the map structure.
%
%  COMET3M(lat,lon,z,p) uses the input p to specify a comet body
%  size of p*length(lat)
%
%  COMET3M activates a Graphical User Interface for projecting
%  comet plots.
%
%  See also  COMETM, COMET, COMET3

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.14.4.1 $  $Date: 2003/08/01 18:18:03 $
%  Written by:  E. Byrns, E. Brown


checknargin(0,4,nargin,mfilename);
if nargin == 0
    cometmui;   
    return
elseif nargin == 3
    p = [];
end

%  Test for scalar z data
%  Comet3 won't accept all data in single z plane, so use z(1) as a work-around
if length(z) == 1;   z = z(ones(size(lat)));   z(1) = z(1)-1E-6;  end

%  Argument tests
if any([min(size(lat))    min(size(lon))     min(size(z))] ~= 1) |...
   any([ndims(lat) ndims(lon)  ndims(z)] > 2)
      eid = sprintf('%s:%s:nonVectorInput', getcomp, mfilename);
      error(eid,'%s','Data inputs must be vectors');

elseif ~isequal(size(lat),size(lon),size(z))
      eid = sprintf('%s:%s:invalidDimensions', getcomp, mfilename);
      error(eid,'%s','Inconsistent dimensions on input data');

elseif length(p) > 1
      eid = sprintf('%s:%s:invalidTailLength', getcomp, mfilename);
      error(eid,'%s','Tail Length input must be a scalar');
end

%  Test for a map axes and get the map structure
[mstruct,msg] = gcm;
if ~isempty(msg);  
    eid = sprintf('%s:%s:noGCM', getcomp, mfilename);
    error(eid,'%s',msg);  
end

%  Project the line data
[x,y,z,savepts] = mfwdtran(mstruct,lat,lon,z,'line');

%  Display the comet plot
nextmap;
if isempty(p);     comet3(x,y,z)
    else;          comet3(x,y,z,p)
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function cometmui

%  COMETMUI creates the dialog box to allow the user to enter in
%  the variable names for a cometm and comet3m commands.  It is called when
%  COMETM or COMET3M is executed with no input arguments.


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

str1 = 'lat';   str2 = 'long';   str3 = '';   str4 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = CometmUIBox(str1,str2,str3,str4);  uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.altedit,'String');
		str4 = get(h.tailedit,'String');
        delete(h.fig)

%  Construct the appropriate plotting string and assemble the callback string

        if isempty(str3) & isempty(str4)
            plotstr = ['cometm(',str1,',',str2,')'];
        elseif isempty(str3) & ~isempty(str4)
            plotstr = ['cometm(',str1,',',str2,',',str4,')'];
        elseif ~isempty(str3) & isempty(str4)
		    plotstr = ['comet3m(',str1,',',str2,',',str3,');'];
        elseif ~isempty(str3) & ~isempty(str4)
            plotstr = ['comet3m(',str1,',',str2,',',str3,',',str4,');'];
        end

	    evalin('base',plotstr,'uiwait(errordlg(lasterr))')
		if isempty(lasterr);   break;   end  %  Break loop with no errors
   else
        delete(h.fig)     %  Close the modal dialog box
		break             %  Exit the loop
   end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************

function h = CometmUIBox(lat0,lon0,alt0,prop0)

%  COMETMUIBOX creates the dialog box and places the appropriate
%  objects for the COMETMUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Comet Map Input',...
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

%  Tail Length Text and Edit Box

h.taillabel = uicontrol(h.fig,'Style','Text','String','Scalar Tail Length (optional):', ...
            'Units','Normalized','Position', [0.05  0.323  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.tailedit = uicontrol(h.fig,'Style','Edit','String', prop0, ...
            'Units','Normalized','Position', [0.05  .22  0.90  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',1,...
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
			'CallBack','maphlp1(''initialize'',''cometmui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)

