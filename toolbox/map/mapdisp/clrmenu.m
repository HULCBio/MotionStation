function clrmenu(argin)

%CLRMENU Add a colormap menu to a figure window.
%
%  CLRMENU adds a colormap menu choices to the current figure.
%
%  CLRMENU(h) adds the menu choices to the figure window specified
%  by the handle h.
%
%  Each of the menu choices operates on the colormap:
%  HOT, PINK, COOL, BONE, JET, COPPER, SPRING, SUMMER, AUTUMN,
%  WINTER, FLAG and PRISM are names of functions which generate colormaps.
%  RAND is a random colormap.
%  BRIGHTEN increases the brightness.
%  DARKEN decreases the brightness.
%  FLIPUD inverts the order of the colormap entries.
%  FLIPLR interchanges the red and blue components.
%  PERMUTE cyclic permutations: red -> blue, blue -> green, green -> red.
%  SPIN spins the colormap, which is a rapid sequence of FLIPUD's.
%  DEFINE allows a workspace variable to be specied for the colormap
%  DIGITAL MAP creates a digital elevation colormap using DEMCMAP
%  POLITICAL MAP creates a political colormap using POLCMAP
%  REMEMBER pushes a copy of the current colormap onto a stack.
%  RESTORE pops a map from the stack (initially, the stack contains the
%       map in use when CLRMENU was invoked.)

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.12.4.1 $  $Date: 2003/08/01 18:17:57 $
%  Written by:  E. Byrns, E. Brown


if nargin == 1
    if isstr(argin);    colorcalls(argin);  return
	   else;            fighndl = argin;
	end
else
    fighndl = gcf;
end


%  Define the pre-stored colormaps

maps = strvcat('Gray','Hsv','Hot','Pink','Cool','Bone',...
	           'Jet','Copper','Spring','Summer','Autumn',...
				  'Winter','Flag','Prism');
h = uimenu(fighndl,'Label','Colormaps');
for k = 1:size(maps,1)
   uimenu(h,'Label',maps(k,:),...
		 'Callback',['colormap(''',lower(deblank(maps(k,:))), ''');']);
end

%  Some operations on the colormap

uimenu(h,'Label','Rand', 'Separator','on',...
         'Callback','colormap(rand([size(colormap,1),3]))');
uimenu(h,'Label','Brighten', 'Callback','brighten(.25)');
uimenu(h,'Label','Darken', 'Callback','brighten(-.25)');
uimenu(h,'Label','Flipud', 'Callback','colormap(flipud(colormap))');
uimenu(h,'Label','Fliplr', 'Callback','colormap(fliplr(colormap))');
uimenu(h,'Label','Permute', 'Callback','colormap;colormap(ans(:,[2 3 1]))');
uimenu(h,'Label','Spin','Callback','spinmap');

%  Define, remember and restore operations

uimenu(h,'Label','Define','Callback','clrmenu(''define'')',...
         'Separator','on')
uimenu(h,'Label','Digital Elevation', 'Callback','demcmap')

uimenu(h,'Label','Political', 'Callback','polcmap')

%  Remember/Restore operations

h1 = uimenu(h,'Label','Remember', 'Separator','on',...
              'Callback','set(get(gcbo,''UserData''),''UserData'',colormap)');

h2 = uimenu(h,'Label','Restore','UserData',colormap,...
              'Callback','colormap(get(gcbo,''UserData''))');
set(h1,'UserData',h2);

%  Refresh operations

uimenu(h,'Label','Refresh','Separator','on','Callback','refresh');


%*************************************************************************
%*************************************************************************
%*************************************************************************

function colorcalls(argin)

%  COLORCALLS processes selected callbacks associated with the CLRMENU.

if strcmp(argin,'define')
    fighndl = get(0,'CurrentFigure');
	 hndl = gcbo;
    colormapdlg('Colormap variable:','Define Colormap','')
    set(get(hndl,'UserData'),'UserData',get(fighndl,'Colormap'));
    refresh(fighndl)

else
    uiwait(errordlg('Unrecognized COLORCALL string','CLRMENU Error','modal'));
end


%*************************************************************************
%*************************************************************************
%*************************************************************************

function colormapdlg(prompt,titlestr,strsave)

%  COLORMAPDLG creates the dialog box to allow the user to enter in
%  the colormap variables.  It is called from CLRMENU.

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = colormapbox(prompt,titlestr,strsave);  uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

   btn = get(h.fig,'CurrentObject');
	str = get(h.txtedit,'String');   strsave = str;
	delete(h.fig)

   if btn == h.apply

%  Make multi-lines of string entry into a single row vector
%  Ensure that all quotes are doubled.  Save the original entry of
%  the other properties string in case its needed during the error loop.


	    if ~isempty(str)
	        indx = find(str == 0);     %  Replace nulls, but not blanks
            if ~isempty(indx);  str(indx) = ' ';  end
            str = str';   str = str(:)';   str = str(find(str));


       end

		 evalin('base',['colormap(',str,')'],...
			     'uiwait(errordlg(lasterr,''Colormap Error'',''modal''))');

		if isempty(lasterr);   break;   end  %  Break loop with no errors
   else
		break             %  Exit the loop
   end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function h = colormapbox(prompt,titlestr,def)

%  COLORMAPBOX creates the dialog box and places the appropriate
%  objects for the COLORMAPDLG function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name',titlestr,...
           'Units','Points',  'Position',PixelFactor*72*[2 1.5 3 1.5],...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

%  Colormap Text and Edit Box

h.txtlabel = uicontrol(h.fig,'Style','Text', 'String',prompt, ...
            'Units','Normalized', 'Position',[0.05  0.85  0.90  0.10], ...
			'FontWeight','bold', 'FontSize',FontScaling*10, ...
			'HorizontalAlignment','left',...
			'ForegroundColor','black', 'BackgroundColor', figclr);

h.txtedit = uicontrol(h.fig,'Style','Edit', 'String',def, ...
            'Units','Normalized', 'Position',[0.05  .40  0.70  0.40], ...
			'FontWeight','bold', 'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'left', 'Max',2,...
			'ForegroundColor','black', 'BackgroundColor',figclr);

h.txtlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .50  0.18  0.20], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.txtedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Buttons to exit the modal dialog

h.apply = uicontrol(h.fig,'Style','Push', 'String','Accept', ...
	        'Units','Points',  'Position',PixelFactor*72*[0.30  0.05  1.05  0.40], ...
			'FontWeight','bold',  'FontSize',FontScaling*12, ...
			'HorizontalAlignment','center', 'Tag','OK',...
			'ForegroundColor','black', 'BackgroundColor', figclr,...
			'CallBack','uiresume');

h.cancel = uicontrol(h.fig,'Style','Push', 'String','Cancel', ...
	        'Units','Points',  'Position',PixelFactor*72*[1.65  0.05  1.05  0.40], ...
			'FontWeight','bold',  'FontSize',FontScaling*12, ...
			'HorizontalAlignment','center', ...
			'ForegroundColor','black', 'BackgroundColor',figclr,...
			'CallBack','uiresume');


set(h.fig,'Visible','on');
