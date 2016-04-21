function h = quiverm(varargin)

% QUIVERM  Two dimensional quiver plot projected on a map axes
%
%  QUIVERM(lat,lon,u,v) projects two dimensional vector plot onto the current 
%  map axes.  The vectors components (u,v) are specified at the points
%  (lat,lon).  Note that both the (lat,lon) and (u,v) data must be in 
%  the same angle units as the current map.  The vector is plotted from 
%  (lat,lon) to (lat+u,lon+v).
%
%  QUIVERM(lat,lon,u,v,s) uses the input s to scale the vectors after they 
%  have been automatically scaled to fit within the rectangular grid.  If 
%  omitted, s = 1 is assumed.  To suppress the automatic scaling, specify 
%  s = 0.
%
%  QUIVERM(lat,lon,u,v,'LineSpec'), QUIVERM(lat,lon,u,v,'LineSpec',s),
%  QUIVERM(lat,lon,u,v,'LineSpec','filled') and
%  QUIVERM(lat,lon,u,v,'LineSpec',s,'filled') use the LineSpec string
%  to define the line style of the vectors.  If a symbol is specified in 
%  'LineSpec', then the symbol is plotted at the base of the vector.  
%  Otherwise, an arrow is drawn at the end of the vector.  If a marker is 
%  specified at the base, then this symbol can be filled in by providing the 
%  input string 'filled'.
%
%  QUIVERM activates a Graphical User Interface to project a quiver plot onto 
%  the current map axes.
%
%  h = QUIVERM(...)  returns a vector of handles to the projected vectors.
%
%  See also  QUIVER3M, QUIVER, QUIVER3

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.14.4.1 $  $Date: 2003/08/01 18:22:30 $
%  Written by:  E. Byrns, E. Brown



if nargin == 0
    quivermui;  return
elseif nargin < 4
    error('Incorrect number of arguments')
else
    lat = varargin{1};    lon = varargin{2};
	u   = varargin{3};    v   = varargin{4};
	varargin(1:4) = [];
end

%  Argument tests

if any([ndims(lat) ndims(lon) ...
        ndims(u)   ndims(v)  ] > 2)
    error('Input data can not contain pages')

elseif length(lat) == 1 & size(lat,1) ~= size(u,1)
    error('Lat vector input must have row dimension of u')

elseif length(lon) == 1 & size(lon,1) ~= size(u,2)
    error('Lon vector input must have column dimension of u')

elseif ~isequal(size(lat),size(lon),size(u),size(v))
	      error('Inconsistent dimensions for inputs')
end

%  Square up lat and lon if necessary

if length(lat) == 1
    lat = lat(:);     lat = lat(:,ones([size(u,2),1]));
end

if length(lon) == 1
    lon = lon(:)';     lat = lat(ones([1 size(u,1)]),:);
end

%  Parts of quiverm (quiver3m) closely parallel quiver (quiver3).
%  Unfortunately, you can not simply call quiver with projected
%  lat and lon data.  You do not get the appropriate clip and trim
%  data, which would preclude further re-projecting (using setm) of
%  the map.

%  Parse the optional input variables

switch length(varargin)
case 1
     filled = [];
     if ~isstr(varargin{1});   autoscale  = varargin{1};    linespec  = [];
	       else;               linespec   = varargin{1};    autoscale = [];
	 end

case 2
     linespec = varargin{1};
     if ~isstr(varargin{2});   autoscale  = varargin{2};    filled    = [];
	       else;               filled     = varargin{2};    autoscale = [];
	 end

case 3
     linespec = varargin{1};   autoscale = varargin{2};  filled = varargin{3};

otherwise
     linespec = [];      autoscale  = [];       filled = [];
end

%  Test for empty arguments

if isempty(autoscale);   autoscale = 1;       end
if ~isempty(linespec)
    [lstyle,lcolor,lmark,msg] = colstyle(varargin{1});
    if ~isempty(msg);   error(msg);   end
else
    lmark = [];
end

%  Autoscaling operation is taken directly from quiver.

if autoscale
  % Base autoscale value on average spacing in the lat and lon
  % directions.  Estimate number of points in each direction as
  % either the size of the input arrays or the effective square
  % spacing if lat and lon are vectors.
  if min(size(lat))==1, n=sqrt(prod(size(lat))); m=n; else [m,n]=size(lat); end
  delx = diff([min(lat(:)) max(lat(:))])/n;
  dely = diff([min(lon(:)) max(lon(:))])/m;
  len = sqrt((u.^2 + v.^2)/(delx.^2 + dely.^2));
  autoscale = autoscale*0.9 / max(len(:));
  u = u*autoscale; v = v*autoscale;
end

%  Make inputs into row vectors.  Must be done after autoscaling

lat = lat(:)';      lon = lon(:)';     u = u(:)';   v = v(:)';

%  Make the velocity vectors

vellat = [lat;  lat+u];   vellat(3,:) = NaN;
vellon = [lon;  lon+v];   vellon(3,:) = NaN;

%  Set up for the next map

nextmap;

%  Project the velocity vectors as lines only

if ~isempty(linespec)
    [h1,msg] = linem(vellat(:),vellon(:),linespec,'Marker','none');
    if ~isempty(msg);   error(msg);   end
else
    [h1,msg] = linem(vellat(:),vellon(:),'Marker','none');
    if ~isempty(msg);   error(msg);   end
end

%  Make and plot the arrow heads if necessary

alpha = 0.33;   % Size of arrow head relative to the length of the vector
beta  = 0.33;   % Width of the base of the arrow head relative to the length


h2 = [];
if isempty(lmark)
  % Make arrow heads and plot them
  hu = [lat+u-alpha*(u+beta*(v+eps));lat+u; ...
        lat+u-alpha*(u-beta*(v+eps))];       hu(4,:) = NaN;
  hv = [lon+v-alpha*(v-beta*(u+eps));lon+v; ...
        lon+v-alpha*(v+beta*(u+eps))];       hv(4,:) = NaN;

   if ~isempty(linespec)
       [h2,msg] = linem(hu(:),hv(:),linespec,'Marker','none');
       if ~isempty(msg);   error(msg);   end
   else
       [h2,msg] = linem(hu(:),hv(:),'Marker','none');
       if ~isempty(msg);   error(msg);   end
   end
end

%  Plot a marker on the base if necessary

h3 = [];
if ~isempty(lmark)
    [h3,msg] = linem(lat,lon,linespec,'LineStyle','none');
    if ~isempty(msg);   error(msg);   end
    if strcmp(filled,'filled')
	      set(h3,'MarkerFaceColor',get(h1,'color'));
	end
end

%  Set the tags

set([h1;h2;h3],'Tag','Quivers')

%  Set the output argument if necessary

if nargout == 1;    h = [h1; h2; h3];   end


%*************************************************************************
%*************************************************************************
%*************************************************************************

function quivermui

%  QUIVERMUI creates the dialog box to allow the user to enter in
%  the variable names for a quivem command.  It is called when
%  QUIVERM is executed with no input arguments.


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

str1 = 'lat';           str2 = 'long';    str3 = 'u';
str4 = 'v';             str5 = '';        str6 = '';    fill0 = 0;

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = QuivermUIBox(str1,str2,str3,str4,str5,str6,fill0);  uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.uedit,'String');
        str4 = get(h.vedit,'String');
		str5 = get(h.scledit,'String');
		str6 = get(h.lineedit,'String');
        fill0 = get(h.arrow,'Value');
		delete(h.fig)

%  Construct the appropriate plotting string and assemble the callback string

        switch fill0
	    case 0
            if isempty(str5) & isempty(str6)
               plotstr = ['quiverm(',str1,',',str2,',',str3,',',str4,')'];
            elseif isempty(str5) & ~isempty(str6)
               plotstr = ['quiverm(',str1,',',str2,',',str3,',',str4,',',str6,')'];
            elseif ~isempty(str5) & isempty(str6)
               plotstr = ['quiverm(',str1,',',str2,',',str3,',',str4,',',str5,')'];
            elseif ~isempty(str5) & ~isempty(str6)
               plotstr = ['quiverm(',str1,',',str2,',',str3,',',str4,',',str6,',',str5,')'];
            end
	    case 1
	       fillstr = [' ''filled'' '];
           if isempty(str5) & isempty(str6)
               plotstr = ['quiverm(',str1,',',str2,',',str3,',',str4,',[],',fillstr,')'];
            elseif isempty(str5) & ~isempty(str6)
               plotstr = ['quiverm(',str1,',',str2,',',str3,',',str4,',',str6,',[],',fillstr,')'];
            elseif ~isempty(str5) & isempty(str6)
               plotstr = ['quiverm(',str1,',',str2,',',str3,',',str4,',',str5,',',fillstr,')'];
            elseif ~isempty(str5) & ~isempty(str6)
               plotstr = ['quiverm(',str1,',',str2,',',str3,',',str4,',',str6,',',str5,',',fillstr,')'];
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

function h = QuivermUIBox(lat0,lon0,u0,v0,scale0,line0,fill0)

%  QUIVERMUIBOX creates the dialog box and places the appropriate
%  objects for the QUIVERMUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Quiver Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 4],...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  Latitude Text and Edit Box

h.latlabel = uicontrol(h.fig,'Style','Text','String','Latitude variable:', ...
            'Units','Normalized','Position', [0.05  0.922  0.90  0.06], ...
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
            'Units','Normalized','Position', [0.05  0.782  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonedit = uicontrol(h.fig,'Style','Edit','String', lon0, ...
            'Units','Normalized','Position', [0.05  .71  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .71  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lonedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  U Text and Edit Box

h.ulabel = uicontrol(h.fig,'Style','Text','String','U Component variable:', ...
            'Units','Normalized','Position', [0.05  0.642  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.uedit = uicontrol(h.fig,'Style','Edit','String', u0, ...
            'Units','Normalized','Position', [0.05  .57  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.ulist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .57  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.uedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  V Text and Edit Box

h.vlabel = uicontrol(h.fig,'Style','Text','String','V Component variable:', ...
            'Units','Normalized','Position', [0.05  0.502  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.vedit = uicontrol(h.fig,'Style','Edit','String', v0, ...
            'Units','Normalized','Position', [0.05  .43  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.vlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .43  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.vedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Scale Text and Edit Box

h.scllabel = uicontrol(h.fig,'Style','Text','String','Scale (optional):', ...
            'Units','Normalized','Position', [0.05  0.34  0.60  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.scledit = uicontrol(h.fig,'Style','Edit','String', scale0, ...
            'Units','Normalized','Position', [0.70  .34  0.25  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',1,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Linespec Text and Edit Box

h.linelabel = uicontrol(h.fig,'Style','Text','String','LineSpec (optional):', ...
            'Units','Normalized','Position', [0.05  0.24  0.60  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lineedit = uicontrol(h.fig,'Style','Edit','String', line0, ...
            'Units','Normalized','Position', [0.70  .24  0.25  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',1,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Filled Arrow Heads Check Box

h.arrow = uicontrol(h.fig,'Style','Check','String','Filled Base Marker', ...
            'Units','Normalized','Position', [0.05  0.14  0.60  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Value',fill0,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Buttons to exit the modal dialog

h.apply = uicontrol(h.fig,'Style','Push','String', 'Apply', ...
	        'Units', 'Normalized','Position', [0.06  0.01  0.26  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'center',...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','uiresume');

h.help = uicontrol(h.fig,'Style','Push','String', 'Help', ...
	        'Units', 'Normalized','Position', [0.37  0.01  0.26  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'center', 'Interruptible','on',...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','maphlp1(''initialize'',''quivermui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.01  0.26  0.09], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)

