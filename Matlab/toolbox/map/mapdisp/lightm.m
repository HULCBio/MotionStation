function [hndl,msg] = lightm(varargin)

%LIGHTM  Project light objects onto the current map axes
%
%  LIGHTM activates a Graphical User Interface for projecting
%  a light object onto the current map axes.
%
%  LIGHTM(lat,lon) projects a light source positioned an infinite distance 
%  above the specified geographic location onto the current map axes.  The 
%  input latitude and longitude data must be in the same units as specified 
%  in the current map axes.  If lat and lon are vectors, then a light is 
%  projected at each element. 
%
%  LIGHTM(lat,lon,'PropertyName',PropertyValue,...) uses the
%  properties specified to define the light source.  Except
%  for 'Position', all properties are supported.
%
%  LIGHTM(lat,lon,alt) and
%  LIGHTM(lat,lon,alt,'PropertyName',PropertyValue,...) project
%  a local light source at the altitude specified by alt.
%
%  h = LIGHTM(...) returns the handles to the light objects projected.
%
%  [h,msg] = LIGHTM(...) returns an text string indicating any error
%  condition encountered.
%
%  See also LIGHT, LIGHTMUI.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.19.4.1 $  $Date: 2003/08/01 18:18:41 $

if nargin == 0
    lightmui;   return
elseif nargin < 2
    error('Incorrect number of arguments')
elseif nargin == 2;
    lat = varargin{1};     lon = varargin{2};   z = ones(size(lat));
	varargin(1:2) = [];    varargin= {'Style','Infinite'};
else
	lat = varargin{1};   lon = varargin{2};
    if isstr(varargin{3})
	    z = ones(size(lat));
		varargin(1:2) = [];
		if  isempty(varargin);     varargin= {'Style','Infinite'};
		    else;       varargin= {varargin{:},'Style','Infinite'};
		end
	else
        z = varargin{3};	   varargin(1:3) = [];
	end
end

%  Test for scalar z data

if length(z) == 1;   z = z(ones(size(lat)));   end

%  Ensure column vectors

lat = lat(:);    lon = lon(:);    z = z(:);

%  Argument size tests

if ~isequal(size(lat),size(lon),size(z))
    msg = 'Inconsistent dimensions on input data';
	if nargout < 2;  error(msg);  end
	return
end

%  Test for a map axes

[mstruct,msg] = gcm;
if ~isempty(msg)
    if nargout < 2;  error(msg);   end
	return
end

%  Project the line data

[x,y,z,savepts] = mfwdtran(mstruct,lat,lon,z,'light');

%  Display the map.

for i = 1:length(x)
   if isempty(varargin)
        hndl0(i,1) = light('Position',[x(i) y(i) z(i)],'UserData',savepts);
   else
        hndl0(i,1) = light('Position',[x(i) y(i) z(i)],'UserData',savepts,varargin{:});
   end
end

%  Set light properties if necessary

if ~isempty(varargin);  set(hndl0,varargin{:});  end

%  Set the renderer to zbuffer so that the light has an effect

set(gcf,'renderer','zbuffer')

%  Set handle return argument if necessary

if nargout ~= 0;    hndl = hndl0;   end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function lightmui

%  LIGHTMUI creates the dialog box to allow the user to enter in
%  the variable names for a lightm command.  It is called when
%  LIGHTM is executed with no input arguments.


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

str1 = 'lat';       str2 = 'long';    str3 = 'z';
clrs = [1 1 1];     mode0 = 0;        str5 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = LightmUIBox(str1,str2,str3,mode0,clrs,str5);  uiwait(h.fig)

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if ~ishandle(h.fig);   return;   end

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.altedit,'String');
		str5 = get(h.propedit,'String');
		mode0 = get(h.mode,'Value');
		clrstruct = get(h.lgtpopup,'UserData');
		clrs = clrstruct.val;
		delete(h.fig)

%  Make the other property string into a single row vector.
%  Eliminate any padding 0s since they mess up a string

		str5 = str5';   str5 = str5(:)';   str5 = str5(find(str5));

%  Set the mode string

        if mode0;    modestr = [' ''style'',''infinite'' '];
	        else;    modestr = [' ''style'',''local'' '];
	    end

%  Set the color property string then concatenate with mode string

	    clrstr =  [' ''color'', [',num2str(clrs),' ]' ];
        propstr = [modestr, ',',clrstr];

%  Construct the appropriate plotting string and assemble the callback string

	     if mode0
	          if  isempty(str5)
	               plotstr = ['lightm(',str1,',',str2,',',propstr,');'];
	          else
	               plotstr = ['lightm(',str1,',',str2,',',propstr,',',str5,');'];
	          end
	     else
	          if      isempty(str3) &  isempty(str5)
	               plotstr = ['lightm(',str1,',',str2,',',propstr,');'];
	          elseif  isempty(str3) & ~isempty(str5)
	               plotstr = ['lightm(',str1,',',str2,',',propstr,',',str5,');'];
	          elseif ~isempty(str3) &  isempty(str5)
	               plotstr = ['lightm(',str1,',',str2,',',str3,',',propstr,');'];
	          elseif ~isempty(str3) & ~isempty(str5)
	               plotstr = ['lightm(',str1,',',str2,',',str3,',',propstr,',',str5,');'];
	          end
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


function h = LightmUIBox(lat0,lon0,alt0,mode0,clr0,prop0)

%  LIGHTMUIBOX creates the dialog box and places the appropriate
%  objects for the LIGHTMUI function.


%  Construct the light color rgb values and popup menu items
%  The structure lightclr is needed to work with clrpopup

LightColors  = strvcat('custom','black','white','red','cyan','green',...
                      'yellow','blue','magenta');
lightclr.rgb = [NaN NaN NaN; 0 0 0; 1 1 1; 1 0 0; 0 1 1;
                            0 1 0; 1 1 0; 0 0 1; 1 0 1];

lightpopup = find(lightclr.rgb(:,1)==clr0(1) & lightclr.rgb(:,2)==clr0(2) & ...
                  lightclr.rgb(:,3)==clr0(3));
if isempty(lightpopup);  lightpopup = 1;  lightclr.val = clr0;
   else;                 lightclr.val = lightclr.rgb(lightpopup,:);
end

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');


%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Light Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 3.9],...
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

%  Altitude Text and Edit Box

h.altlabel = uicontrol(h.fig,'Style','Text','String','Altitude variable:', ...
            'Units','Normalized','Position', [0.05  0.625  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altedit = uicontrol(h.fig,'Style','Edit','String', alt0, ...
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

%  Mode Check Box

h.mode = uicontrol(h.fig,'Style','Check','String', 'Light at Infinity', ...
            'Units','Normalized','Position', [0.05  0.47  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Value',mode0,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Light Color Text and Popup Menu

h.lgtlabel = uicontrol(h.fig,'Style','Text','String','Color:', ...
            'Units','Normalized','Position', [0.05  0.38  0.22  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lgtpopup = uicontrol(h.fig,'Style','Popup', 'String',LightColors, ...
              'Units','Normalized', 'Position',[0.32  0.38  0.45  0.07], ...
              'Value', lightpopup, 'UserData',lightclr, ...
			  'FontWeight','bold',  'FontSize',FontScaling*10, ...
			  'HorizontalAlignment','left', 'Interruptible','on',...
			  'ForegroundColor','black', 'BackgroundColor',figclr,...
			  'CallBack','clrpopup');

%  Other Properties Text and Edit Box

h.proplabel = uicontrol(h.fig,'Style','Text','String','Other Properties:', ...
            'Units','Normalized','Position', [0.05  0.302  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.propedit = uicontrol(h.fig,'Style','Edit','String', prop0, ...
            'Units','Normalized','Position', [0.05  .16  0.90  0.14], ...
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
			'CallBack','maphlp1(''initialize'',''lightmui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)
