function h = quiver3m(varargin)

% QUIVER3M  Three dimensional quiver plot projected on a map axes
%
%  QUIVER3M(lat,lon,alt,u,v,w) projects three dimensional vector plot onto 
%  the current map axes.  The vectors components (u,v,w) are specified at the 
%  points (lat,lon,alt).  Note that both the (lat,lon) and (u,v) data must be 
%  in the same angle units as the current map.  The units of alt and w must 
%  be consistent, since these components will be used to define the altitude 
%  of the vector above the map.  The vector is plotted from (lat,lon,alt) to 
%  (lat+u,lon+v,alt+w).
%
%  QUIVER3M(lat,lon,alt,u,v,w,s) uses the input s to scale the velocity
%  vectors after they have been automatically scaled to fit within
%  the rectangular grid.  If omitted, s = 1 is assumed.  To suppress
%  the automatic scaling, specify s = 0.
%
%  QUIVER3M(lat,lon,alt,u,v,w,'LineSpec'),
%  QUIVER3M(lat,lon,alt,u,v,w,'LineSpec',s),
%  QUIVER3M(lat,lon,alt,u,v,w,'LineSpec','filled') and
%  QUIVER3M(lat,lon,alt,u,v,w,'LineSpec',s,'filled') use the LineSpec
%  string to define the line style of the velocity vectors.  If a symbol
%  is specified in 'LineSpec', then the symbol is plotted at the
%  base of the velocity vector.  Otherwise, an arrow is drawn at
%  the end of the velocity vector.  If a marker is specified at
%  the base, then this symbol can be filled in by providing
%  the input string 'filled'.
%
%  QUIVER3M activates a Graphical User Interface to project a quiver
%  plot onto the current map axes.
%
%  h = QUIVER3M(...) returns a vector of handles to the projected
%  velocity vectors.
%
%  See also  QUIVERM, QUIVER, QUIVER3

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.15.4.1 $  $Date: 2003/08/01 18:22:29 $
%  Written by:  E. Byrns, E. Brown



if nargin == 0
    quiver3mui;  return
elseif nargin < 6
    error('Incorrect number of arguments')
else
    lat = varargin{1};    lon = varargin{2};     alt = varargin{3};
	u   = varargin{4};    v   = varargin{5};     w   = varargin{6};
	varargin(1:6) = [];
end

%  Argument tests

if any([ndims(lat) ndims(lon) ndims(alt) ...
        ndims(u)   ndims(v)   ndims(w) ] > 2)
    error('Input data can not contain pages')

elseif ~isequal(size(lat),size(lon),size(alt),size(u),size(v),size(w))
	      error('Inconsistent dimensions for inputs')
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

%  Autoscaling operation is taken directly from quiver3.

if autoscale
  % Base autoscale value on average spacing in the lat and lon
  % directions.  Estimate number of points in each direction as
  % either the size of the input arrays or the effective square
  % spacing if lat and lon are vectors.
  if min(size(lat))==1, n=sqrt(prod(size(lat))); m=n; else [m,n]=size(lat); end
  delx = diff([min(lat(:)) max(lat(:))])/n;
  dely = diff([min(lon(:)) max(lon(:))])/m;
  delz = diff([min(alt(:)) max(alt(:))])/max(m,n);
  del  = sqrt(delx.^2 + dely.^2 + delz.^2);
  len  = sqrt((u/del).^2 + (v/del).^2 + (w/del).^2);
  autoscale = autoscale*0.9 / max(len(:));
  u = u*autoscale; v = v*autoscale;; w = w*autoscale;
end

%  Make inputs into row vectors.  Must be done after autoscaling

lat = lat(:)';      lon = lon(:)';     alt = alt(:)';
u   = u(:)';        v   = v(:)';       w   = w(:)';

%  Make the velocity vectors

vellat = [lat;  lat+u];   vellat(3,:) = NaN;
vellon = [lon;  lon+v];   vellon(3,:) = NaN;
velalt = [alt;  alt+w];   velalt(3,:) = NaN;

%  Set up for the next map

nextmap;

%  Project the velocity vectors as lines only

if ~isempty(linespec)
    [h1,msg] = linem(vellat(:),vellon(:),velalt(:),linespec,'Marker','none');
    if ~isempty(msg);   error(msg);   end
else
    [h1,msg] = linem(vellat(:),vellon(:),velalt(:),'Marker','none');
    if ~isempty(msg);   error(msg);   end
end

%  Make and plot the arrow heads if necessary

alpha = 0.33;   % Size of arrow head relative to the length of the vector
beta  = 0.33;   % Width of the base of the arrow head relative to the length


h2 = [];
if isempty(lmark)
% Normalize beta

  beta = beta * sqrt(u.*u + v.*v + w.*w)/sqrt(u.*u + v.*v + eps*eps);

% Make arrow heads and plot them
  hu = [lat+u-alpha*(u+beta*(v+eps));lat+u; ...
        lat+u-alpha*(u-beta*(v+eps))];       hu(4,:) = NaN;
  hv = [lon+v-alpha*(v-beta*(u+eps));lon+v; ...
        lon+v-alpha*(v+beta*(u+eps))];       hv(4,:) = NaN;
  hw = [alt+w-alpha*w;alt+w;alt+w-alpha*w];  hw(4,:) = NaN;

   if ~isempty(linespec)
       [h2,msg] = linem(hu(:),hv(:),hw(:),linespec,'Marker','none');
       if ~isempty(msg);   error(msg);   end
   else
       [h2,msg] = linem(hu(:),hv(:),hw(:),'Marker','none');
       if ~isempty(msg);   error(msg);   end
   end
end

%  Plot a marker on the base if necessary

h3 = [];
if ~isempty(lmark)
    [h3,msg] = linem(lat,lon,alt,linespec,'LineStyle','none');
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

function quiver3mui

%  QUIVER3MUI creates the dialog box to allow the user to enter in
%  the variable names for a quiver3m command.  It is called when
%  QUIVER3M is executed with no input arguments.


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

str1 = 'lat';           str2 = 'long';    str3 = 'alt';
str4 = 'u';             str5 = 'v';       str6 = 'w';
str7 = '';              str8 = '';        fill0 = 0;

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = Quiver3mUIBox(str1,str2,str3,str4,str5,str6,str7,str8,fill0);  uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.altedit,'String');
        str4 = get(h.uedit,'String');
        str5 = get(h.vedit,'String');
        str6 = get(h.wedit,'String');
		str7 = get(h.scledit,'String');
		str8 = get(h.lineedit,'String');
        fill0 = get(h.arrow,'Value');
		delete(h.fig)

%  Construct the appropriate plotting string and assemble the callback string

        switch fill0
	    case 0
           if isempty(str7) & isempty(str8)
               plotstr = ['quiver3m(',str1,',',str2,',',str3,',',str4,',',...
			                          str5,',',str6,')'];
            elseif isempty(str7) & ~isempty(str8)
               plotstr = ['quiver3m(',str1,',',str2,',',str3,',',str4,',',...
			                          str5,',',str6,',',str8,')'];
            elseif ~isempty(str7) & isempty(str8)
               plotstr = ['quiver3m(',str1,',',str2,',',str3,',',str4,',',...
			                         str5,',',str6,',',str7,')'];
            elseif ~isempty(str7) & ~isempty(str8)
               plotstr = ['quiver3m(',str1,',',str2,',',str3,',',str4,',',...
			                         str5,',',str6,',',str8,',',str7,')'];
            end
	    case 1
	       fillstr = [' ''filled'' '];
           if isempty(str7) & isempty(str8)
               plotstr = ['quiver3m(',str1,',',str2,',',str3,',',str4,',',...
			                          str5,',',str6,',[],',fillstr,')'];
            elseif isempty(str7) & ~isempty(str8)
               plotstr = ['quiver3m(',str1,',',str2,',',str3,',',str4,',',...
			                          str5,',',str6,',',str8,',[],',fillstr,')'];
            elseif ~isempty(str7) & isempty(str8)
               plotstr = ['quiver3m(',str1,',',str2,',',str3,',',str4,',',...
			                          str5,',',str6,',',str7,',',fillstr,')'];
            elseif ~isempty(str7) & ~isempty(str8)
               plotstr = ['quiver3m(',str1,',',str2,',',str3,',',str4,',',...
			                          str5,',',str6,',',str8,',',str7,',',fillstr,')'];
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

function h = Quiver3mUIBox(lat0,lon0,alt0,u0,v0,w0,scale0,line0,fill0)

%  QUIVER3MUIBOX creates the dialog box and places the appropriate
%  objects for the QUIVER3MUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Quiver3 Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 4.5],...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  Latitude Text and Edit Box

h.latlabel = uicontrol(h.fig,'Style','Text','String','Latitude variable:', ...
            'Units','Normalized','Position', [0.05  0.942  0.90  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latedit = uicontrol(h.fig,'Style','Edit','String', lat0, ...
            'Units','Normalized','Position', [0.05  .88  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .88  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.latedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Longitude Text and Edit Box

h.lonlabel = uicontrol(h.fig,'Style','Text','String','Longitude variable:', ...
            'Units','Normalized','Position', [0.05  0.822  0.90  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonedit = uicontrol(h.fig,'Style','Edit','String', lon0, ...
            'Units','Normalized','Position', [0.05  .76  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .76  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lonedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Altitude Text and Edit Box

h.altlabel = uicontrol(h.fig,'Style','Text','String','Altitude variable:', ...
            'Units','Normalized','Position', [0.05  0.702  0.90  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altedit = uicontrol(h.fig,'Style','Edit','String', alt0, ...
            'Units','Normalized','Position', [0.05  .64  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.altlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .64  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.altedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  U Text and Edit Box

h.ulabel = uicontrol(h.fig,'Style','Text','String','U Component variable:', ...
            'Units','Normalized','Position', [0.05  0.582  0.90  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.uedit = uicontrol(h.fig,'Style','Edit','String', u0, ...
            'Units','Normalized','Position', [0.05  .52  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.ulist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .52  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.uedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  V Text and Edit Box

h.vlabel = uicontrol(h.fig,'Style','Text','String','V Component variable:', ...
            'Units','Normalized','Position', [0.05  0.462  0.90  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.vedit = uicontrol(h.fig,'Style','Edit','String', v0, ...
            'Units','Normalized','Position', [0.05  .40  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.vlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .40  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.vedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  W Text and Edit Box

h.wlabel = uicontrol(h.fig,'Style','Text','String','W Component variable:', ...
            'Units','Normalized','Position', [0.05  0.342  0.90  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.wedit = uicontrol(h.fig,'Style','Edit','String', w0, ...
            'Units','Normalized','Position', [0.05  .28  0.70  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.wlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .28  0.18  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.wedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Scale Text and Edit Box

h.scllabel = uicontrol(h.fig,'Style','Text','String','Scale (optional):', ...
            'Units','Normalized','Position', [0.05  0.22  0.60  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.scledit = uicontrol(h.fig,'Style','Edit','String', scale0, ...
            'Units','Normalized','Position', [0.70  .22  0.25  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',1,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Linespec Text and Edit Box

h.linelabel = uicontrol(h.fig,'Style','Text','String','LineSpec (optional):', ...
            'Units','Normalized','Position', [0.05  0.15  0.60  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lineedit = uicontrol(h.fig,'Style','Edit','String', line0, ...
            'Units','Normalized','Position', [0.70  .15  0.25  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',1,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Filled Arrow Heads Check Box

h.arrow = uicontrol(h.fig,'Style','Check','String','Filled Base Marker', ...
            'Units','Normalized','Position', [0.05  0.08  0.60  0.05], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Value',fill0,...
			'ForegroundColor', 'black','BackgroundColor', figclr);


%  Buttons to exit the modal dialog

h.apply = uicontrol(h.fig,'Style','Push','String', 'Apply', ...
	        'Units', 'Normalized','Position', [0.06  0.01  0.26  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'center',...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','uiresume');

h.help = uicontrol(h.fig,'Style','Push','String', 'Help', ...
	        'Units', 'Normalized','Position', [0.37  0.01  0.26  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'center', 'Interruptible','on',...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','maphlp1(''initialize'',''quiver3mui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.01  0.26  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)
