function maphlp2(varargin)

%MAPHLP2  Mapping Toolbox Help Utility for Selected GUIs
%
%  MAPHLP2 enables the help utility for the GUIs listed below.
%  It also processes the help callbacks and restores the
%  calling dialog to its original state (pre-help call).
%
%  MAPHLP2 contains the help utilities for:
%        trackui,   trackui/RangeUnitsBox
%        scirclui,  scirclui/RangeUnitsBox
%        surfdist,  surfdist/RangeUnitsBox

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.12.4.3 $  $Date: 2004/02/01 21:58:11 $
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
    set(h.figure,'CloseRequestFcn','maphlp2(''forceclose'')' )

    h.windowstyle = get(h.figure,'WindowStyle');
	 if ~strcmp(computer,'MAC2') & ~strcmp(computer,'PCWIN')
            set(h.figure,'WindowStyle','normal')
	 end

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

	PixelFactor = guifactm('pixels');
	FontScaling =  guifactm('fonts');

%  Create the help dialog box.  Make visible when all objects are drawn

    h.helpfig = figure('Name','',...
                'Units','Points',  'Position',PixelFactor*72*[5.6 1.4 3 4.25],...
                'Tag','MapHelpWindow', 'Visible','off',...
                'NumberTitle','off', 'CloseRequestFcn','',...
					 'IntegerHandle','off');
    colordef(h.helpfig,'white');
    figclr = get(h.helpfig,'Color');
	 if strcmp(computer,'MAC2') 
            set(h.helpfig,'WindowStyle','modal')
	 end
     
    % hide menubar in help window
    set(findall(h.helpfig,'type','uimenu'),'visible','off')
    
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

    set(h.figure,'WindowStyle','modal')
    set(h.helpfig,'Visible','on')   %  Turn help window on
    set(h.figure,'UserData',h)      %  Save the additional help handles
    figure(h.figure)                %  Activate the original modal dialog

case 'done'
    h = get(get(0,'CurrentFigure'),'UserData');
    delete(h.helpfig)               %  Delete the help dialog
    set(h.figure,'WindowStyle',h.windowstyle)
    CustomDone(varargin{2},h)       %  Restore the original modal dialog
    refresh(h.figure)
	 set(h.figure,'CloseRequestFcn','closereq')

case 'forceclose'
    h = get(get(0,'CurrentFigure'),'UserData');
    delete(h.helpfig)               %  Delete the help dialog
    delete(h.figure)                %  Delete from the force close operation

case 'TrackStyle'              %  Help for track style radio buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use these radio buttons to specify whether a "Great Circle" ',...
	        'or "Rhumb Line" track is displayed.'];
    set(h.helptext,'String',str1)

case 'TrackMode'              %  Help for track mode radio buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use these radio buttons to choose how the track will be ',...
	        'defined.  Two point specification requires the starting ',...
			'and ending points of the track.  One point specification ',...
			'requires the starting point, azimuth and range for the track.'];
	str2 = ['The range is an optional argument used to ',...
			'define a fixed distance along the track.  If a scalar is ',...
			'supplied, the track travels the specified distance from ',...
			'the starting point.  If a vector is supplied, it must ',...
			'be a two-element vector defining the starting and ending range along ',...
			'the track, and it must be enclosed in square brackets.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'CircleStyle'              %  Help for track style radio buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use these radio buttons to specify the style of the ',...
	        'small circle.  If "Great Circle" is selected, then the ',...
			'circle radius is a constant great circle distance.  If ',...
			'"Rhumb Line" is specified, then the circle radius is a constant ',...
			'rhumb line distance.'];
	str2 = ['The Great Circle style is the standard definition of a small circle.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'CircleMode'              %  Help for track mode radio buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use these radio buttons to select how the small circle will be ',...
	        'defined.  Two point specification requires the ',...
			'center point and a  point on the circle.  One point ',...
			'specification requires the center point, radius ',...
	        'and azimuth.'];
	str2 = ['The azimuth is an optional argument used to ',...
			'define a sector of the small circle to be displayed.  ',...
			'If a scalar is supplied, the starting azimuth is 0.  If a ',...
			'vector is supplied, it must be a two-element row vector defining the ',...
			'starting and ending azimuths, and it must be enclosed in square brackets.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'SurfaceStyle'              %  Help for surfdist style radio buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use these radio buttons to specify whether a "Great Circle" ',...
	        'or "Rhumb Line" is used to compute the surface distance.'];
	str2 = ['When all entries are provided, selecting a style option ',...
	        'will recalculate the surface distance calculation.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'SurfaceMode'              %  Help for surfdist mode radio buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use these radio buttons to control the specification of ',...
	        'the distance calculation.  Two point specification requires ',...
			'the starting and ending points of the track to be defined.  ',...
			'The distance and azimuth along this track are then computed.'];
	str2 = ['One point specification require the starting point, range and ',...
	        'azimuth to be defined.  The ending point latitude and ',...
			'longitude are then computed.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'AngleLabel'           %  Help for angle label text display
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This text string displays the current angle units and ',...
	        'range units.'];
    set(h.helptext,'String',str1)

case 'ShowTrack'           %  Help for show track check box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This check box determines if the defined track is shown ',...
	        'on the associated map axes.  This track will be deleted ',...
			'upon closing the tool or by deselecting this box and ',...
			'recomputing the surface distance calculations.'];
    set(h.helptext,'String',str1)

case 'TrackStart'           %  Help for track starting point
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['These edit boxes allow the latitude and longitude of the starting point ',...
	        'to be defined.  Starting points must be in degrees.'];
	str2 = ['Both scalar and vector starting points may be entered.  If ',...
	        'vector entries are provided, they must be enclosed in square brackets.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'TrackEnd'           %  Help for track ending point
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['These edit boxes allow the latitude and longitude of the ending ',...
	        'point to be defined.  Ending points must ',...
			'be in degrees.'];
	str2 = ['Vector entries are used to specify more than one track, and must  ',...
	        'be enclosed in square brackets.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'TrackDirection'           %  Help for track direction
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['These edit boxes allow the track direction (azimuth and ',...
	        'range) to be defined.  The azimuth is in degrees measured ',...
			'clockwise from due north.  The range is in the units specified ',...
			'by the Range Units button.  The default range units are ',...
			'kilometers.  Valid expressions such as sm2km(1000) are ',...
			'acceptable range entries.  If the range is omitted, then ',...
			'a complete track is drawn.  Complete great circles traverse ',...
			'the globe and complete rhumb lines travel from pole to pole.'];
	str2 = ['Both scalar and vector directions may be entered.  If ',...
	        'vector entries are provided, they must be enclosed in square brackets.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'CircleCenter'           %  Help for circle center point
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['These edit boxes allow the latitude and longitude of the small ',...
	        'circle center(s) to be defined.  Center points must ',...
			'be in degrees.'];
	str2 = ['To enter more than one small circle center, provide latitude and ',...
	        'longitude vectors enclosed in square brackets.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'CirclePoint'           %  Help for circle point point
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['These edit boxes allow a point on the small circle (latitude ',...
	        'and longitude) to be defined.  The circle point(s) must ',...
			'be in degrees.'];
	str2 = ['Both scalar and vector circle points may be entered.  If ',...
	        'vector entries are provided, they must be enclosed in square brackets.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'CircleDefinition'           %  Help for circle size and sector
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['These edit boxes allow the small circle to be defined ',...
	        'by a radius and sector azimuth. The sector azimuth defines ',...
	        'the angular limits of the circle. Azimuth may be defined as a ',...
	        'two-element vector containing the start and end angles, or as a ',...
	        'scalar ending angle. In that case the starting angle is implicitly zero. ',...
	        'The azimuth is in degrees ',...
			'measured clockwise from due north.  The radius is in the ',...
			'units specified by the ',...
			'Radius Units button.  The default radius units are ',...
			'kilometers.  Valid expressions such as sm2km(1000) are ',...
			'acceptable radius entries.  If the azimuth is omitted, ',...
			'then a complete small circle is drawn.'];
	str2 = ['Both scalar and vector definitions may be entered.  If ',...
	        'vector entries are provided, they must be enclosed in square brackets.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'DistanceStart'           %  Help for surface distance starting point
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['These edit boxes allow the track starting point (latitude ',...
	        'and longitude) to be defined.  The starting point must ',...
			'be in degrees.'];
    str2 = ['Only single points may be entered.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'DistanceEnd'           %  Help for surface distance ending point
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['These edit boxes allow the track ending point (latitude ',...
	        'and longitude) to be defined, and are only used when ',...
	        'two-point mode is selected.  The ending point must ',...
			'be in degrees.'];
    str2 = ['Only single points may be entered.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'DistanceDirection'           %  Help for surface distance direction edits
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['These edit boxes allow the reckoning azimuth and range ',...
	        'to be defined. The starting point, range and azimuth ',...
			'are used to calculate the displayed ending point.  The azimuth is in ',...
			'degrees measured clockwise from due north.  The range is ',...
			'in the units specified by the ',...
			'Range Units button.  The default range units are ',...
			'kilometers.  Valid expressions such as sm2km(1000) are ',...
			'acceptable radius entries.'];
    str2 = ['Only single points may be entered.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'RangeUnits'           %  Help for range units button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This button allows the range units to be defined.  The ',...
	        'track range must be entered in these units.'];
	str2 = ['This button also allows the normalizing geoid to ',...
	        'be defined.  The normalizing geoid is used to convert the ',...
			'specified range into radian units for proper ',...
			'projection onto the map axes. This allows use of spherical or ellipsoidal ',...
         'geoid models of the Earth or other planetary bodies.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'RadiusUnits'           %  Help for radius units button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This button allows the radius units to be defined.'];
	str2 = ['This button also allows the normalizing geoid to ',...
	        'be defined.  The normalizing geoid is used to convert the ',...
			'specified radius into radian units for proper ',...
			'projection onto the map axes. This allows use of spherical or ellipsoidal ',...
         'geoid models of the Earth or other planetary bodies.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'MouseSelect'           %  Help for mouse selection button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This button allows the point to be selected ',...
	        'by clicking on the displayed map.  The coordinates of the selected point will be placed ',...
			'in the edit boxes and can be subsequently edited.'];
	str2 = ['The selected point will be in degrees, regardless ',...
	        'of the angle units used with the displayed map.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'BigEdit'           %  Help for big edit buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This button will bring up an expanded edit box for ',...
	        'the entry.'];
	str2 = ['This allows long entries to be easily edited.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'ScalarAltitude'           %  Help for scalar altitude variable (patchm only)
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Enter a scalar value to specify the plane in which the object is drawn. '];
    set(h.helptext,'String',str1)

case 'OtherProperties'          %  Help for other property edit box
                                %  LineSpec strings are valid entries in this case
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Any other properties of the object to be displayed may be ',...
	        'specified here.  Any string entry must be enclosed ',...
			'in single quotes.  LineSpec strings are also a valid entry.'];
	str2 = 'Examples:';
	str3 = '  ''b-'' ';
	str4 = '  ''LineWidth'',2 ';
	str5 = '  ''b-'',''LineWidth'',2 ';
    set(h.helptext,'String',{str1,' ',str2,str3,str4,str5})

case 'RangePopup'           %  Help for range units popup menu
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The range units are selected from this list.'];
	str2 = ['All range units other than radians are converted to angular ',...
	        'units using the normalizing geoid.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'NormalizingGeoid'           %  Help for normalizing geoid edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry defines the radius used to normalize all ',...
	        'range entries to a radian value.  This normalization is ',...
			'necessary for proper computation and projection of the ',...
			'map data.  If a geoid specification is provided, the geoid ',...
			'is transformed to the appropriate auxillary sphere to ',...
			'determine the normalizing radius.'];
	str2 = ['If the range units are radians, then the normalizing ',...
	        'geoid must be the same as the geoid used in the ',...
			'associated map axes.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'Apply'                    %  Help for the apply button
	h = get(get(0,'CurrentFigure'),'UserData');
	str = ['Pressing the Apply button will apply the current settings.'];
    set(h.helptext,'String',str)

case 'Compute'                    %  Help for the compute button
	h = get(get(0,'CurrentFigure'),'UserData');
	str = ['Pressing the Compute button will calculate the specified ',...
	       'surface distance.'];
    set(h.helptext,'String',str)

case 'Close'                    %  Help for the close button
	h = get(get(0,'CurrentFigure'),'UserData');
	str = ['Pressing the Close button will close this tool.'];
    set(h.helptext,'String',str)

case 'Cancel'                    %  Help for the cancel button
	h = get(get(0,'CurrentFigure'),'UserData');
	str = ['Pressing the Cancel button will abort the current operation.'];
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
case 'trackui'         %  Trackui Interactive Tool
	set(h.helpfig,'Name','Track Tool Help')
	set([h.gc; h.rh; h.onept; h.twopt; h.stlatedit; h.stlonedit; ...
	     h.latORaz; h.lonORrng; h.altedit; h.propedit], 'Enable','off')

	set(h.styletext,'Style','push','CallBack','maphlp2(''TrackStyle'')')
	set(h.modetext,'Style','push','CallBack','maphlp2(''TrackMode'')')
	set(h.anglabel,'Style','push','CallBack','maphlp2(''AngleLabel'')')

	set(h.sttitle,'Style','push','CallBack','maphlp2(''TrackStart'')')
	set(h.stselect,'CallBack','maphlp2(''MouseSelect'')')

	set([h.stlatlabel; h.stlonlabel; h.latORazlabel; h.lonORrnglabel],...
	    'CallBack','maphlp2(''BigEdit'')')

    if get(h.onept,'Value')
	    set(h.endORdirtitle,'Style','push','CallBack','maphlp2(''TrackDirection'')')
	    set(h.endselect,'CallBack','maphlp2(''RangeUnits'')')
	else
	    set(h.endORdirtitle,'Style','push','CallBack','maphlp2(''TrackEnd'')')
	    set(h.endselect,'CallBack','maphlp2(''MouseSelect'')')
	end

	set(h.altlabel,'Style','push','CallBack','maphlp2(''ScalarAltitude'')')
	set(h.proplabel,'Style','push','CallBack','maphlp2(''OtherProperties'')')

	set(h.cancel,'CallBack','maphlp2(''Close'')')
	set(h.apply,'CallBack','maphlp2(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp2(''done'',''trackui'')')

case 'scirclui'         %  Scirclui Interactive Tool
	set(h.helpfig,'Name','Small Circle Tool Help')
	set([h.gc; h.rh; h.onept; h.twopt; h.stlatedit; h.stlonedit; ...
	     h.latORrng; h.lonORaz; h.altedit; h.propedit], 'Enable','off')

	set(h.styletext,'Style','push','CallBack','maphlp2(''CircleStyle'')')
	set(h.modetext,'Style','push','CallBack','maphlp2(''CircleMode'')')
	set(h.anglabel,'Style','push','CallBack','maphlp2(''AngleLabel'')')

	set(h.sttitle,'Style','push','CallBack','maphlp2(''CircleCenter'')')
	set(h.stselect,'CallBack','maphlp2(''MouseSelect'')')

	set([h.stlatlabel; h.stlonlabel; h.latORrnglabel; h.lonORazlabel],...
	    'CallBack','maphlp2(''BigEdit'')')

    if get(h.onept,'Value')
	    set(h.endORdirtitle,'Style','push','CallBack','maphlp2(''CircleDefinition'')')
	    set(h.endselect,'CallBack','maphlp2(''RadiusUnits'')')
	else
	    set(h.endORdirtitle,'Style','push','CallBack','maphlp2(''CirclePoint'')')
	    set(h.endselect,'CallBack','maphlp2(''MouseSelect'')')
	end

	set(h.altlabel,'Style','push','CallBack','maphlp2(''ScalarAltitude'')')
	set(h.proplabel,'Style','push','CallBack','maphlp2(''OtherProperties'')')

	set(h.cancel,'CallBack','maphlp2(''Close'')')
	set(h.apply,'CallBack','maphlp2(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp2(''done'',''scirclui'')')

case 'surfdist'         %  Surface Distance Interactive Tool
	set(h.helpfig,'Name','Surface Distance Help')
	set([h.gc; h.rh; h.onept; h.twopt; h.stlatedit; h.stlonedit; ...
	     h.endlatedit; h.endlonedit; h.azedit; h.rngedit], 'Enable','off')

	set(h.styletext,'Style','push','CallBack','maphlp2(''SurfaceStyle'')')
	set(h.modetext,'Style','push','CallBack','maphlp2(''SurfaceMode'')')
	set(h.anglabel,'Style','push','CallBack','maphlp2(''AngleLabel'')')
	set(h.showtrack,'Style','push','CallBack','maphlp2(''ShowTrack'')')

	set(h.sttitle,'Style','push','CallBack','maphlp2(''DistanceStart'')')
	set(h.stselect,'CallBack','maphlp2(''MouseSelect'')')

	set(h.endtitle,'Style','push','CallBack','maphlp2(''DistanceEnd'')')
	set(h.endselect,'CallBack','maphlp2(''MouseSelect'')')

    set(h.dirtitle,'Style','push','CallBack','maphlp2(''DistanceDirection'')')
    set(h.rngselect,'CallBack','maphlp2(''RangeUnits'')')

	set(h.cancel,'CallBack','maphlp2(''Close'')')
	set(h.apply,'CallBack','maphlp2(''Compute'')')
	set(h.help,'String','Done','CallBack','maphlp2(''done'',''surfdist'')')

case 'rangeunits'         %  Range Units modal dialog
	set(h.helpfig,'Name','Range Units Help')
	set([h.poprng; h.geoidedit], 'Enable','off')

	set(h.poplabel,'Style','push','CallBack','maphlp2(''RangePopup'')')
	set(h.geoidlabel,'Style','push','CallBack','maphlp2(''NormalizingGeoid'')')

	set(h.cancel,'CallBack','maphlp2(''Cancel'')')
	set(h.apply,'CallBack','maphlp2(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp2(''done'',''rangeunits'')')
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function CustomDone(SourceCall,h)

%  CUSTOMDONE will restore the original callback and object state
%  of the modal dialog box upon exit of the help mode.  This is
%  called when the done button is pushed.


switch SourceCall      %  SourceCall identifies the orignal modal dialog
case 'trackui'         %  Trackui Interactive Tool
	set([h.gc; h.rh; h.onept; h.twopt; h.stlatedit; h.stlonedit; ...
	     h.latORaz; h.lonORrng; h.altedit; h.propedit], 'Enable','on')

	set([h.styletext; h.modetext; h.anglabel; h.altlabel; h.proplabel; ...
	     h.sttitle; h.endORdirtitle], 'Style','text','CallBack','')

	set(h.stlatlabel,'CallBack','trackui(''bigedit'',''Starting Latitude'')')
	set(h.stlonlabel,'CallBack','trackui(''bigedit'',''Starting Longitude'')')
	set(h.stselect,'Style','push','CallBack','trackui(''select'')')

    if get(h.onept,'Value')
	    set(h.latORazlabel,'CallBack','trackui(''bigedit'',''Azimuth'')')
	    set(h.lonORrnglabel,'CallBack','trackui(''bigedit'',''Range'')')
	    set(h.endselect,'CallBack','trackui(''rangeunits'')')
	else
	    set(h.latORazlabel,'CallBack','trackui(''bigedit'',''Ending Latitude'')')
	    set(h.lonORrnglabel,'CallBack','trackui(''bigedit'',''Ending Longitude'')')
	    set(h.endselect,'CallBack','trackui(''select'')')
	end

	set(h.cancel,'CallBack','close')
	set(h.apply,'CallBack','trackui(''apply'')')
	set(h.help,'String','Help','CallBack','maphlp2(''initialize'',''trackui'')')

case 'scirclui'         %  Small Circle Interactive Tool
	set([h.gc; h.rh; h.onept; h.twopt; h.stlatedit; h.stlonedit; ...
	     h.latORrng; h.lonORaz; h.altedit; h.propedit], 'Enable','on')

	set([h.styletext; h.modetext; h.anglabel; h.altlabel; h.proplabel; ...
	     h.sttitle; h.endORdirtitle], 'Style','text','CallBack','')

	set(h.stlatlabel,'CallBack','trackui(''bigedit'',''Center Latitude'')')
	set(h.stlonlabel,'CallBack','trackui(''bigedit'',''Center Longitude'')')
	set(h.stselect,'Style','push','CallBack','scirclui(''select'')')

    if get(h.onept,'Value')
	    set(h.latORrnglabel,'CallBack','trackui(''bigedit'',''Radius'')')
	    set(h.lonORazlabel,'CallBack','trackui(''bigedit'',''Azimuth'')')
	    set(h.endselect,'CallBack','scirclui(''rangeunits'')')
	else
	    set(h.latORrnglabel,'CallBack','trackui(''bigedit'',''Circle Latitude'')')
	    set(h.lonORazlabel,'CallBack','trackui(''bigedit'',''Circle Longitude'')')
	    set(h.endselect,'CallBack','trackui(''select'')')
	end

	set(h.cancel,'CallBack','close')
	set(h.apply,'CallBack','scirclui(''apply'')')
	set(h.help,'String','Help','CallBack','maphlp2(''initialize'',''scirclui'')')

case 'surfdist'         %  Surface Distance Interactive Tool
	set([h.gc; h.rh; h.onept; h.twopt; h.stlatedit; h.stlonedit; ...
	     h.endlatedit; h.endlonedit; h.azedit; h.rngedit], 'Enable','on')

	set(h.styletext,'Style','text','CallBack','')
	set(h.modetext,'Style','text','CallBack','')
	set(h.anglabel,'Style','text','CallBack','')
	set(h.showtrack,'Style','check','CallBack','')

	set(h.sttitle,'Style','text','CallBack','')
	set(h.stselect,'CallBack','surfdist(''select'')')

	set(h.endtitle,'Style','text','CallBack','')
	set(h.endselect,'CallBack','surfdist(''select'')')

    set(h.dirtitle,'Style','text','CallBack','')
    set(h.rngselect,'CallBack','surfdist(''rangeunits'')')

	set(h.cancel,'CallBack','close')
	set(h.apply,'CallBack','surfdist(''apply'')')
	set(h.help,'String','Help','CallBack','maphlp2(''initialize'',''surfdist'')')

case 'rangeunits'         %  Range Units modal dialog
	set([h.poprng; h.geoidedit], 'Enable','on')

	set([h.poplabel; h.geoidlabel],'Style','text','CallBack','')

	set(h.cancel,'CallBack','uiresume')
	set(h.apply,'CallBack','trackui(''rangeapply'')')
	set(h.help,'String','Help','CallBack','maphlp2(''initialize'',''rangeunits'')')
end

