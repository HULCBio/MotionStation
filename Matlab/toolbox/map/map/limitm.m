function [lat, lon] = limitm(map,maplegend)

%LIMITM  Latitude and longitude limits for a regular matrix map
%
%  [lat,lon] = LIMITM(map,maplegend) returns the Greenwich frame
%  latitude  and longitude limits of a regular matrix map.
%
%  mat = LIMITM(...) returns a single output, where mat = [lat lon].
%
%  LIMITM activates a Graphical User Interface for the computation
%  of the map limits.
%
%  See also SIZEM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.13.4.1 $  $Date: 2003/08/01 18:16:54 $


if nargin == 0
     limitmui;   return
elseif nargin ~= 2
     error('Incorrect number of arguments')
end

%  Input dimension tests

if ndims(map) > 2
    error('Input map can not have pages')

elseif ~isequal(sort(size(maplegend)),[1 3])
    error('Input maplegend must be a 3 element vector')

elseif ~isreal(maplegend)
    warning('Imaginary parts of complex MAPLEGEND argument ignored')
	maplegend = real(maplegend);
end


%  Compute the latitude limits

[n,m] = size(map);
startlat  = maplegend(2) - n/maplegend(1);
endlat    = maplegend(2);

%  Compute the longitude limits

startlon = maplegend(3);
endlon   = maplegend(3) + m/maplegend(1);

%  Construct the output variables.
%  The outputs are fixed at 6 significant digits to
%  eliminate potential round-off errors.

lat = roundn([startlat  endlat],-6);
lon = roundn([startlon  endlon],-6);

%  Set the output matrix if necessary

if nargout ~= 2;   lat = [lat lon];   end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function limitmui

%  LIMITMUI creates the dialog box to allow the user to enter in
%  the variable names for a limitm command.  It is called when
%  LIMITM is executed with no input arguments.


%  Initialize the entries of the dialog box

str1 = 'map';   str2 = 'maplegend';   str3 = 'latlim';   str4 = 'lonlim';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = LimitmUIBox(str1,str2,str3,str4);  uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.mapedit,'String');    %  Get the dialog entries
		str2 = get(h.legedit,'String');
        str3 = get(h.latedit,'String');
		str4 = get(h.lonedit,'String');
        delete(h.fig)

%  Construct the appropriate plotting string and assemble the callback string

        fcnstr = ['[',str3,',',str4,']=limitm(',str1,',',str2,');'];

	    evalin('base',fcnstr,...
		        'uiwait(errordlg(lasterr,''Map Limit Computation'',''modal''))')
		if isempty(lasterr);   break;   end  %  Break loop with no errors
   else
        delete(h.fig)     %  Close the modal dialog box
		break             %  Exit the loop
   end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************

function h = LimitmUIBox(map0,maplegend0,lat0,lon0)

%  LIMITMUIBOX creates the dialog box and places the appropriate
%  objects for the LIMITMUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Map Limit Input',...
           'Units','Points',  'Position',PixelFactor*72*[2.5 1.5 3 3.3],...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  Map Text and Edit Box

h.maplabel = uicontrol(h.fig,'Style','Text','String','Map variable:', ...
            'Units','Normalized','Position', [0.05  0.91  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.mapedit = uicontrol(h.fig,'Style','Edit','String', map0, ...
            'Units','Normalized','Position', [0.05  .82  0.70  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.maplist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .82  0.18  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.mapedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Maplegend Text and Edit Box

h.leglabel = uicontrol(h.fig,'Style','Text','String','Maplegend variable:', ...
            'Units','Normalized','Position', [0.05  0.722  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.legedit = uicontrol(h.fig,'Style','Edit','String', maplegend0, ...
            'Units','Normalized','Position', [0.05  .63  0.70  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.leglist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .63  0.18  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.legedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Latitude Text and Edit Box

h.latlabel = uicontrol(h.fig,'Style','Text','String','Output Latitude limit:', ...
            'Units','Normalized','Position', [0.05  0.502  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latedit = uicontrol(h.fig,'Style','Edit','String', lat0, ...
            'Units','Normalized','Position', [0.05  .41  0.70  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .41  0.18  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.latedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Longitude Text and Edit Box

h.lonlabel = uicontrol(h.fig,'Style','Text','String','Output Longitude limit:', ...
            'Units','Normalized','Position', [0.05  0.303  0.90  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonedit = uicontrol(h.fig,'Style','Edit','String', lon0, ...
            'Units','Normalized','Position', [0.05  .20  0.70  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .20  0.18  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lonedit,...
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
			'CallBack','maphlp1(''initialize'',''limitmui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)

