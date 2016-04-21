function maphlp3(varargin)

%MAPHLP3  Mapping Toolbox Help Utility for Selected GUIs
%
%  MAPHLP3 enables the help utility for the GUIs listed below.
%  It also processes the help callbacks and restores the
%  calling dialog to its original state (pre-help call).
%
%  MAPHLP3 contains the help utilities for:
%        axesmui and all of the dialog boxes contained in axesmui

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.14.4.3 $  $Date: 2004/02/01 21:58:12 $
%  Written by:  E. Byrns, E. Brown


%  1 or 2 arguments may be supplied to this function.  The
%  first argument is the action string for the switch yard below.
%  The second argument identifies the calling dialog and is used
%  by CustomInit and CustomDone to properly customize the help utility.

%  The help utility change static text to push buttons and then
%  associates the proper callback with these new buttons.  All other
%  dialog controls are disabled.  Upon termination of the utility, the
%  push buttons are returned to their original style.

%  This help file has a particular feature in that the MapProjection
%  popup menu is not disabled in the help mode.  Instead, this control
%  is used to bring up the description of each map file contained in
%  its online help.


switch varargin{1}
case 'initialize'
    h = get(get(0,'CurrentFigure'),'UserData');  %  Get the object handles
    set(h.fig,'CloseRequestFcn','maphlp3(''forceclose'')' )
	 if ~strcmp(computer,'MAC2') & ~strcmp(computer,'PCWIN')
            set(h.fig,'WindowStyle','normal')
	 end

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

	PixelFactor = guifactm('pixels');
	FontScaling =  guifactm('fonts');

%  Create the help dialog box.  Make visible when all objects are drawn

    h.helpfig = figure('Name','',...
                'Units','Points',  'Position',PixelFactor*72*[0.75 0.12 7 2.0],...
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

    h = CustomInit(varargin{2},h);   %  Customize the help callbacks

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

case 'Projection'              %  Help for map projection popup menu
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This popup displays the available map projections.  Specifying ',...
	        'the projection determines the transformation calculations and ',...
			  'the resulting properties of the displayed map.  This list contains ',...
			  'all the projections contained in the Mapping Toolbox. Projections ',...
			  'are listed by type: Cyln=Cylindrical, Pycl=Pseudocylindrical, ',...
				'Coni=Conic, Poly=Polyconic, Pcon=Pseudoconic, ',...
				'Azim=Azimuthal, Pazi=Pseudoazimuthal, Mazi=Modified Azimuthal.'];

   if strcmp(computer,'MAC2') | strcmp(computer,'PCWIN')
	   str2 = ' ';
   else
	   str2 = ['The list items "Page Up" and "Page Down" allow paging ',...
		        'through the list of projections.  This platform ',...
				  'does not support scrolling of popup menus if the menu exceeds ',...
				  'the height of the monitor.'];
   end
   set(h.helptext,'String',{str1,' ',str2})

case 'ProjectionPopup'              %  Help for individual map projections
	h = get(get(0,'CurrentFigure'),'UserData');
   set(h.projection,'Interruptible','on')

   listdata = get(h.projection,'UserData');    %  Map  id strings
	indx = listdata.offset*listdata.pagelength + get(h.projection,'Value');

   if strcmp('Page Down',deblank(listdata.idstr(indx,:)))
       listdata.offset = listdata.offset+1;
		 if listdata.offset > listdata.maxoffset;  listdata.offset = 0;  end
	    indx = listdata.offset*listdata.pagelength + 2;
	    stindx  = listdata.offset*listdata.pagelength + 1;
       endindx = (listdata.offset+1)*listdata.pagelength;

	    set(h.projection,'String',listdata.namestr(stindx:endindx,:),...
	                     'Value',indx-stindx+1,'UserData',listdata)

   elseif strcmp('Page Up',deblank(listdata.idstr(indx,:)))
       listdata.offset = listdata.offset-1;
		 if listdata.offset < 0;  listdata.offset = listdata.maxoffset;  end
	    indx = (listdata.offset+1)*listdata.pagelength - 1;
	    stindx  = listdata.offset*listdata.pagelength + 1;
       endindx = (listdata.offset+1)*listdata.pagelength;

	    set(h.projection,'String',listdata.namestr(stindx:endindx,:),...
	                     'Value',indx-stindx+1,'UserData',listdata)
   else

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

		PixelFactor = guifactm('pixels');
		FontScaling =  guifactm('fonts');

	    newdialog = dialog('Units','Points',  'Position',PixelFactor*[25 10 500 420],...
	             'Name',[deblank(listdata.namestr(indx,:)),' Projection'],...
					 'Visible','off','CloseRequestFcn','uiresume');
       colordef(newdialog,'white');    figclr = get(newdialog,'Color');

       helptext = uicontrol(newdialog,'Style','Text',...
	            'String',help(deblank(listdata.idstr(indx,:))), ...
                'Units','Normalized','Position', [0.05  0.08  0.90  0.90], ...
			       'FontWeight','bold',  'FontSize',FontScaling*10, ...
			       'HorizontalAlignment', 'left',...
			       'ForegroundColor', 'black','BackgroundColor', figclr);

       OKbtn = uicontrol(newdialog,'Style','push',...
	             'String','OK', ...
                'Units','Normalized','Position', [0.45  0.01  0.10  0.05], ...
			       'FontWeight','bold',  'FontSize',FontScaling*10, ...
			       'ForegroundColor', 'black','BackgroundColor', figclr,...
				    'CallBack','uiresume');

       set(newdialog,'Visible','on')
		 uiwait(newdialog);  delete(newdialog)
		 figure(h.fig) 
	end

case 'ZoneButton'              %  Help for zone pick interface
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The Zone property defines the geographic zone coverage for ',...
			'UTM and UPS projections.'];
	str2 = ['Pressing the zone push button will bring up an interface for ',...
			'choosing a UTM zone on a world map display.  The zone edit ',...
			'box can be used to enter valid UTM or UPS zone designations.  ',...
			'Recognized UTM zones are integers from 1 to 60 or numbers followed ',...
			'by letters from C to X.  There are two UPS zones: north and south.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'Geoid'              %  Help for geoid edit boxes and popup menu
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The Geoid parameter defines the ellipsoidal model of the Earth used in ',...
			'the projection calculations. The Geoid parameter is of the form ',...
			'[semimajor-axis eccentricity]. Projected coordinates are in the units ',...
			'of the semi-major axis. '];
	str2 = ['The Geoid parameter can be specified in the edit boxes or using the popup menu. ',...
			'For UTM and UPS projections, the default units are in meters.  All other ',...
	        'projections default to kilometers.'];
	str3 = ['For UTM projections, asterisks are shown next to the geoid ',...
	        'definitions that are recommended for a particular zone.'];

   set(h.helptext,'String',{str1,' ',str2,' ',str3})

case 'ProjectionAngleUnits'    %  Help for projecion angle units popup menu
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Use this popup to define the angle units used in the ',...
	        'map projection.  All angles entered in the Projection ',...
			  'Control dialog boxes must be supplied in the specified units.'];
	str2 = ['If the angle units are changed, this has no effect on the ',...
	        'current map display, although the dialog entries will be ',...
			  'updated to reflect the new units.  However, all subsequent ',...
			  'data projected on the map must be supplied in the specified ',...
			  'units.'];
    set(h.helptext,'String',{str1,' ',str2})

case 'MapAspect'    %  Help for Map Aspect popup menu
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This property controls the orientation of the base projection ',...
	        'on a page.  When aspect is normal, "north" (on the base projection) ',...
			  'is up.  In transverse aspect, "north" (in the base projection) ',...
			  'is to the right.'];
	str2 = ['A cylindrical projection of the whole ',...
	        'world looks like a "landscape" display under normal aspect, and ',...
			  'like a "portrait" under a transverse aspect.'];
	str3 = ['Use a Map Origin Orientation of -90 degrees with a transverse aspect ',...
			'to create a standard transverse projection.' ];
    set(h.helptext,'String',{str1,' ',str2,' ',str3})

case 'MapLatLimits'    %  Help for Map Latitude Limits
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The Map Latitude Limit property controls the north and south ',...
	        'latitude of the map display.  The north and south latitudes ',...
			  'establish the extent of meridian lines, regardless of the ',...
			  'Meridian Limit Property (See Grid Settings). They also ',...
			  'specify the default coverage of matrix maps and default parallels.'];
	str2 = ['The extent of the map data is always measured in Greenwich ',...
	        'coordinates, regardless of the origin and orientation setting.'];
	str3 = ['In the normal aspect, the map display is trimmed to the minimum ',...
			'of the Map and Frame Limits.'];
    set(h.helptext,'String',{str1,' ',str2,' ',str3})

case 'MapLonLimits'    %  Help for Map Longitude Limits
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The Map Longitude Limit property controls the east and west ',...
	        'longitude of the map display.  The east and west longitudes ',...
			  'establish the extent of parallel lines, regardless of the ',...
			  'Parallel Limit Property (See Grid Settings). They also ',...
			  'specify the default coverage of matrix maps.'];
	str2 = ['The extent of the map data is always measured in Greenwich ',...
	        'coordinates, regardless of the origin and orientation setting.'];
	str3 = ['In the normal aspect, the map display is trimmed to the minimum ',...
			'of the Map and Frame Limits.'];
    set(h.helptext,'String',{str1,' ',str2,' ',str3})

case 'FrameLatLimits'    %  Help for Frame Latitude Limits
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The Frame Latitude Limit property controls the north and south ',...
	        'extent of the frame display.  All map data will be trimmed ',...
			  'at the specified frame limits.  For azimuthal projections, the ',...
			  'latitude limits should be set to -inf and the desired trim distance ',...
			  'from the map origin.'];
	str2 = ['The Frame Limits are always measured in the base projection ',...
	        'system.  Angles are from the ',...
	        'Map Origin at the center of the frame.'];
	str3 = ['In the normal aspect, the map display is trimmed to the minimum ',...
			'of the Map and Frame Limits.'];
    set(h.helptext,'String',{str1,' ',str2,' ',str3})

case 'FrameLonLimits'    %  Help for Frame Longitude Limits
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The Frame Longitude Limit property controls the east and west ',...
	        'extent of the frame display.  All map data will be trimmed ',...
			  'at the specified frame limits.'];
	str2 = ['The Frame Limits are always measured in the base projection ',...
	        'system.  Angles are from the ',...
	        'Map Origin at the center of the frame.'];
	str3 = ['In the normal aspect, the map display is trimmed to the minimum ',...
			'of the Map and Frame Limits.'];
    set(h.helptext,'String',{str1,' ',str2,' ',str3})

case 'MapOrigin'    %  Help for Map Origin edit boxes
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The Map Origin specifies the Greenwich point which is placed ',...
	        'in the center of the base projection.  The latitude entry ',...
			  'determines if the projection is normal aspect (0 degrees) or ',...
			  'a simple oblique (latitude not 0 degrees).  The longitude ',...
			  'entry will set the central meridian of the projection.'];
	str2 = ['If either entry is left blank, then 0 degrees is used.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'MapOrientation'    %  Help for Map Orientation edit boxes
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The Map Orientation specifies the azimuth angle of the ',...
	        'north pole relative to the map origin.  Azimuth is ',...
			  'measured clockwise from the top of the projection.  If the ',...
			  'orientation is 0, then the north pole lies at the top of ',...
			  'the display.  If the orientation is -90 degrees, then a ',...
			  'transverse aspect map results.  If orientation is ',...
			  'any other number, then a skew oblique projection results.'];
	str2 = ['If the orientation edit box is disabled, then the current ',...
	        'projection has a fixed orientation by definition.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'MapFalseEandN'    %  Help for False Easting and Northing edit boxes
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The Map False Easting and Northing parameters specify a ',...
	        'coordinate shift for projection calculations.'];
	str2 = ['The FalseEasting and FalseNorthing is in the same units as ',...
	        'the projected coordinates, i.e., units of the first element of ',...
			'the Geoid map axes property.'];
	str3 = ['False eastings and northings are sometimes used to ensure ',...
	        'non-negative values of the projected coordinates. For example, ',...
			'the Universal Transverse Mercator uses a false easting of ',...
			'500,000 meters and a false northing of 10,000,000 meters in ',...
			'the southern hemisphere.'];
    set(h.helptext,'String',{str1,' ',str2,' ',str3})

case 'MapScalefactor'    %  Help for Map Scalefactor edit boxes
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The Map Scale Factor modifies the size of the map in the ',...
	        'projected coordinates.  The geographic coordinates are ',...
			'transformed to Cartesian coordinates by the map projection ',...
			'equations, and then multiplied by the scale factor.'];
	str2 = ['Scale factors are used to minimize the scale distortion ',...
	        'in a map projection. For example, the Universal Transverse ',...
			'Mercator uses a scale factor of 0.996 to shift the line ',...
			'of zero scale distortion to two lines on either side of ',...
			'the central meridian.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'MapParallel'    %  Help for Map Parallel edit boxes
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['The Map Parallels specify the standard parallels of the ',...
	        'selected projection.'];
	str2 = ['The default settings are points 1/6 from the top and bottom ',...
	        'of the map latitude limits.  If only one box is displayed, ',...
			  'then this projection has only one standard parallel.  If two ',...
			  'boxes are displayed then the projection can have one or two ',...
			  'standard parallels.  If the parallels edit box is disabled, ',...
			  'then the current projection has no standard parallels or has fixed standard parallels.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'FrameButton'              %  Help for Frame push buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Pressing this button will bring up an additional dialog ',...
	        'window allowing the map frame settings to be specified.'];
   set(h.helptext,'String',str1)

case 'GridButton'              %  Help for Grid push buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Pressing this button will bring up an additional dialog ',...
	        'window allowing the map grid settings to be specified.'];
   set(h.helptext,'String',str1)

case 'LabelButton'              %  Help for Label push buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Pressing this button will bring up an additional dialog ',...
	        'window allowing the map parallel and meridian label ',...
			  'settings to be specified.'];
   set(h.helptext,'String',str1)

case 'DefaultButton'                    %  Help for the default button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Pressing this button will update and compute the default ',...
	        'settings given the currently specified map parameters.  ',...
			  'Only blank map parameters will be affected by this action.'];
	str2 = ['The Fill in button is particularly useful to reset the ',...
	        'Map Frame limits when switching projections.  Simply clear ',...
			  'the Map Frame entries and then press the Fill in button to ',...
			  'update the frame to the largest possible size for the ',...
			  'specified projection.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'ResetButton'                    %  Help for the reset button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Pressing this button will reset the default settings for the ',...
	        'listed map projection, regardless of the current entries ',...
			  'in the map structure.'];
	str2 = ['For example, if the Reset button is pushed and confirmed, ',...
	        'the map grid and frame will be reset to their default ',...
			  'colors and display state (off).'];
   set(h.helptext,'String',{str1,' ',str2})

case 'Frame'              %  Help for Frame on/off Radio Buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines if the Map Frame is visible.'];
   set(h.helptext,'String',str1)

case 'FFaceColor'         %  Help for Frame Face Color popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines the color used for the background of the Map Frame.  ',...
	        'On a map with only land patches displayed, setting the ',...
			  'frame background color is a convenient way to fill oceans and ',...
			  'other bodies of water.  Selecting "none" will make the frame ',...
			  'background transparent (ie:  same as the axes color).'];
	str2 = ['If "Custom" is selected, then any RBG triple can be previewed ',...
	        'and selected.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'FEdgeColor'         %  Help for Frame Edge Color popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines the color used for the edge of the Map Frame.  ',...
	        'Selecting "none" will hide the frame edge.  ',...
			  'If "Custom" is selected, then any RBG triple can be previewed ',...
	        'and selected.'];
   set(h.helptext,'String',str1)

case 'FWidth'         %  Help for Frame Width edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry determines the width of the Map Frame edge, measured ',...
	        'in points.'];
   set(h.helptext,'String',str1)

case 'FFill'         %  Help for Frame Points/edge edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry determines the number of points used to display ',...
	        'each edge of the Map Frame.  An entry of 100 results in a ',...
			  'total of 400 points used to display the frame.'];
   set(h.helptext,'String',str1)

case 'Grid'              %  Help for Grid on/off Radio Buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines if the Map Grid is visible.'];
   set(h.helptext,'String',str1)

case 'GridColor'         %  Help for Grid Color popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines the color used for the grid lines.  ',...
           'If "Custom" is selected, then any RBG triple can be previewed ',...
	        'and selected.'];
   set(h.helptext,'String',str1)

case 'GridStyle'         %  Help for Grid Style popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines the line style used to display a map grid.'];
   set(h.helptext,'String',str1)

case 'GWidth'         %  Help for Grid Width edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry determines the width of the grid lines, measured ',...
	        'in points.'];
   set(h.helptext,'String',str1)

case 'GAltitude'         %  Help for Grid Altitude edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry determines the plane in which the map grid is drawn.  ',...
	        'With this property, the grid lines can be placed in front of or ',...
			  'behind displayed map objects.  The default plane for map objects ',...
			  'is z = 0.  If this property is set to INF, then the map grid ',...
			  'is drawn just outside the current upper limit of the z axis, ',...
			  'which places the grid on top of all displayed objects.'];
   set(h.helptext,'String',str1)

case 'GridSettings'         %  Help for Grid Settings push button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Pressing this button will bring up an additional dialog ',...
	        'window allowing properties specific to the parallel or ',...
			  'meridian grid to be modified.'];
   set(h.helptext,'String',str1)

case 'MeridianLabels'              %  Help for Meridian Labels on/off Radio Buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines if the meridian labels are visible.'];
   set(h.helptext,'String',str1)

case 'ParallelLabels'              %  Help for Parallel Labels on/off Radio Buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines if the parallel labels are visible.'];
   set(h.helptext,'String',str1)

case 'LabelColor'         %  Help for Label Color popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines the color used for the parallel and meridian labels.  ',...
           'If "Custom" is selected, then any RBG triple can be previewed ',...
	        'and selected.'];
   set(h.helptext,'String',str1)

case 'LabelAngle'         %  Help for Label Angle popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines the character slant on displayed parallel and ',...
	        'meridian labels.  "Normal" specifies non-italic font, while ',...
			  '"Italic" and "Oblique" specify an italic font.'];
   set(h.helptext,'String',str1)

case 'LabelFont'         %  Help for Label Font edit box
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines the character font used to display parallel and ',...
	        'meridian labels.  The entered name must be a font existing ',...
			  'on the computer.  If the specified font does not exist, then ',...
			  'a default of "Helvetica" is used.'];
	str2 = ['Pressing this button provides a preview of the specified font.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'LabelFormat'         %  Help for Label Format popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines the format used to display parallel and ',...
	        'meridian labels.  If "compass" is selected, labels ',...
			  'are suffixed with an "E,W,N,S" for east, west, north or ',...
			  'south respectively.  If "signed" is used, then labels are ',...
			  'prefixed with a "+" for east and north, and "-" for west and ',...
			  'south.  If "none" is selected, then labels are prefixed with ',...
			  '"-" for west and south, but no prefix is used for east and north.'];
   set(h.helptext,'String',str1)

case 'LabelUnits'         %  Help for Label Units popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines the angle units used to display parallel and ',...
	        'meridian labels.  The labels are displayed in these units, ',...
			  'regardless of the Map Angle Units setting.'];
   set(h.helptext,'String',str1)

case 'LabelSize'         %  Help for Label Size edits
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This is a scalar entry specifying the size of the meridian ',...
	        'and parallel labels, in the units specified ',...
			  'by the Font Units entry.'];
   set(h.helptext,'String',str1)

case 'LabelFontUnits'         %  Help for LabelFontUnits popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This specifies the units of the Font Size entry.  ',...
	        'If it is set to "normalized", then the font size is a ',...
			  'fraction (between 0 and 1) of the figure window.'];
   set(h.helptext,'String',str1)

case 'LabelWeight'         %  Help for Label Weight popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines the character weight used to display parallel and ',...
	        'meridian labels.'];
   set(h.helptext,'String',str1)

case 'LabelSettings'         %  Help for Label Settings push button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Pressing this button will bring up an additional dialog ',...
	        'window allowing properties specific to the parallel or ',...
			  'meridian labels to be modified.'];
   set(h.helptext,'String',str1)

case 'MeridianLocation'         %  Help for Meridian Label Location popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry specifies the meridians to be labeled.  ',...
	        'The label locations need not correspond to displayed meridian ',...
			  'lines.  A scalar entry results in evenly spaced meridian labels, ',...
			  'starting at the Prime Meridian and proceeding east ',...
			  'and west.  If a vector of longitudes is entered (enclosed in square brackets), ',...
			  'meridian labels will be displayed at the locations given by ',...
			  'elements of the vector. Entries must be provided in the angle ',...
			  'units of the current map axes.'];
   set(h.helptext,'String',str1)

case 'MParallel'         %  Help for M Parallel popup and edit
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry specifies the latitude at which the meridian labels ',...
	        'will be drawn.  A scalar latitude may be entered in the edit box.'];
	str2 = ['If the edit box is empty, then the specification chosen from the ',...
	        'popup menu is used.  "north" refers to the maximum ',...
			  'and "south" to the minimum of Map Latitude Limits.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'ParallelLocation'         %  Help for Parallel Label Location popup
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry specifies the parallels to be labeled.  ',...
	        'The label locations need not correspond to displayed parallel ',...
			  'lines.  A scalar entry results in evenly spaced parallel labels, ',...
			  'starting at the Equator and proceeding north ',...
			  'and south.  If a vector of latitudes is entered (enclosed in square brackets), ',...
			  'parallel labels will be displayed at the locations given by ',...
			  'elements of the vector. Entries must be provided in the angle ',...
			  'units of the current map axes.'];
   set(h.helptext,'String',str1)

case 'PMeridian'         %  Help for P Meridian popup and edit
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry specifies the longitude at which the parallel labels ',...
	        'will be drawn.  A scalar longitude may be entered in the edit box.'];
	str2 = ['If the edit box is empty, then the specification chosen from the ',...
	        'popup menu is used.  "east" refers to the maximum ',...
			  'and "west" to the minimum of Map Longitude Limits.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'Round'         %  Help for Meridian and Parallel Round edit
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry specifies to which power of ten the corresponding labels ',...
	        'will be rounded.  For example, if the entry is -1, the labels ',...
			  'are rounded to the tenths position.'];
   set(h.helptext,'String',str1)

case 'MeridianGrids'              %  Help for MeridianGrids on/off Radio Buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines if the meridians will be visible when the grid ',...
	        'is turned on.'];
   set(h.helptext,'String',str1)

case 'MLocationGrids'              %  Help for MLocationGrids
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry specifies the meridians that will be displayed.  ',...
	        'A scalar entry results in evenly spaced meridian lines, ',...
			  'starting at the Prime Meridian and proceeding east ',...
			  'and west.  If a vector of longitudes is entered (enclosed in square brackets), ',...
			  'meridian lines will be displayed at the locations given by ',...
			  'elements of the vector. Entries must be provided in the angle ',...
			  'units of the current map axes.'];
   set(h.helptext,'String',str1)

case 'MeridianLimits'              %  Help for MeridianLimits
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry specifies the parallels beyond which the meridian ',...
	        'grids do not extend.  By default, this property is empty, which ',...
			  'allows the meridian lines to extend to the Map Latitude Limits.  ',...
			  'If an entry is provided, it must be a two-element vector, ',...
			  'enclosed in square brackets.'];
   set(h.helptext,'String',str1)

case 'MeridianExceptions'              %  Help for MeridianExceptions
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry specifies the meridians which are exceptions to the ',...
			  'Meridian Latitude Limits. Unlike the other meridians, these exceptions extend beyond the ',...
	        'parallel given by the Meridian Latitude Limits.  This entry ',...
			  'is a vector containing the longitudes of the meridians to extend.  This property, ',...
			  'in conjunction with the Meridian Latitude Limits, is especially ',...
			  'useful for controlling of the grid lines near the poles.'];
   set(h.helptext,'String',str1)

case 'MeridianFill'              %  Help for MeridianFill
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This scalar entry specifies the number of points to be used to ',...
	        'construct each meridian line.  The default is 100 points.'];
   set(h.helptext,'String',str1)

case 'ParallelGrids'              %  Help for ParallelGrids on/off Radio Buttons
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This determines if the parallels will be visible when the grid ',...
	        'is turned on.'];
   set(h.helptext,'String',str1)

case 'PLocationGrids'              %  Help for PLocationGrids
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry specifies the parallels which will be displayed.  ',...
	        'A scalar entry results in evenly spaced parallel lines, ',...
			  'starting at the Equator and proceeding north ',...
			  'and south.  If a vector of latitudes is entered (enclosed in square brackets), ',...
			  'parallel lines will be displayed at the locations given by ',...
			  'elements of the vector. Entries must be provided in the angle ',...
			  'units of the current map axes.'];
   set(h.helptext,'String',str1)

case 'ParallelLimits'              %  Help for ParallelLimits
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry specifies the meridians beyond which the parallel ',...
	        'grids do not extend.  By default, this property is empty, which ',...
			  'allows the parallel lines to extend to the Map Longitude Limits.  ',...
			  'If an entry is provided, it must be a two-element vector, ',...
			  'enclosed in square brackets.'];
   set(h.helptext,'String',str1)

case 'ParallelExceptions'              %  Help for ParallelExceptions
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This entry specifies the parallels which are exceptions to the ',...
			  'Parallel Longitude Limits. Unlike the other parallels, these exceptions extend beyond the ',...
	        'meridian given by the Parallel Longitude Limits.  This entry ',...
			  'is a vector containing the latitudes of the parallel to extend.  This property, ',...
			  'in conjunction with the Parallel Longitude Limits, is especially ',...
			  'useful for controlling of the grid lines near the edges of a map.'];
   set(h.helptext,'String',str1)

case 'ParallelFill'              %  Help for ParallelFill
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['This scalar entry specifies the number of points to be used to ',...
	        'construct each parallel line.  The default is 100 points.'];
   set(h.helptext,'String',str1)

case 'Apply'                    %  Help for the apply button
	h = get(get(0,'CurrentFigure'),'UserData');
	str = ['Pressing the Apply button will apply the specified settings ',...
	       'to the current map.  This will cause the current map to be ',...
			 'reprojected.'];
   set(h.helptext,'String',str)

case 'Accept'                    %  Help for the accept button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Pressing the Accept button will update the map projection structure with ',...
	        'the current properties.'];
	str2 = ['The Apply button on the Projection Control Dialog must still ',...
	        'be pressed for these changes to be applied to the current map.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'CancelMain'                    %  Help for the Projection Control cancel button
	h = get(get(0,'CurrentFigure'),'UserData');
	str1 = ['Pressing the Cancel button will abort the current operation.'];
	str2 = ['If an error condition has been encountered, the current map ',...
	        'will be updated to its original settings.'];
   set(h.helptext,'String',{str1,' ',str2})

case 'Cancel'                    %  Help for other cancel button
	h = get(get(0,'CurrentFigure'),'UserData');
	str = ['Pressing the Cancel button will abort the current operation.'];
   set(h.helptext,'String',str)
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function h = CustomInit(SourceCall,h)

%  CUSTOMINIT will initialize the help callbacks and object states
%  of the modal dialog box upon entering of the help mode.  This is
%  called when the help button is pushed.


switch SourceCall      %  SourceCall identifies the orignal modal dialog
case 'axesmui'         %  Axesmui Main Dialog
	set(h.helpfig,'Name','Projection Control Help')

    str1 = ['Press Any Button (excluding "Done") or Select an Item from ',...
	        'the Map Projection list for Help'];
	 str2 = 'Press "Done" to Exit Help';
    set(h.helptext,'String',{str1,' ',str2})

	zonestate = {get(h.zonebtn,'Enable') get(h.zone,'Enable')};
	set(h.zonebtn,'Enable','on','UserData',zonestate)

	set([h.angleunits; h.maplat(:); h.maplon(:); h.frmlat(:);...
	     h.frmlon(:); h.origin(:); h.parallel(:); h.aspect; ...
		 h.geoid(:); h.geoidpop; h.falseE; h.falseN; h.sf; ...
		 h.zone], 'Enable','off')
	
	set(h.projectionlabel,'Style','push','CallBack','maphlp3(''Projection'')')
 	set(h.geoidlabel,'Style','push','CallBack','maphlp3(''Geoid'')')
	set(h.anglelabel,'Style','push','CallBack','maphlp3(''ProjectionAngleUnits'')')
	set(h.maplatlabel,'Style','push','CallBack','maphlp3(''MapLatLimits'')')
	set(h.maplonlabel,'Style','push','CallBack','maphlp3(''MapLonLimits'')')
	set(h.frmlatlabel,'Style','push','CallBack','maphlp3(''FrameLatLimits'')')
	set(h.frmlonlabel,'Style','push','CallBack','maphlp3(''FrameLonLimits'')')
	set(h.originlatlon,'Style','push','CallBack','maphlp3(''MapOrigin'')')
	set(h.orientation,'Style','push','CallBack','maphlp3(''MapOrientation'')')
	set(h.falseENlabel,'Style','push','CallBack','maphlp3(''MapFalseEandN'')')
	set(h.sflabel,'Style','push','CallBack','maphlp3(''MapScalefactor'')')
	set(h.parallellabel,'Style','push','CallBack','maphlp3(''MapParallel'')')
	set(h.aspectlbl,'Style','push','CallBack','maphlp3(''MapAspect'')')

	set(h.projection,'CallBack','maphlp3(''ProjectionPopup'')')
	set(h.zonebtn,'CallBack','maphlp3(''ZoneButton'')')
	set(h.framebtn,'CallBack','maphlp3(''FrameButton'')')
	set(h.gridbtn,'CallBack','maphlp3(''GridButton'')')
	set(h.labelbtn,'CallBack','maphlp3(''LabelButton'')')
	set(h.defaultbtn,'CallBack','maphlp3(''DefaultButton'')')
	set(h.resetbtn,'CallBack','maphlp3(''ResetButton'')')

	set(h.cancel,'CallBack','maphlp3(''CancelMain'')')
	set(h.apply,'CallBack','maphlp3(''Apply'')')
	set(h.help,'String','Done','CallBack','maphlp3(''done'',''axesmui'')')

%  Save the current projection index setting

   h.saveindx = get(h.projection,'Value');
	listdata   = get(h.projection,'UserData');
	h.saveoffset = listdata.offset;

case 'frame'         %  Frame Dialog
	set(h.helpfig,'Name','Frame Control Help')

	set([h.frameon; h.frameoff; h.facecolor; h.edgecolor;...
	     h.widthedit; h.filledit], 'Enable','off')

	set(h.frametitle,'Style','push','CallBack','maphlp3(''Frame'')')
	set(h.facetext,'Style','push','CallBack','maphlp3(''FFaceColor'')')
	set(h.edgetext,'Style','push','CallBack','maphlp3(''FEdgeColor'')')
	set(h.widthtext,'Style','push','CallBack','maphlp3(''FWidth'')')
	set(h.filltext,'Style','push','CallBack','maphlp3(''FFill'')')

	set(h.cancel,'CallBack','maphlp3(''Cancel'')')
	set(h.apply,'CallBack','maphlp3(''Accept'')')
	set(h.help,'String','Done','CallBack','maphlp3(''done'',''frame'')')

case 'grid'         %  Grid Dialog
	set(h.helpfig,'Name','Grid Control Help')

	set([h.gridon; h.gridoff; h.color; h.style; h.widthedit; h.altedit], ...
	    'Enable','off')

	set(h.gridtitle,'Style','push','CallBack','maphlp3(''Grid'')')
	set(h.colortext,'Style','push','CallBack','maphlp3(''GridColor'')')
	set(h.styletext,'Style','push','CallBack','maphlp3(''GridStyle'')')
	set(h.widthtext,'Style','push','CallBack','maphlp3(''GWidth'')')
	set(h.alttext,'Style','push','CallBack','maphlp3(''GAltitude'')')
   set(h.settings,'CallBack','maphlp3(''GridSettings'')')

	set(h.cancel,'CallBack','maphlp3(''Cancel'')')
	set(h.apply,'CallBack','maphlp3(''Accept'')')
	set(h.help,'String','Done','CallBack','maphlp3(''done'',''grid'')')

case 'labels'         %  Labels Dialog

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

	set(h.helpfig,'Name','Map Labels Control Help',...
	              'Units','Points',  'Position',PixelFactor*72*[0.75 0.12 7 1.8])

	set([h.meridianon; h.meridianoff; h.parallelon; h.paralleloff; ...
	     h.format;     h.units;       h.fontedit;   h.sizeedit; ...
		  h.fontwt;     h.fontclr;     h.fontunits;  h.fontangle], ...
	    'Enable','off')

	set(h.meridiantitle,'Style','push','CallBack','maphlp3(''MeridianLabels'')')
	set(h.paralleltitle,'Style','push','CallBack','maphlp3(''ParallelLabels'')')
	set(h.formattitle,'Style','push','CallBack','maphlp3(''LabelFormat'')')
	set(h.unitstitle,'Style','push','CallBack','maphlp3(''LabelUnits'')')
	set(h.fonttitle,'Style','push','CallBack','maphlp3(''LabelFont'')')
	set(h.sizetitle,'Style','push','CallBack','maphlp3(''LabelSize'')')
	set(h.fontunitstitle,'Style','push','CallBack','maphlp3(''LabelFontUnits'')')
	set(h.fontclrtitle,'Style','push','CallBack','maphlp3(''LabelColor'')')
	set(h.fontwttitle,'Style','push','CallBack','maphlp3(''LabelWeight'')')
	set(h.fontangtitle,'Style','push','CallBack','maphlp3(''LabelAngle'')')

   set(h.settings,'CallBack','maphlp3(''LabelSettings'')')

	set(h.cancel,'CallBack','maphlp3(''Cancel'')')
	set(h.apply,'CallBack','maphlp3(''Accept'')')
	set(h.help,'String','Done','CallBack','maphlp3(''done'',''labels'')')

case 'labelsetting'         %  Label Setting Dialog
	set(h.helpfig,'Name','Label Settings Help')

	set([h.mlocateedit; h.mparallelpopup; h.mparalleledit; h.mroundedit; ...
	     h.plocateedit; h.pmeridianpopup; h.pmeridianedit; h.proundedit], ...
	    'Enable','off')

	set(h.mlocatetext,'Style','push','CallBack','maphlp3(''MeridianLocation'')')
	set(h.mparalleltext,'Style','push','CallBack','maphlp3(''MParallel'')')
	set(h.mroundtext,'Style','push','CallBack','maphlp3(''Round'')')
	set(h.plocatetext,'Style','push','CallBack','maphlp3(''ParallelLocation'')')
	set(h.pmeridiantext,'Style','push','CallBack','maphlp3(''PMeridian'')')
	set(h.proundtext,'Style','push','CallBack','maphlp3(''Round'')')

	set(h.cancel,'CallBack','maphlp3(''Cancel'')')
	set(h.apply,'CallBack','maphlp3(''Accept'')')
	set(h.help,'String','Done','CallBack','maphlp3(''done'',''labelsetting'')')

case 'gridsetting'         %  Grid Setting Dialog

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

	PixelFactor = guifactm('pixels');
	FontScaling =  guifactm('fonts');

	set(h.helpfig,'Name','Grid Settings Help',...
	              'Units','Points',  'Position',PixelFactor*72*[0.75 0.05 7 1.5])

	set([h.meridianon;  h.meridianoff; h.longedit; h.mlimitedit; ...
	     h.longexcedit; h.mfilledit; ...
		  h.parallelon;  h.paralleloff; h.latedit; h.plimitedit; ...
	     h.latexcedit; h.pfilledit], 'Enable','off')

	set(h.mtitle,'Style','push','CallBack','maphlp3(''MeridianGrids'')')
	set(h.longtext,'Style','push','CallBack','maphlp3(''MLocationGrids'')')
	set(h.mlimits,'Style','push','CallBack','maphlp3(''MeridianLimits'')')
	set(h.longexctext,'Style','push','CallBack','maphlp3(''MeridianExceptions'')')
	set(h.mfilltext,'Style','push','CallBack','maphlp3(''MeridianFill'')')

	set(h.ptitle,'Style','push','CallBack','maphlp3(''ParallelGrids'')')
	set(h.lattext,'Style','push','CallBack','maphlp3(''PLocationGrids'')')
	set(h.plimits,'Style','push','CallBack','maphlp3(''ParallelLimits'')')
	set(h.latexctext,'Style','push','CallBack','maphlp3(''ParallelExceptions'')')
	set(h.pfilltext,'Style','push','CallBack','maphlp3(''ParallelFill'')')

	set(h.cancel,'CallBack','maphlp3(''Cancel'')')
	set(h.apply,'CallBack','maphlp3(''Accept'')')
	set(h.help,'String','Done','CallBack','maphlp3(''done'',''gridsetting'')')
end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function CustomDone(SourceCall,h)

%  CUSTOMDONE will restore the original callback and object state
%  of the modal dialog box upon exit of the help mode.  This is
%  called when the done button is pushed.


switch SourceCall      %  SourceCall identifies the orignal modal dialog
case 'axesmui'         %  Axesmui Main Dialog
	set([h.angleunits; h.maplat(:); h.maplon(:); h.frmlat(:);...
	     h.frmlon(:); h.origin(:); h.parallel(:); h.aspect;...
		 h.geoid(:); h.geoidpop; h.falseE; h.falseN; h.sf], 'Enable','on')
	
	zonestate = get(h.zonebtn,'UserData');
	set(h.zonebtn,'Enable',zonestate{1},'UserData',[])
	set(h.zone,'Enable',zonestate{2})

	set(h.projectionlabel,'Style','push','CallBack','maphlp3(''Projection'')')
	set([h.projectionlabel; h.anglelabel;    h.maplatlabel;  h.maplonlabel; ...
	     h.frmlatlabel;     h.frmlonlabel;   h.originlatlon; ...
	     h.orientation;     h.parallellabel; h.aspectlbl; ...
		 h.geoidlabel;		h.falseENlabel;	 h.sflabel], ...
		  'Style','text','CallBack','')

	set(h.projection,'CallBack','axesmui(''MainDialog'',''Projection'')')
	set(h.zonebtn,'CallBack','axesmui(''MainDialog'',''Zonebtn'')')
	set(h.framebtn,'CallBack','axesmui(''MainDialog'',''Frame'')')
	set(h.gridbtn,'CallBack','axesmui(''MainDialog'',''Grid'')')
	set(h.labelbtn,'CallBack','axesmui(''MainDialog'',''Labels'')')
	set(h.defaultbtn,'CallBack','axesmui(''MainDialog'',''Default'')')
	set(h.resetbtn,'CallBack','axesmui(''MainDialog'',''Reset'')')

	set([h.cancel; h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp3(''initialize'',''axesmui'')')

%  Reset the Projection list string

	listdata   = get(h.projection,'UserData');
   stindx  = h.saveoffset*listdata.pagelength + 1;
   endindx = min((h.saveoffset+1)*listdata.pagelength,size(listdata.namestr,1));

   set(h.projection,'String',listdata.namestr(stindx:endindx,:),...
	                 'Value',h.saveindx)

case 'frame'         %  Frame Dialog
	set([h.frameon; h.frameoff; h.facecolor; h.edgecolor;...
	     h.widthedit; h.filledit], 'Enable','on')

	set([h.frametitle; h.facetext; h.edgetext; h.widthtext; h.filltext],...
	    'Style','text','CallBack','')

	set([h.cancel; h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp3(''initialize'',''frame'')')

case 'grid'         %  Grid Dialog
	set([h.gridon; h.gridoff; h.color; h.style; h.widthedit; h.altedit], ...
	    'Enable','on')

	set([h.gridtitle; h.colortext; h.styletext; h.widthtext; h.alttext],...
	    'Style','text','CallBack','')

   set(h.settings,'CallBack','axesmui(''MainDialog'',''Meridian&Parallel'')')

	set([h.cancel; h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp3(''initialize'',''grid'')')

case 'labels'         %  Labels Dialog
	set([h.meridianon; h.meridianoff; h.parallelon; h.paralleloff; ...
	     h.format;     h.units;       h.fontedit;   h.sizeedit; ...
		  h.fontwt;     h.fontclr;     h.fontunits;  h.fontangle], ...
	    'Enable','on')

	set([h.meridiantitle; h.paralleltitle;   h.formattitle; h.unitstitle;...
	     h.sizetitle;     h.fontunitstitle;  h.fontclrtitle;...
		  h.fontwttitle;   h.fontangtitle], 'Style','text','CallBack','')

   set(h.settings,'CallBack','axesmui(''MainDialog'',''LabelSettings'')')
   set(h.fonttitle,'CallBack','axesmui(''MainDialog'',''FontPreview'')')


	set([h.cancel; h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp3(''initialize'',''labels'')')

case 'labelsetting'         %  Label Setting Dialog
	set([h.mlocateedit; h.mparallelpopup; h.mparalleledit; h.mroundedit; ...
	     h.plocateedit; h.pmeridianpopup; h.pmeridianedit; h.proundedit], ...
	    'Enable','on')

	set([h.mlocatetext; h.mparalleltext;   h.mroundtext;...
	     h.plocatetext; h.pmeridiantext;   h.proundtext],...
		 'Style','text','CallBack','')

	set([h.cancel; h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp3(''initialize'',''labelsetting'')')

case 'gridsetting'         %  Grid Setting Dialog
	set([h.meridianon;  h.meridianoff; h.longedit; h.mlimitedit; ...
	     h.longexcedit; h.mfilledit; ...
		  h.parallelon;  h.paralleloff; h.latedit; h.plimitedit; ...
	     h.latexcedit; h.pfilledit], 'Enable','on')

	set([h.mtitle; h.longtext;   h.mlimits; h.longexctext; h.mfilltext;...
	     h.ptitle; h.lattext;    h.plimits; h.latexctext;  h.pfilltext],...
		 'Style','text','CallBack','')

	set([h.cancel; h.apply],'CallBack','uiresume')
	set(h.help,'String','Help','CallBack','maphlp3(''initialize'',''gridsetting'')')
end

