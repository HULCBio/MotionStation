function [out1,out2] = utmzoneui(arg)

%UTMZONEUI  UTM zone picker
%
%  ZONE = UTMZONEUI will create an interface for choosing a UTM zone on a world
%  display map.  It allows for clicking on an area for its appropriate zone, or 
%  entering a valid zone to identify the zone on the map.
%
%  ZONE = UTMZONEUI(InitZone) will initialize the displayed zone to the zone 
%  string given in INITZONE.
%
%  [ZONE,MSG] = UTMZONEUI(...) adds a message if the utm zone is invalid.

%  Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.3.4.1 $
%  Written by A. Kim


msg = [];

if nargin == 0
	action = []; initzone = [];
elseif nargin == 1
	if length(arg)>3	% action string
		initzone = []; action = arg;
	else	% initial zone
		[latlim,lonlim,msg] = utmzone(upper(arg));
		if isempty(msg)
			initzone = upper(arg); action = [];
		else
			error('Invalid UTM zone designation')
		end
	end
end

zone = [];

if isempty(action),	action = 'initialize'; end

latzones = char([67:72 74:78 80:88]');

if strcmp(action,'initialize')

	hndl = initgui(initzone);
	set(gcf,'UserData',hndl)

	set(gca,'ButtonDownFcn','utmzoneui(''zoneclick'');');	%  Disable default button down function
	hch = get(gca,'Children');
	set(hch,'ButtonDownFcn','utmzoneui(''zoneclick'');');	%  Disable default button down function

	while 1

		uiwait(hndl.fig);
		if ~ishandle(hndl.fig);  return;   end

		btn = get(hndl.fig,'CurrentObject');

		zone = upper(get(hndl.zoneedit,'String'));
		[latlim,lonlim,msg] = utmzone(zone);

		if isempty(btn)
			disp('???')
		elseif btn==hndl.zoneedit

			hndl = get(gcf,'UserData');
			hboxold = get(hndl.zoneedit,'UserData');

			if ~isempty(msg)   %  Error condition
				uiwait(errordlg(msg,'Invalid Zone','modal'))
			else         %  Valid zone
				if ~isempty(hboxold),  delete(hboxold),  end
				ltbox = [latlim(1) latlim(2) latlim(2) latlim(1) latlim(1)];
				lnbox = [lonlim(1) lonlim(1) lonlim(2) lonlim(2) lonlim(1)];
				hbox = patchm(ltbox,lnbox,-1,[1 .2 .2]);

				set(hndl.zoneedit,'String',zone)
				set(hndl.zoneedit,'UserData',hbox)
			end

		elseif btn==hndl.apply

			hndl = get(gcf,'UserData');

			if isempty(msg)
				zone = upper(get(hndl.zoneedit,'String'));
			else
				zone = [];
			end

 			delete(hndl.fig)
 			break

		else	% cancel button pushed

			zone = initzone;	msg = [];
			delete(hndl.fig)
			break

		end
	
	end

elseif strcmp(action,'zoneclick')

	hndl = get(gcf,'UserData');
	hboxold = get(hndl.zoneedit,'UserData');

	mat = gcpmap; lt = mat(1,1); ln = mat(1,2);
	mat2 = get(gca,'CurrentPoint');

	[zone,msg] = utmzone(lt,ln);
	
	if mat2(1,1)>pi | mat2(1,1)<-pi
		msg = 'Coordinates not within UTM zone limits';
	end

	if ~isempty(msg)   %  Error condition
		zone = [];
		uiwait(errordlg(msg,'Invalid Zone','modal'))
	else         %  Valid zone
		[latlim,lonlim,msg] = utmzone(zone);
		if ~isempty(hboxold),  delete(hboxold),  end
		ltbox = [latlim(1) latlim(2) latlim(2) latlim(1) latlim(1)];
		lnbox = [lonlim(1) lonlim(1) lonlim(2) lonlim(2) lonlim(1)];
		hbox = patchm(ltbox,lnbox,-1,[1 .2 .2]);

		set(hndl.zoneedit,'String',zone)
		set(hndl.zoneedit,'UserData',hbox)
	end

	set(gcf,'UserData',hndl)

elseif strcmp(action,'help')

	hndl = get(gcf,'UserData');

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

	PixelFactor = guifactm('pixels');
	FontScaling =  guifactm('fonts');

%  Create the help dialog box.  Make visible when all objects are drawn

    hndl.helpfig = figure('Name','', 'Units','Points', ...
					'Position',PixelFactor*72*[0.75 0.12 7 2.0],...
					'Tag','MapHelpWindow', 'Visible','off',...
					'NumberTitle','off', 'CloseRequestFcn','',...
					'IntegerHandle','off');
    colordef(hndl.helpfig,'white');
    figclr = get(hndl.helpfig,'Color');

	hndl.windowstyle = get(hndl.fig,'WindowStyle');
	if ~strcmp(computer,'MAC2') & ~strcmp(computer,'PCWIN')
		set(hndl.fig,'WindowStyle','normal')
	end

	if strcmp(computer,'MAC2') 
    	set(hndl.helpfig,'WindowStyle','modal')
	end

	str1 = ['Click on any area on the map to display its UTM zone, or ',...
		   'enter a vaid UTM zone designation in the edit box.  ',...
		   'Recognized zones are integers from 1 to 60 or numbers ',...
		   'followed by letters from C to X.'];
	str2 = 'Press "Close" to Exit Help';
    hndl.helptext = uicontrol(hndl.helpfig,'Style','Text',...
            'String',{str1,' ',str2}, ...
            'Units','Normalized', 'Position',[0.05  0.05  0.90  0.90], ...
            'FontWeight','bold',  'FontSize',FontScaling*10, ...
            'HorizontalAlignment', 'left',...
            'ForegroundColor','black', 'BackgroundColor', figclr);

    hndl.closebtn = uicontrol(hndl.helpfig,'Style','push',...
            'String','Close', 'Units','Normalized', ...
			'Position',[.8  0.1  .15  .2], ...
            'FontWeight','bold',  'FontSize',FontScaling*10, ...
            'HorizontalAlignment', 'left',...
	        'BackgroundColor',figclr, 'ForegroundColor','black',...
			'Callback','utmzoneui(''close'')');

	set(hndl.helpfig,'Visible','on')

	set(gcf,'UserData',hndl)

elseif strcmp(action,'close')

	hndl = get(gcf,'UserData');
	delete(hndl.helpfig)
	set(hndl.fig,'WindowStyle',hndl.windowstyle)

end

if isempty(zone),	zone = [];	end

if nargin==0 | (nargin==1 & length(arg)<=3)
	out1 = zone;
	if nargout==2
		out2 = msg;
	end
end



%**************************************************************************
%**************************************************************************
%**************************************************************************

function h = initgui(initzone)

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

h.fig = figure('NumberTitle','off', 'Name','Pick UTM Zone', ...
       'Units','Points', 'Position',PixelFactor*[96 128 894 616], ...
       'Resize','off', 'WindowStyle','modal', 'Visible','off');
%
%adjust window position if corners are offscreen
%
shiftwin(h.fig)

colordef(h.fig,'white')
figclr = get(h.fig,'Color');
frameclr = brighten(figclr,0.5);

%  Display map of world with utm zone designations

load worldlo

lts = [-80:8:72 84]';
lns = [-180:6:180]';
latzones = char([67:72 74:78 80:88]');

axesm('miller','maplatlim',[-80 84],'maplonlim',[-180 180],...
	  'mlinelocation',lns,'plinelocation',lts,...
	  'mlabellocation',-180:24:180,'plabellocation',lts)
framem; gridm; mlabel; plabel
set(gca,'position',[.02 .12 .96 .87],'xlim',[-3.5 3.3],'ylim',[-2 2.2])

hPO = displaym(POline);
set(hPO(1),'Color','k')

if ~isempty(initzone)
	[latlim,lonlim,msg] = utmzone(initzone);
	ltbox = [latlim(1) latlim(2) latlim(2) latlim(1) latlim(1)];
	lnbox = [lonlim(1) lonlim(1) lonlim(2) lonlim(2) lonlim(1)];
	hbox = patchm(ltbox,lnbox,-1,[1 .2 .2]);
else
	hbox = [];
end

%  Set up gui display below map

uicontrol(h.fig, 'Style','frame', ...
	             'Units','normalized', 'Position',[0.2 0.02 0.15 0.08], ...
	             'FontSize',FontScaling*12, 'FontWeight','bold', ...
	             'BackgroundColor',frameclr, 'ForegroundColor','black');

uicontrol(h.fig, 'Style','text', 'String','Zone:', ...
	             'Units','normalized', 'Position',[0.21 0.03 0.065 0.05], ...
	             'FontSize',FontScaling*12, 'FontWeight','bold', ...
	             'HorizontalAlignment','left',  ...
	             'BackgroundColor',figclr, 'ForegroundColor','black');

h.zoneedit = uicontrol(h.fig, 'Style','edit', 'String',initzone, ...
	             'Units','normalized', 'Position',[0.28 .035 0.06 0.05], ... 
	             'FontSize',FontScaling*12,    'FontWeight','bold', ...
	             'HorizontalAlignment','center', 'UserData',hbox, ...
	             'BackgroundColor',figclr, 'ForegroundColor','red', ...
				 'CallBack','uiresume');

h.apply = uicontrol(h.fig, 'Style','push', 'String','Accept', ...
	        'Units','normalized', 'Position',[0.46 0.02 0.1 0.08], ...
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*12, ...
			'FontWeight','bold', 'CallBack','uiresume');

h.help = uicontrol(h.fig, 'Style','push', 'String','Help', ...
	        'Units','normalized', 'Position',[0.58 0.02 0.1 0.08], ... 
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*12, ...
			'FontWeight','bold',  'Interruptible','on', ...
			'CallBack','utmzoneui(''help'')');

h.cancel = uicontrol(h.fig, 'Style','push', 'String','Cancel', ...
	        'Units','normalized', 'Position',[0.7 0.02 0.1 0.08], ...  
	        'ForegroundColor','black', 'BackgroundColor',figclr, ...
	        'FontName','Helvetica', 'FontSize',FontScaling*12, ...
			'FontWeight','bold', 'CallBack','uiresume');

set(h.fig,'Visible','on')


