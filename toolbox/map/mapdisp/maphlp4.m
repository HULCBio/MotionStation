function maphlp4(varargin)

%MAPHLP4  Mapping Toolbox Help Utility for Selected GUIs
%
%  MAPHLP4 enables the help utility for the GUIs listed below.
%  It also processes the help callbacks and restores the
%  calling dialog to its original state (pre-help call).
%
%  MAPHLP4 contains the help utilities for:
%        meshlsrmui, surflsrmui, demcmapui
%
%        These functions are local functions contained in the
%        m-file specified by dropping the "ui" characters in the
%        above names.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.12.4.3 $  $Date: 2004/02/01 21:58:13 $
%  Written by:  E. Byrns, E. Brown


%  1 or 2 arguments may be supplied to this function.  The
%  first argument is the action string for the switch yard below.
%  The second argument identifies the calling dialog and is used
%  by CustomInit and CustomDone to properly customize the help utility.

%  The help utility change static text to push buttons and then
%  associates the proper callback with these new buttons.  All other
%  dialog controls are disabled.  Upon termination of the utility, the
%  push buttons are returned to their original style.

switch varargin{1}
case 'initialize'
    h = get(get(0,'CurrentFigure'),'UserData');  %  Get the object handles
    set(h.fig,'CloseRequestFcn','maphlp4(''forceclose'')' )
	 if ~strcmp(computer,'MAC2') & ~strcmp(computer,'PCWIN')
            set(h.fig,'WindowStyle','normal')
	 end

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

    PixelFactor = guifactm('pixels');
    FontScaling =  guifactm('fonts');

%  Create the help dialog box.  Make visible when all objects are drawn

    h.helpfig = figure('Name','',...
                'Units','Points',  'Position',PixelFactor*72*[5.3 1.4 2.7 2.9],...
                'Tag','MapHelpWindow', 'Visible','off',...
                'NumberTitle','off', 'CloseRequestFcn','',...
					 'IntegerHandle','off');
    colordef(h.helpfig,'white');
    figclr = get(h.helpfig,'Color');
	 if strcmp(computer,'MAC2') 
            set(h.helpfig,'WindowStyle','modal')
	 end

%  Initialize the help text object

    str1 = 'Press Any Button (excluding "Done") for Help';
    str2 = 'Press "Done" to Exit Help';
    h.helptext = uicontrol(h.helpfig,'Style','Text',...
	        'String',{str1,' ',str2}, ...
            'Units','Normalized','Position', [0.05  0.05  0.90  0.90], ...
            'FontWeight','bold',  'FontSize',FontScaling*10, ...
            'HorizontalAlignment', 'left',...
            'ForegroundColor', 'black','BackgroundColor', figclr);

    CustomInit(varargin{2},h)   %  Customize the help callbacks

    set(h.fig,'WindowStyle','modal')
    set(h.helpfig,'Visible','on')   %  Turn help window on
    set(h.fig,'UserData',h)         %  Save the additional help handles
    figure(h.fig)                   %  Activate the original modal dialog

case 'done'
    h = get(get(0,'CurrentFigure'),'UserData');
    delete(h.helpfig)               %  Delete the help dialog
    CustomDone(varargin{2},h)       %  Restore the original modal dialog
    refresh(h.fig)
	 set(h.fig,'CloseRequestFcn','closereq')

case 'forceclose'
    h = get(get(0,'CurrentFigure'),'UserData');
    delete(h.helpfig)               %  Delete the help dialog
    delete(h.fig)                   %  Delete from the force close operation

case 'AzEl'              %  Help for azimuth and elevation variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use this entry to specify the location of the light source, ',...
           'defined by an azimuth and elevation [az el].  Angles are ',...
           'in degrees, with the azimuth measured clockwise from North, ',...
			  'and elevation up from the zero plane of the surface.'];
	str2 = ['If data is supplied, then the vector must be enclosed in square brackets.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'CLim'           %  Help for color limit edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use this entry to specify the two-element [cmin cmax] ',...
           'color limit vector.  This vector is used with caxis.  If omitted, ',...
			  'these caxis limits are computed from the map.'];
	str2 = ['If data is supplied, then the vector must be enclosed in square brackets.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'ColorMap'           %  Help for colormap edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use this entry to supply a user defined colormap.  The number ',...
           'of grayscales is chosen to keep the size of the shaded colormap ',...
			  'below 256.'];
	str2 = ['To use the current colormap in the figure window, enter the  ',...
	        'string ''window'' for the colormap.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'DEMMode'           %  Help for DEMCMAP mode radio button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['These radio buttons define the construction mode for the ',...
	        'digital elevation colormaps.  If "Size" is selected, ',...
			  'then the length of the colormap is specified.  If omitted, ',...
			  'a length of 64 is assumed.  If "Range" is selected, then ',...
			  'the altitude range assigned to each color is specified.  If ',...
			  'omitted, a range of 100 is assumed.'];
   set(h.helptext,'String',{str1})

case 'DEMSize'           %  Help for DEMCMAP colormap size edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use this entry to define the length of the colormap.  If omitted, ',...
           'then a length of 64 is assumed.'];
	str2 = ['Only scalars are allowed for this entry.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'DEMRange'           %  Help for DEMCMAP altitude range edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use this entry to define the altitude range assigned to each ',...
	        'color.  If omitted, then a range of 100 is assumed.'];
	str2 = ['Only scalars are allowed for this entry.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'RGBSea'           %  Help for DEMCMAP sea RGB edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use this entry to replace the default colors for sea data.  ',...
	        'The colors are interpolated from the RGB color matrix, which can be of any length. ',...
           'Default colors for the sea data can be retained by leaving this ',...
			  'entry blank.  The current figure colormap can be specified ',...
			  'by entering the string ''window''.'];
	str2 = ['If RGB data is directly specified, then it must be enclosed ',...
	        'in square brackets (eg: [0 0 0; 0.5 0.5 0.5; 1 1 1]).'];
   set(h.helptext,'String',{str1,' ',str2})


case 'RGBLand'           %  Help for DEMCMAP land RGB edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use this entry to replace the default colors for land data.  ',...
	        'The colors are interpolated from the RGB color matrix, which can be of any length. ',...
           'Default colors for the land data can be retained by leaving this ',...
			  'entry blank.  The current figure colormap can be specified ',...
			  'by entering the string ''window''.'];
	str2 = ['If RGB data is directly specified, then it must be enclosed ',...
	        'in square brackets (eg: [0 0 0; 0.5 0.5 0.5; 1 1 1]).'];
   set(h.helptext,'String',{str1,' ',str2})
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function CustomInit(SourceCall,h)

%  CUSTOMINIT will initialize the help callbacks and object states
%  of the modal dialog box upon entering of the help mode.  This is
%  called when the help button is pushed.


switch SourceCall      %  SourceCall identifies the orignal modal dialog
case 'meshlsrmui'      %  Shaded Relief Mesh Map Modal Dialog

	set(h.helpfig,'Name','Shaded Mesh Map Help')
	set([h.mapedit; h.legedit; h.azeledit; h.cmapedit; h.climedit],'Enable','off')
   set([h.maplist; h.leglist; h.azellist; h.cmaplist; h.climlist],'CallBack','maphlp1(''ListButton'')')

	set(h.maplabel,'Style','push','CallBack','maphlp1(''Map'')')
	set(h.leglabel,'Style','push','CallBack','maphlp1(''Maplegend'')')
	set(h.azellabel,'Style','push','CallBack','maphlp4(''AzEl'')')
	set(h.cmaplabel,'Style','push','CallBack','maphlp4(''ColorMap'')')
	set(h.climlabel,'Style','push','CallBack','maphlp4(''CLim'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp4(''done'',''meshlsrmui'')')

case 'surflsrmui'      %  Shaded Relief Map Modal Dialog

	set(h.helpfig,'Name','Shaded Map Help')
	set([h.mapedit; h.latedit; h.lonedit; h.azeledit; h.cmapedit; h.climedit],'Enable','off')
   set([h.maplist; h.latlist; h.lonlist; h.azellist; h.cmaplist; h.climlist],'CallBack','maphlp1(''ListButton'')')

	set(h.maplabel,'Style','push','CallBack','maphlp1(''Map'')')
	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.azellabel,'Style','push','CallBack','maphlp4(''AzEl'')')
	set(h.cmaplabel,'Style','push','CallBack','maphlp4(''ColorMap'')')
	set(h.climlabel,'Style','push','CallBack','maphlp4(''CLim'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp4(''done'',''surflsrmui'')')

case 'demcmapui'      %  DEM Colormap Modal Dialog

	set(h.helpfig,'Name','DEM Colormap Help')
	set([h.radio1; h.radio2; h.mapedit; h.sizeedit; h.rgbsedit; h.rgbledit],...
       'Enable','off')
   set([h.maplist; h.sizelist; h.rgbslist; h.rgbllist],'CallBack','maphlp1(''ListButton'')')

	set(h.radiolabel,'Style','push','CallBack','maphlp4(''DEMMode'')')
	set(h.maplabel,'Style','push','CallBack','maphlp1(''Map'')')
	set(h.sizelabel,'Style','push','CallBack','maphlp4(''DEMSize'')')
	set(h.ranglabel,'Style','push','CallBack','maphlp4(''DEMRange'')')
	set(h.rgbslabel,'Style','push','CallBack','maphlp4(''RGBSea'')')
	set(h.rgbllabel,'Style','push','CallBack','maphlp4(''RGBLand'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp4(''done'',''demcmapui'')')

end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function CustomDone(SourceCall,h)

%  CUSTOMDONE will restore the original callback and object state
%  of the modal dialog box upon exit of the help mode.  This is
%  called when the done button is pushed.


switch SourceCall      %  SourceCall identifies the orignal modal dialog
case 'meshlsrmui'      %  Shaded Relief Mesh Map Modal Dialog

	set([h.maplabel; h.leglabel; h.azellabel; h.cmaplabel; h.climlabel],...
	    'Style','text','CallBack','')
	set([h.mapedit; h.legedit; h.azeledit; h.cmapedit; h.climedit],'Enable','on')
    set([h.maplist; h.leglist; h.azellist; h.cmaplist; h.climlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp4(''initialize'',''meshlsrmui'')')

case 'surflsrmui'      %  Shaded Relief Map Modal Dialog

	set([h.maplabel; h.latlabel; h.lonlabel; h.azellabel; ...
	     h.cmaplabel; h.climlabel],'Style','text','CallBack','')
	set([h.mapedit; h.latedit; h.lonedit; h.azeledit; ...
        h.cmapedit; h.climedit],'Enable','on')
    set([h.maplist; h.latlist; h.lonlist; h.azellist; ...
         h.cmaplist; h.climlist],...
         'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp4(''initialize'',''surflsrmui'')')

case 'demcmapui'      %  DEM Colormap Modal Dialog

	set([h.radio1; h.radio2; h.mapedit; h.sizeedit; h.rgbsedit; h.rgbledit],...
       'Enable','on')
   set([h.maplist; h.sizelist; h.rgbslist; h.rgbllist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.radiolabel; h.maplabel; h.sizelabel;h.ranglabel; h.rgbslabel; h.rgbllabel],...
	    'Style','text','CallBack','')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp4(''initialize'',''demcmapui'')')

end

