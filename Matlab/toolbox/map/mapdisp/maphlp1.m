function maphlp1(varargin)

%MAPHLP1  Mapping Toolbox Help Utility for Selected GUIs
%
%  MAPHLP1 enables the help utility for the GUIs listed below.
%  It also processes the help callbacks and restores the
%  calling dialog to its original state (pre-help call).
%
%  MAPHLP1 contains the help utilities for:
%        linemui, patchmui, meshmui, surfacemui, comet3mui,
%        stem3mui, scattermui, textmui, contor3mui, quivermui,
%        quiver3mui, surflmui, lightmui, limitmuim
%
%        These functions are local functions contained in the
%        m-file specified by dropping the "ui" characters in the
%        above names.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.12.4.1 $  $Date: 2003/08/01 18:18:47 $
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
    set(h.fig,'CloseRequestFcn','maphlp1(''forceclose'')' )
	 if ~strcmp(computer,'MAC2') & ~strcmp(computer,'PCWIN')
            set(h.fig,'WindowStyle','normal')
	 end

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

    PixelFactor = guifactm('pixels');
    FontScaling =  guifactm('fonts');

%  Create the help dialog box.  Make visible when all objects are drawn

    h.helpfig = figure('Name',' ',...
                'Units','Points',  'Position',PixelFactor*72*[5.3 1.4 2.7 2.9],...
                'Tag','MapHelpWindow', 'Visible','off ',...
                'NumberTitle','off', 'CloseRequestFcn',' ',...
					 'IntegerHandle','off');
    colordef(h.helpfig,'white');
    figclr = get(h.helpfig,'Color');
	 if strcmp(computer,'MAC2') 
            set(h.helpfig,'WindowStyle','modal')
	 end

%  Initialize the help text object

    str1 = 'Press Any Button (excluding "Done") for Help';
    str2 = 'Press "Done" to Exit Help';
    h.helptext = uicontrol(h.helpfig,'Style','Text ',...
	        'String',{str1,' ',str2}, ...
            'Units','Normalized','Position', [0.05  0.05  0.90  0.90], ...
            'FontWeight','bold',  'FontSize',FontScaling*10, ...
            'HorizontalAlignment', 'left ',...
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

case 'Latitude'              %  Help for latitude variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the latitude data.'];
	str2 = ['MATLAB expressions with a numerical result are also ',...
	        'valid entries (e.g. ones([10 10]) ).'];
    set(h.helptext,'String',{str1,' ',str2})

case 'Longitude'           %  Help for longitude variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the longitude data.'];
	str2 = ['MATLAB expressions with a numerical result are also ',...
	        'valid entries (e.g. ones([10 10]) ).'];
    set(h.helptext,'String',{str1,' ',str2})

case 'Map'           %  Help for map variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the matrix map.'];
	str2 = ['MATLAB expressions with a numerical result are also ',...
	        'valid entries (e.g. ones([10 10]) ).'];
    set(h.helptext,'String',{str1,' ',str2})

case 'Altitude'           %  Help for altitude variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the altitude data.  A scalar numerical ',...
			'entry can be entered instead of a variable name to specify the plane in which to ',...
			'display the object.'];
	str2 = ['MATLAB expressions with a numerical result are also ',...
	        'valid entries (e.g. ones([10 10]) ).'];
    set(h.helptext,'String',{str1,' ',str2})

case 'ScalarAltitude'           %  Help for scalar altitude variable (patchm only)
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter a scalar value to specify the plane in which ',...
	        'to display the patch map object.'];
	str2 = ['A valid workspace variable may also be entered, provided ',...
	        'that this variable is a scalar.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'Text'           %  Help for text variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the text strings.'];
	str2 = ['A text string can be directly entered, provided that ',...
	        'it is enclosed in single quotes.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'Maplegend'           %  Help for map legend variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the matrix map legend.'];
	str2 = ['The maplegend can also be ',...
	        'entered directly as [scale lat long].'];
    set(h.helptext,'String',{str1,' ',str2})

case 'Npts'           %  Help for graticule size variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the matrix map graticule size.'];
	str2 = ['A two-element vector enclosed in square brackets can also be ',...
	        'entered instead of a variable name.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'CountData'           %  Help for count data variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the stem height data.'];
	str2 = ['MATLAB expressions with a numerical result are also ',...
	        'valid entries (e.g. ones([10 10]) ).'];
    set(h.helptext,'String',{str1,' ',str2})
case 'MarkerSizeWeight'           %  Help for count data variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter a scalar marker size or the name of the workspace variable ',...
	        'that contains the marker size data. ',...
	        'The length of the vector must be ',...
			'the same as that of the lat and lon vectors. The data must also be positive and in units of points^2'];
	str2 = ['MATLAB expressions with a numerical result are also ',...
	        'valid entries (e.g. ones([10 10]) ). '];
    set(h.helptext,'String',{str1,' ',str2})
case 'MarkerColor'           %  Help for count data variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter a ColorSpec string (''r''), a three element RGB color ([1 0 0]), ',...
			'or the name of the workspace variable that contains the marker color data. ',...
	        'The length of the vector must be ',...
			'the same as that of the lat and lon vectors'];
	str2 = ['MATLAB expressions with a numerical result are also ',...
	        'valid entries (e.g. ones([10 10]) ).'];
    set(h.helptext,'String',{str1,' ',str2})
case 'MarkerSymbolPopup'
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Select the marker from the popup menu.',...
	        ''];
	str2 = ['This marker will be applied to all of the data.'];
    set(h.helptext,'String',{str1,' ',str2})	
case 'FillCheck'
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Markers will be filled when this box is checked.',...
	        ''];
	str2 = ['This will apply to all of the markers.'];
    set(h.helptext,'String',{str1,' ',str2})	
case 'UComponent'              %  Help for U component variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the U vector component data. The vector is ',... 
	        'plotted from (lat,lon,alt) to (lat+U,lon+V,alt+W). '];
	str2 = ['MATLAB expressions with a numerical result are also ',...
	        'valid entries (e.g. ones([10 10]) ).'];
    set(h.helptext,'String',{str1,' ',str2})

case 'VComponent'              %  Help for V component variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the V vector component data. The vector is ',... 
	        'plotted from (lat,lon,alt) to (lat+U,lon+V,alt+W). '];
	str2 = ['MATLAB expressions with a numerical result are also ',...
	        'valid entries (e.g. ones([10 10]) ).'];
    set(h.helptext,'String',{str1,' ',str2})

case 'WComponent'              %  Help for W component variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the W vector component data. The vector is ',... 
	        'plotted from (lat,lon,alt) to (lat+U,lon+V,alt+W). '];
	str2 = ['MATLAB expressions with a numerical result are also ',...
	        'valid entries (e.g. ones([10 10]) ).'];
    set(h.helptext,'String',{str1,' ',str2})

case 'FaceColor'           %  Help for scalar face color variable (patchm only)
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter a valid face color string or RGB triple.  A color ',...
	        'string must be enclosed in single quotes.  If omitted, ',...
	        'a default color will be used.'];
	str2 = ['A valid workspace variable may also be entered, provided ',...
	        'that this variable is a color string or RBG triple.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'LineSpec'           %  Help for line spec variable
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter a valid LineSpec string enclosed in single quotes.  Make ',...
	        'sure that the LineSpec string contains a symbol definition.'];
	str2 = 'Example:';
	str3 = '  ''b*'' ';
    set(h.helptext,'String',{str1,' ',str2,str3})

case 'CometTail'           %  Help for tail length variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter a scalar value between 0 and 1 for the length ',...
	        ' of the comet tail.'];
	str2 = ['A valid workspace variable may also be entered, provided ',...
	        'that this variable is a scalar.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'OtherProperties1'          %  Help for other property edit box
                                 %  LineSpec strings are valid entries in this case
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Any other properties of the object to be displayed may be ',...
	        'specified here.  Any string entry must be enclosed ',...
			'in single quotes.  LineSpec strings are also valid entries.'];
	str2 = 'Examples:';
	str3 = '  ''b-'' ';
	str4 = '  ''LineWidth'',2 ';
	str5 = '  ''b-'',''LineWidth'',2 ';
    set(h.helptext,'String',{str1,' ',str2,str3,str4,str5})

case 'OtherProperties2'          %  Help for other property edit box
                                 %  LineSpec strings are not valid entries
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Any other properties of the object to be displayed may be ',...
	        'specified here.  Any string entry must be enclosed ',...
			'in single quotes ''''.'];
	str2 = 'Examples:';
	str3 = '  ''LineWidth'',2 ';
    set(h.helptext,'String',{str1,' ',str2,str3})

case 'ListButton'         %  Help for variable pick list button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Pressing this button will produce a list of current ',...
	       'workspace variables.  The desired variable can be selected ',...
		   'from this list.'];
    set(h.helptext,'String',str1)

case 'SVector'           %  Help for Surlm light position edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The position of the light source can be controlled by ',...
	        'this input.  If specified, it can be a vector S = [x,y,z] ',...
			'that specifies the direction of the light source. It can also ',...
			'be specified in spherical coordinates, S = [azimuth,elevation].  The ',...
			'default value for S is 45 degrees counterclockwise from the ',...
			'current view direction.'];
    set(h.helptext,'String',str1)

case 'SurflCoef'           %  Help for Surflm coefficients edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The relative contributions due to ambient light, diffuse ',...
            'reflection, specular reflection, and the specular spread ',...
            'coefficient can be set by providing a vector of coefficients, ',...
            '[ka,kd,ks,spread].'];
    set(h.helptext,'String',str1)

case 'QuiverScale'           %  Help for quiver scale edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter a scalar value to specify the scale factor applied ',...
	        'to the vectors. To suppress the automatic scaling, specify s = 0.'];
	str2 = ['A valid workspace variable may also be entered, provided ',...
	        'that this variable is a scalar.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'FilledBase'           %  Help for filled base check box (quivers)
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Check this box to fill the base markers of the vectors.'];
	str2 = ['If checked, make sure that the LineSpec string contains ',...
	        'a symbol definition.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'ContourLevels'           %  Help for contour levels variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable ',...
	        'that contains the desired contour levels.'];
	str2 = ['A vector enclosed in square brackets can also be ',...
	        'entered instead of a variable name.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'ContourMode'           %  Help for contour mode radio buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Using these radio buttons, a 2D or 3D contour map can ',...
	        'be specified.  In a 2D contour map, all contour levels ',...
			'are drawn in the z = 0 plane.  In a 3D contour map, the ',...
			'contour lines are drawn in their corresponding z plane.'];
    set(h.helptext,'String',str1)

case 'ContourLegend'           %  Help for contour legend popup menu
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This popup menu specifies the label or legend ',...
	        'to be added to the contour map.  If the Plot Legend option ',...
			'is chosen, any existing legend will be deleted.  If a ',...
			'manual label option is chosen, then the contours to be ',...
			'labelled are specified by clicking on them after they ',... 
			'have been plotted.'];
    set(h.helptext,'String',str1)

case 'LightMode'           %  Help for light mode check box (light)
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Check this box to specify parallel rays from an infinite light source.'];
	str2 = ['If checked, the altitude variable has no effect.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'LightColor'           %  Help for light color popup menu (light)
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use this popup menu to specify the light color.'];
	str2 = ['An RGB triple can be specified by selecting the custom option.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'MapLimit'           %  Help for contour MLimit button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This button enables the latitude and longitude limits of a regular matrix ',...
	        'map to be computed.  The results of this computation are ',...
			'stored as variables in the workspace.  Afterwards, these ',...
			'limit variables can be used as the latitude and ',...
			'longitude inputs for the contour map.  This allows contour maps to be computed ',...
			'for regular matrix maps.'];
    set(h.helptext,'String',str1)

case 'LatitudeLimit'           %  Help for latitude limit variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable which will ',...
	        'store the computed latitude limits of the matrix map.'];
	str2 = ['If this variable exists in the workspace, it will be overwritten.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'LongitudeLimit'           %  Help for longitude limit variable edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter the name of the workspace variable which will ',...
	        'store the computed longitude limits of the matrix map.'];
	str2 = ['If this variable exists in the workspace, it will be overwritten.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'Apply'                    %  Help for the apply button
	h = get(get(0,'CurrentFigure'),'UserData');
	str = ['Pressing the Apply button will execute the function.'];
    set(h.helptext,'String',str)

case 'Cancel'                    %  Help for the cancel button
	h = get(get(0,'CurrentFigure'),'UserData');
	str = ['Pressing the Cancel button will abort the operation.'];
    set(h.helptext,'String',str)

end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function CustomInit(SourceCall,h)

%  CUSTOMINIT will initialize the help callbacks and object states
%  of the modal dialog box upon entering of the help mode.  This is
%  called when the help button is pushed.

switch SourceCall      %  SourceCall identifies the orignal modal dialog
case 'linemui'         %  Line Map Modal Dialog

	set(h.helpfig,'Name','Line Map Help')
	set([h.latedit; h.lonedit; h.altedit; h.propedit],'Enable','off')
    set([h.latlist; h.lonlist; h.altlist],'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.altlabel,'Style','push','CallBack','maphlp1(''Altitude'')')
	set(h.proplabel,'Style','push','CallBack','maphlp1(''OtherProperties1'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''linemui'')')

case 'patchmui'         %  Patch Map Modal Dialog

	set(h.helpfig,'Name','Patch Map Help')
	set([h.latedit; h.lonedit; h.altedit; h.cdedit; h.propedit],'Enable','off')
    set([h.latlist; h.lonlist; h.altlist],'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.altlabel,'Style','push','CallBack','maphlp1(''ScalarAltitude'')')
	set(h.cdlabel,'Style','push','CallBack','maphlp1(''FaceColor'')')
	set(h.proplabel,'Style','push','CallBack','maphlp1(''OtherProperties2'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''patchmui'')')

case 'surfacemui'         %  Surface Map Modal Dialog

	set(h.helpfig,'Name','Surface Map Help')
	set([h.latedit; h.lonedit; h.mapedit; h.altedit; h.propedit],'Enable','off')
    set([h.latlist; h.lonlist; h.maplist; h.altlist],'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.maplabel,'Style','push','CallBack','maphlp1(''Map'')')
	set(h.altlabel,'Style','push','CallBack','maphlp1(''Altitude'')')
	set(h.proplabel,'Style','push','CallBack','maphlp1(''OtherProperties2'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''surfacemui'')')

case 'meshmui'         %  Mesh Map Modal Dialog

	set(h.helpfig,'Name','Mesh Map Help')
	set([h.mapedit; h.legedit; h.nptsedit; h.altedit; h.propedit],'Enable','off')
    set([h.maplist; h.leglist; h.nptslist; h.altlist],'CallBack','maphlp1(''ListButton'')')

	set(h.maplabel,'Style','push','CallBack','maphlp1(''Map'')')
	set(h.leglabel,'Style','push','CallBack','maphlp1(''Maplegend'')')
	set(h.nptslabel,'Style','push','CallBack','maphlp1(''Npts'')')
	set(h.altlabel,'Style','push','CallBack','maphlp1(''Altitude'')')
	set(h.proplabel,'Style','push','CallBack','maphlp1(''OtherProperties2'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''meshmui'')')

case 'surflmui'         %  Surfl Map Modal Dialog

	set(h.helpfig,'Name','Surfl Map Help')
	set([h.latedit; h.lonedit; h.mapedit; h.lgtedit; h.cofedit],'Enable','off')
    set([h.latlist; h.lonlist; h.maplist; h.lgtlist; h.coflist],...
	    'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.maplabel,'Style','push','CallBack','maphlp1(''Map'')')
	set(h.lgtlabel,'Style','push','CallBack','maphlp1(''SVector'')')
	set(h.coflabel,'Style','push','CallBack','maphlp1(''SurflCoef'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''surflmui'')')

case 'textmui'         %  Text Map Modal Dialog

	set(h.helpfig,'Name','Text Map Help')
	set([h.txtedit; h.latedit; h.lonedit; h.altedit; h.propedit],'Enable','off')
    set([h.txtlist; h.latlist; h.lonlist; h.altlist],'CallBack','maphlp1(''ListButton'')')

	set(h.txtlabel,'Style','push','CallBack','maphlp1(''Text'')')
	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.altlabel,'Style','push','CallBack','maphlp1(''Altitude'')')
	set(h.proplabel,'Style','push','CallBack','maphlp1(''OtherProperties2'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''textmui'')')

case 'lightmui'         %  Light Map Modal Dialog

	set(h.helpfig,'Name','Light Map Help')
	set([h.latedit; h.lonedit; h.altedit; h.propedit; h.lgtpopup],'Enable','off')
    set([h.latlist; h.lonlist; h.altlist],'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.altlabel,'Style','push','CallBack','maphlp1(''Altitude'')')
	set(h.proplabel,'Style','push','CallBack','maphlp1(''OtherProperties2'')')

	set(h.lgtlabel,'Style','push','CallBack','maphlp1(''LightColor'')')
	set(h.mode,'Style','push','CallBack','maphlp1(''LightMode'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''lightmui'')')

case 'cometmui'         %  Comet Map Modal Dialog

	set(h.helpfig,'Name','Comet Map Help')
	set([h.latedit; h.lonedit; h.altedit; h.tailedit],'Enable','off')
    set([h.latlist; h.lonlist; h.altlist],'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.altlabel,'Style','push','CallBack','maphlp1(''Altitude'')')
	set(h.taillabel,'Style','push','CallBack','maphlp1(''CometTail'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''cometmui'')')

case 'stem3mui'         %  Stem Map Modal Dialog

	set(h.helpfig,'Name','Stem Map Help')
	set([h.latedit; h.lonedit; h.altedit; h.propedit],'Enable','off')
    set([h.latlist; h.lonlist; h.altlist],'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.altlabel,'Style','push','CallBack','maphlp1(''CountData'')')
	set(h.proplabel,'Style','push','CallBack','maphlp1(''OtherProperties1'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''stem3mui'')')

case 'scattermui'         %  Symbol Map Modal Dialog

	set(h.helpfig,'Name','Symbol Map Help')
	set([h.latedit; h.lonedit; h.altedit; h.coloredit; h.markpopup],'Enable','off')
    set([h.latlist; h.lonlist; h.altlist; h.colorlist],'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.altlabel,'Style','push','CallBack','maphlp1(''MarkerSizeWeight'')')
	set(h.colorlabel,'Style','push','CallBack','maphlp1(''MarkerColor'')')
	set(h.marklabel,'Style','push','CallBack','maphlp1(''MarkerSymbolPopup'')')
	set(h.fillcheck,'Style','push','CallBack','maphlp1(''FillCheck'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
   set(h.help,'String','Done','CallBack','maphlp1(''done'',''scattermui'')')

case 'contor3mui'         %  Contour Map Modal Dialog

	set(h.helpfig,'Name','Contour Map Help')
	set([h.mode2d; h.mode3d; h.latedit; h.lonedit; h.mapedit; h.lvledit; ...
	     h.legpopup; h.propedit],'Enable','off')
    set([h.latlist; h.lonlist; h.maplist; h.lvllist],'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.maplabel,'Style','push','CallBack','maphlp1(''Map'')')
	set(h.lvllabel,'Style','push','CallBack','maphlp1(''ContourLevels'')')
	set(h.modelabel,'Style','push','CallBack','maphlp1(''ContourMode'')')
    set(h.leglabel,'Style','push','CallBack','maphlp1(''ContourLegend'')')
	set(h.proplabel,'Style','push','CallBack','maphlp1(''OtherProperties1'')')

	set(h.limitm,'CallBack','maphlp1(''MapLimit'')')
	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''contor3mui'')')

case 'contourfmui'         %  Filled Contour Map Modal Dialog

	set(h.helpfig,'Name','Contour Map Help')
	set([h.latedit; h.lonedit; h.mapedit; h.lvledit; ...
	     h.legpopup; h.propedit],'Enable','off')
    set([h.latlist; h.lonlist; h.maplist; h.lvllist],'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.maplabel,'Style','push','CallBack','maphlp1(''Map'')')
	set(h.lvllabel,'Style','push','CallBack','maphlp1(''ContourLevels'')')
    set(h.leglabel,'Style','push','CallBack','maphlp1(''ContourLegend'')')
	set(h.proplabel,'Style','push','CallBack','maphlp1(''OtherProperties1'')')

	set(h.limitm,'CallBack','maphlp1(''MapLimit'')')
	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''contourfmui'')')

case 'quivermui'         %  Quiver Map Modal Dialog

	set(h.helpfig,'Name','Quiver Map Help')
	set([h.latedit; h.lonedit; h.uedit; h.vedit; h.scledit; h.lineedit], ...
	     'Enable','off')
    set([h.latlist; h.lonlist; h.ulist; h.vlist],'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.ulabel,'Style','push','CallBack','maphlp1(''UComponent'')')
	set(h.vlabel,'Style','push','CallBack','maphlp1(''VComponent'')')
	set(h.linelabel,'Style','push','CallBack','maphlp1(''LineSpec'')')
	set(h.scllabel,'Style','push','CallBack','maphlp1(''QuiverScale'')')
	set(h.arrow,'Style','push','CallBack','maphlp1(''FilledBase'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''quivermui'')')

case 'quiver3mui'         %  Quiver 3D Map Modal Dialog

	set(h.helpfig,'Name','3D Quiver Map Help')
	set([h.latedit; h.lonedit; h.altedit; h.uedit; h.vedit; h.wedit; ...
	     h.scledit; h.lineedit], 'Enable','off')
    set([h.latlist; h.lonlist; h.altlist; h.ulist; h.vlist; h.wlist],...
	    'CallBack','maphlp1(''ListButton'')')

	set(h.latlabel,'Style','push','CallBack','maphlp1(''Latitude'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''Longitude'')')
	set(h.altlabel,'Style','push','CallBack','maphlp1(''Altitude'')')
	set(h.ulabel,'Style','push','CallBack','maphlp1(''UComponent'')')
	set(h.vlabel,'Style','push','CallBack','maphlp1(''VComponent'')')
	set(h.wlabel,'Style','push','CallBack','maphlp1(''WComponent'')')
	set(h.linelabel,'Style','push','CallBack','maphlp1(''LineSpec'')')
	set(h.scllabel,'Style','push','CallBack','maphlp1(''QuiverScale'')')
	set(h.arrow,'Style','push','CallBack','maphlp1(''FilledBase'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''quiver3mui'')')

case 'limitmui'         %  Limitm Modal Dialog

	set(h.helpfig,'Name','Map Limit Help')

	set([h.mapedit; h.legedit; h.latedit; h.lonedit],'Enable','off')
    set([h.maplist; h.leglist; h.latlist; h.lonlist],'CallBack','maphlp1(''ListButton'')')

	set(h.maplabel,'Style','push','CallBack','maphlp1(''Map'')')
	set(h.leglabel,'Style','push','CallBack','maphlp1(''Maplegend'')')
	set(h.latlabel,'Style','push','CallBack','maphlp1(''LatitudeLimit'')')
	set(h.lonlabel,'Style','push','CallBack','maphlp1(''LongitudeLimit'')')

	set(h.cancel,'CallBack','maphlp1(''Cancel'')')
	set(h.apply,'CallBack','maphlp1(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp1(''done'',''limitmui'')')
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function CustomDone(SourceCall,h)

%  CUSTOMDONE will restore the original callback and object state
%  of the modal dialog box upon exit of the help mode.  This is
%  called when the done button is pushed.

switch SourceCall      %  SourceCall identifies the orignal modal dialog
case 'linemui'         %  Line Map Modal Dialog

	set([h.latlabel; h.lonlabel; h.altlabel; h.proplabel],...
	    'Style','text','CallBack','')
	set([h.latedit; h.lonedit; h.altedit; h.propedit],'Enable','on')
    set([h.latlist; h.lonlist; h.altlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''linemui'')')

case 'patchmui'         %  Patch Map Modal Dialog

	set([h.latlabel; h.lonlabel; h.altlabel; h.cdlabel; h.proplabel],...
	    'Style','text','CallBack','')
	set([h.latedit; h.lonedit; h.altedit; h.cdedit; h.propedit],'Enable','on')
    set([h.latlist; h.lonlist; h.altlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''patchmui'')')

case 'surfacemui'         %  Surface Map Modal Dialog

	set([h.latlabel; h.lonlabel; h.maplabel; h.altlabel; h.proplabel],...
	    'Style','text','CallBack','')
	set([h.latedit; h.lonedit; h.mapedit; h.altedit; h.propedit],'Enable','on')
    set([h.latlist; h.lonlist; h.maplist; h.altlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''surfacemui'')')

case 'meshmui'         %  Mesh Map Modal Dialog

	set([h.maplabel; h.leglabel; h.nptslabel; h.altlabel; h.proplabel],...
	    'Style','text','CallBack','')
	set([h.mapedit; h.legedit; h.nptsedit; h.altedit; h.propedit],'Enable','on')
    set([h.maplist; h.leglist; h.nptslist; h.altlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''meshmui'')')

case 'surflmui'         %  Surfl Map Modal Dialog

	set([h.latedit; h.lonedit; h.mapedit; h.lgtedit; h.cofedit],'Enable','on')
    set([h.latlist; h.lonlist; h.maplist; h.lgtlist; h.coflist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')
	set([h.latlabel; h.lonlabel; h.maplabel; h.lgtlabel; h.coflabel],...
	    'Style','text','CallBack','')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''surflmui'')')

case 'textmui'         %  Text Map Modal Dialog

	set([h.txtlabel; h.latlabel; h.lonlabel; h.altlabel; h.proplabel],...
	    'Style','text','CallBack','')
	set([h.txtedit; h.latedit; h.lonedit; h.altedit; h.propedit],'Enable','on')
    set([h.txtlist; h.latlist; h.lonlist; h.altlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''textmui'')')

case 'lightmui'         %  Light Map Modal Dialog

	set([h.latlabel; h.lonlabel; h.altlabel; h.proplabel; h.lgtlabel],...
	    'Style','text','CallBack','')
	set([h.latedit; h.lonedit; h.altedit; h.propedit; h.lgtpopup],'Enable','on')
    set([h.latlist; h.lonlist; h.altlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set(h.mode,'Style','check','CallBack','')
	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''lightmui'')')

case 'cometmui'         %  Comet Map Modal Dialog

	set([h.latlabel; h.lonlabel; h.altlabel; h.taillabel],...
	    'Style','text','CallBack','')
	set([h.latedit; h.lonedit; h.altedit; h.tailedit],'Enable','on')
    set([h.latlist; h.lonlist; h.altlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''cometmui'')')

case 'stem3mui'         %  Stem Map Modal Dialog

	set([h.latlabel; h.lonlabel; h.altlabel; h.proplabel],...
	    'Style','text','CallBack','')
	set([h.latedit; h.lonedit; h.altedit; h.propedit],'Enable','on')
    set([h.latlist; h.lonlist; h.altlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''stem3mui'')')

case 'scattermui'         %  Symbol Map Modal Dialog

	set([h.latlabel; h.lonlabel; h.altlabel; h.colorlabel; h.marklabel],...
	    'Style','text','CallBack','')
	set(h.fillcheck, 'Style','check','CallBack','')
	set([h.latedit; h.lonedit; h.altedit;  h.coloredit; h.markpopup],'Enable','on')
    set([h.latlist; h.lonlist; h.altlist; h.colorlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.cancel;h.apply],'CallBack','uiresume')
   set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''scattermui'')')

case 'contor3mui'         %  Contour Map Modal Dialog

	set([h.latlabel; h.lonlabel; h.maplabel; h.modelabel; h.leglabel;...
	     h.lvllabel; h.proplabel],'Style','text','CallBack','')
	set([h.mode2d; h.mode3d; h.latedit; h.lonedit; h.mapedit; h.lvledit;...
	     h.legpopup; h.propedit],'Enable','on')
    set([h.latlist; h.lonlist; h.maplist; h.lvllist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

    set(h.limitm,'CallBack','limitm')
	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''contor3mui'')')

case 'contourfmui'         %  Contour Map Modal Dialog

	set([h.latlabel; h.lonlabel; h.maplabel; h.leglabel;...
	     h.lvllabel; h.proplabel],'Style','text','CallBack','')
	set([h.latedit; h.lonedit; h.mapedit; h.lvledit;...
	     h.legpopup; h.propedit],'Enable','on')
    set([h.latlist; h.lonlist; h.maplist; h.lvllist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

    set(h.limitm,'CallBack','limitm')
	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''contourfmui'')')

case 'quivermui'         %  Quiver Map Modal Dialog

	set([h.latlabel; h.lonlabel; h.ulabel; h.vlabel; h.scllabel; h.linelabel],...
	     'Style','text','CallBack','')
	set([h.latedit; h.lonedit; h.uedit; h.vedit; h.scledit; h.lineedit], ...
	     'Enable','on')
    set([h.latlist; h.lonlist; h.ulist; h.vlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set(h.arrow,'Style','check','CallBack','')
	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''quivermui'')')

case 'quiver3mui'         %  3D Quiver Map Modal Dialog

	set([h.latlabel; h.lonlabel; h.altlabel; h.ulabel; h.vlabel; h.wlabel; ...
	     h.scllabel; h.linelabel],'Style','text','CallBack','')
	set([h.latedit; h.lonedit; h.altedit; h.uedit; h.vedit; h.wedit; ...
	     h.scledit; h.lineedit], 'Enable','on')
    set([h.latlist; h.lonlist; h.altlist; h.ulist; h.vlist; h.wlist],...
	    'CallBack','varpick(who,get(gco,''UserData''))')

	set(h.arrow,'Style','check','CallBack','')
	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''quiver3mui'')')

case 'limitmui'         %  Mesh Map Modal Dialog

	set([h.maplabel; h.leglabel; h.latlabel; h.lonlabel],...
	     'Style','text','CallBack','')
	set([h.mapedit; h.legedit; h.latedit; h.lonedit],'Enable','on')
    set([h.maplist; h.leglist; h.latlist; h.lonlist],...
	     'CallBack','varpick(who,get(gco,''UserData''))')

	set([h.cancel;h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp1(''initialize'',''limitmui'')')

end
