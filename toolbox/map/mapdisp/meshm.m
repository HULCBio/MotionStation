function [hndl,msg] = meshm(varargin)

%MESHM  Display a regular matrix map warped to a projected graticule
%
%  MESHM(map,maplegend) will display the regular matrix map warped
%  to the default projection graticule.  The current axes must have a
%  valid map projection definition.
%
%  MESHM(map,maplegend,gsize) displays a regular matrix map warped to a
%  graticule mesh defined by gsize.  GSIZE must be a 2 element vector
%  specifying the number of latitude graticule lines, gsize(1), and the
%  number of longitude graticule lines, gsize(2).
%
%  MESHM(map,maplegend,gsize,alt) displays the regular surface map at
%  the altitude specified by alt.  If alt is a scalar, then the map is
%  drawn in the z = alt plane.  If alt is a matrix, then size(alt) must
%  equal gsize, and the graticule mesh is drawn at the altitudes specified
%  by alt.  If the default graticule is desired, set gsize = [].
%
%  MESHM(map,maplegend,'PropertyName',PropertyValue,...) and
%  MESHM(map,maplegend,gsize,'PropertyName',PropertyValue,...) and
%  MESHM(map,maplegend,gsize,alt,'PropertyName',PropertyValue,...) display
%  regular matrix map using the specified surface properties.  If data is
%  placed in the UserData property of the surface, then the projection of
%  this object can not be altered once displayed.
%
%  h = MESHM(...) returns the handle to the surface drawn.
%
%  MESHM, without any inputs, activates a GUI for projecting regular surfaces
%  onto the current axes.
%
%  See also SURFM, SURFACEM, PCOLORM, MESHGRAT

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.17.4.1 $  $Date: 2003/08/01 18:18:57 $

if nargout ~= 0;   hndl = [];   msg = [];   end   %  Initialize outputs

if nargin == 0
     meshmui;   return

elseif nargin < 2
     error('Incorrect number of arguments')

else
     map = varargin{1};     maplegend = varargin{2};
     varargin(1:2) = [];

	 npts = [];
     if ~isempty(varargin) & ~isstr(varargin{1})
	          npts = varargin{1};  varargin(1) = [];
	 end

     alt = [];
	 if ~isempty(varargin) & ~isstr(varargin{1})
	          alt = varargin{1};   varargin(1) = [];
	 end
end

%  Argument tests

if length(maplegend(:)) ~= 3;
	error('Map legend must be a three-element vector');
end

%
% Note: code below to be added for proper alignment of map with graticule equal to 
% size of map. If shading interp is the final display mode, may need to shift the 
% matrix over by half a cell, i.e. add 
%
%    maplegend(2) = maplegend(2) + (0.5/maplegend(1));
%    maplegend(3) = maplegend(3) + (0.5/maplegend(1));
%
% (There is a visual shift because the matlab convention for displaying 
%  surfaces - displaying color for corner of cell, and dropping 2 edges -
%  is not followed with shading interp


%  Compute the graticule. 

% If size(graticule) = size(map), pad the map to avoid misalignment
% between texture-mapped and normal surfaces
    
if isequal(npts,size(map))
    sz = size(map);
    try
        [lat,lon] = meshgrat(map,maplegend,npts+[1 1]);
    catch
        error(lasterr);
    end
    map = [ [map map(:,sz(2))] ; [map(sz(1),:) map(sz(1),sz(2)) ]];
    if ~isempty(alt)
        alt = [ [alt alt(:,sz(2))] ; [alt(sz(1),:) alt(sz(1),sz(2)) ]];
    end
else 
    try
        [lat,lon] = meshgrat(map,maplegend,npts);
    catch
        error(lasterr);
    end
end

%  Test for empty altitude

if isempty(alt);   alt = zeros(size(lat));   end

%  Display the map

nextmap;
if ~isempty(varargin)
    [hndl0,msg] = surfacem(lat,lon,map,alt,varargin{:});
else
    [hndl0,msg] = surfacem(lat,lon,map,alt);
end

if ~isempty(msg)
   if nargout < 2;      error(msg);
      else;             return;
   end
end

%  Save the map legend

mapdata = get(hndl0,'UserData');
mapdata.maplegend = maplegend;
set(hndl0,'UserData',mapdata);

%  Set handle return argument if necessary

if nargout ~= 0;   hndl = hndl0;    end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function meshmui

%  MESHMUI creates the dialog box to allow the user to enter in
%  the variable names for a meshm command.  It is called when
%  MESHM is executed with no input arguments.


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

str1 = 'map';           str2 = 'maplegend';
str3 = '[50 100]';      str4 = '';             str5 = '';

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = MeshmUIBox(str1,str2,str3,str4,str5);  uiwait(h.fig)

    if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.mapedit,'String');    %  Get the dialog entries
		str2 = get(h.legedit,'String');
        str3 = get(h.nptsedit,'String');
        str4 = get(h.altedit,'String');
		str5 = get(h.propedit,'String');
		delete(h.fig)

%  Make the other property string into a single row vector.
%  Eliminate any padding 0s since they mess up a string

		str5 = str5';   str5 = str5(:)';   str5 = str5(find(str5));

%  Construct the appropriate plotting string and assemble the callback string

        if isempty(str4) & isempty(str5)
            plotstr = ['meshm(',str1,',',str2,',',str3,')'];
        elseif isempty(str4) & ~isempty(str5)
            plotstr = ['meshm(',str1,',',str2,',',str3,',',str5,')'];
        elseif ~isempty(str4) & isempty(str5)
            plotstr = ['meshm(',str1,',',str2,',',str3,',',str4,')'];
        elseif ~isempty(str4) & ~isempty(str5)
            plotstr = ['meshm(',str1,',',str2,',',str3,',',str4,',',str5,');'];
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

function h = MeshmUIBox(map0,maplegend0,npts0,alt0,prop0)

%  MESHMUIBOX creates the dialog box and places the appropriate
%  objects for the MESHMUI function.

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Mesh Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 3.7], ...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');


% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  Map Text and Edit Box

h.maplabel = uicontrol(h.fig,'Style','Text','String','Map variable:', ...
            'Units','Normalized','Position', [0.05  0.925  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.mapedit = uicontrol(h.fig,'Style','Edit','String', map0, ...
            'Units','Normalized','Position', [0.05  .85  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.maplist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .85  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.mapedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Maplegend Text and Edit Box

h.leglabel = uicontrol(h.fig,'Style','Text','String','Maplegend variable:', ...
            'Units','Normalized','Position', [0.05  0.775  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.legedit = uicontrol(h.fig,'Style','Edit','String', maplegend0, ...
            'Units','Normalized','Position', [0.05  .70  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.leglist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .70  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.legedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Npts Text and Edit Box

h.nptslabel = uicontrol(h.fig,'Style','Text','String','Graticule size variable:', ...
            'Units','Normalized','Position', [0.05  0.625  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.nptsedit = uicontrol(h.fig,'Style','Edit','String', npts0, ...
            'Units','Normalized','Position', [0.05  .55  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.nptslist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .55  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.nptsedit,...
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
			'CallBack','maphlp1(''initialize'',''meshmui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.02  0.26  0.10], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)

