function scirclui(action,titlestr)

%  SCIRCLUI  Interactive tool for adding small circles to a map
%
%  SCIRCLUI activates the interactive tool and associates it with the
%  current axes.  The current axes must be a map axes.
%
%  SCIRCLUI(hndl)  activates the interactive tool and associates it
%  with the axes specified by hndl.  Again, the axes specified by hndl
%  must be a map axes.
%
%  SCIRCLUI is obsolete. SCIRCLEG interactive circles can be modified 
%  after creation.
%
%  See also SCIRCLEG, TRACKG

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.17.4.1 $  $Date: 2003/08/01 18:22:39 $
%  Written by:  E. Byrns, E. Brown


%  Parse the inputs

if nargin == 0;
	hndl = get(get(0,'CurrentFigure'),'CurrentAxes');
	action = 'initialize';
elseif ~isstr(action);
	hndl = action;
	action = 'initialize';
end


%  Switch yard

switch action
case 'initialize'       %  Activate the tool
    [mstruct,msg] = gcm(hndl);     %  Axes handle test performed here too.
    if ~isempty(msg);    error(msg);   end

    scircluiBox(hndl)               %  Construct the gui
    scirclui('onepoint')            %  Initialize for one point operation
	set(gcf,'HandleVisibility','Callback')

case 'onepoint'         %  Callback for the one point mode radio button
    h = get(get(0,'CurrentFigure'),'UserData');

%  Make mode radio buttons mutually exclusive

    set(h.onept,'Value',1);    set(h.twopt,'Value',0)

%  Set the strings and callbacks to correspond to one point mode

	set(h.endORdirtitle,'String','Size and Sector:')
	set(h.latORrnglabel,'String','Rad', ...
	                   'CallBack','scirclui(''bigedit'',''Radius'')');
	set(h.lonORazlabel,'String','Az', ...
	                   'CallBack','scirclui(''bigedit'',''Azimuth'')');
	set(h.endselect,'String','Radius Units','CallBack','scirclui(''rangeunits'')')
	set([h.latORrng; h.lonORaz],'String','')
    scirclui('rangestring')    %  Update the unit string

case 'twopoint'         %  Callback for the two point mode radio button
    h = get(get(0,'CurrentFigure'),'UserData');

%  Make mode radio buttons mutually exclusive

    set(h.onept,'Value',0);    set(h.twopt,'Value',1)

%  Set the strings and callbacks to correspond to two point mode

	set(h.endORdirtitle,'String','Circle Point:')
	set(h.latORrnglabel,'String','Lat', ...
	                   'CallBack','scirclui(''bigedit'',''Circle Latitude'')');
	set(h.lonORazlabel,'String','Lon', ...
	                   'CallBack','scirclui(''bigedit'',''Circle Longitude'')');
	set(h.endselect,'String','Mouse Select','CallBack','scirclui(''select'')')
	set([h.latORrng; h.lonORaz],'String','')
    set(h.anglabel,'String','Angles in degrees')

case 'rangestring'       %  Update the range string display
    h = get(get(0,'CurrentFigure'),'UserData');

    switch h.unitstring
	case 'Kilometers'
	    set(h.anglabel,'String','Angles in degrees; Radius in kilometers')
	case 'Miles'
	    set(h.anglabel,'String','Angles in degrees; Radius in miles')
	case 'Nautical Miles'
	    set(h.anglabel,'String','Angles in degrees; Radius in nautical miles')
	case 'Radians'
	    set(h.anglabel,'String','Angles in degrees; Radius in radians')
    otherwise
	    error('Unrecognized range unit string')
    end

case 'select'           %  Callback associated with the Mouse Select button
    h = get(get(0,'CurrentFigure'),'UserData');
	if ~ishandle(h.mapaxes)     %  Abort tool if axes is gone
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Circle Tool No Longer Appropriate'},...
							  'Circle Tool Error','modal'));
	    trackui('close');
		 return
	end
    btn = get(h.figure,'CurrentObject');
	editboxes = get(btn,'UserData');      %  Get associated edit boxes

	[lat,lon] = inputm(1,h.mapaxes);      %  Get a point from the map and
    [mstruct,msg] = gcm(h.mapaxes);       %  convert it to degrees.
	datapoint = angledim([lat lon],mstruct.angleunits,'degrees');

    set(editboxes(1),'String',num2str(datapoint(1),'%6.2f'))  %  Update
    set(editboxes(2),'String',num2str(datapoint(2),'%6.2f'))  %  display
	figure(h.figure)

case 'apply'        %  Apply the currently defined small circle to the map
	h = get(get(0,'CurrentFigure'),'UserData');
	if ~ishandle(h.mapaxes)     %  Abort tool if axes is gone
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Circle Tool No Longer Appropriate'},...
							  'Circle Tool Error','modal'));
	    trackui('close');
		 return
	end
    mapstruct = get(h.mapaxes,'UserData');  %  Associated map structure
    commastr  = ',';                        %  Useful string needed later

	if get(h.gc,'Value');    trackstr = '''gc''';   %  Define circle type
	                         tagstr   = '''Small Circle''';
	   else;                 trackstr = '''rh''';
	                         tagstr   = '''Rhumb Line Small Circle''';
	end

%  Get the edit box entries.  If the entries are required, abort if empty

    startlat = get(h.stlatedit,'String');
	startlon = get(h.stlonedit,'String');
	if isempty(startlat) | isempty(startlon)
	     uiwait(errordlg('Center Latitude and Longitude Required',...
		                  'Small Circle Error','modal'));  return
	end

	latORrng  = get(h.latORrng,'String');            %  Empty entries are allowed
	if isempty(latORrng);  latORrng = '[]';  end
	lonORaz = get(h.lonORaz,'String');
	if isempty(lonORaz);  lonORaz = '[]';  end

	zplane = get(h.altedit,'String');      %  Plotting altitude
	znumber = str2num(zplane);
	if isempty(zplane);            znumber = 0;
	   elseif isempty(znumber);    uiwait(errordlg('Invalid Z Plane',...
		                            'Small Circle Error','modal'));  return
	end

	otherprop = get(h.propedit,'String');    %  Other line property string

%  Make a potentially multi-line strings into a single row vector.
%  Eliminate any padding 0s since they mess up a string

    startlat = startlat';   startlat = startlat(:)';
    startlat = startlat(find(startlat));

    startlon = startlon';   startlon = startlon(:)';
    startlon = startlon(find(startlon));

    latORrng = latORrng';   latORrng = latORrng(:)';
    latORrng = latORrng(find(latORrng));

    lonORaz = lonORaz';   lonORaz = lonORaz(:)';
    lonORaz = lonORaz(find(lonORaz));

    otherprop = otherprop';   otherprop = otherprop(:)';
    otherprop = otherprop(find(otherprop));

%  Reset the last error function and set the axes pointer to the
%  associated map axes.  This setting process directs the plot
%  commands to the proper axes without activating the axes figure window.

    lasterr('')
	set(0,'CurrentFigure',get(h.mapaxes,'Parent'));
	set(get(h.mapaxes,'Parent'),'CurrentAxes',h.mapaxes)

    if get(h.twopt,'Value')   %  Two point track definition
        evalstr = ['[lat,lon]=scircle2(',trackstr,commastr,startlat,commastr,...
		            startlon,commastr,latORrng,commastr,lonORaz,commastr,...
				   '[',num2str(mapstruct.geoid),']',commastr,'''degrees'');'];
	    eval(evalstr, 'uiwait(errordlg(lasterr,''Small Circle Error'',''modal''))');

	else      %  One point track definition.  Requires processing of
	          %  the range data based on range units and geoid definition

%  Determine the geoid/radius to use as the normalizing radius for
%  the range entries.

        if strcmp(h.unitstring,'Radians');            normalize = 1;
		    else;              eval(['normalize = ',h.geoidstr,';'])
	    end

%  Compute the normalizing factor.  The range needs to be normalized
%  to radians and then scaled by the appropriate radius as defined by
%  the current map geoid.
%
%   range = range/(normalize radius) * (geoid radius)
%
%  The geoid radius multiplies the expression above because the
%  track1 routine (actually reckon) will divide the range entry
%  by (geoid radius) since [0 0] is not used as the input geoid in track1

%  When a rhumb line is requested, the radius of the rectifying sphere must be
%  used, since reckon is aware of the rectifying sphere.  For the great
%  circles, only the radius (or semimajor axis) is used because this
%  is the factor used in reckon/reckongc.  Great circle reckoning is
%  not aware of ellipsoids.  If that ever changes, be sure to
%  adjust the radfact construction below.

	    if get(h.gc,'Value')
		      radfact = ['*',num2str(mapstruct.geoid(1)/normalize(1),'%16.12f')];
	    else
              radius = rsphere('rectifying',mapstruct.geoid);
		      normalize = rsphere('rectifying',normalize);
		      radfact = ['*',num2str(radius/normalize,'%16.12f')];
	    end

%  Construct the range string.  Account for unit changes if necessary.

        diststr = h.unitstring;   diststr(find(diststr==' ')) = [];
        if strcmp(h.unitstring,'Radians')
		    diststr = lonORaz;
		else
            diststr = ['distdim(',latORrng,',''',diststr,''',''kilometers'')'];
	    end

%  Build up the eval string and process.

        evalstr = ['[lat,lon]=scircle1(',trackstr,commastr,startlat,commastr,...
		            startlon,commastr,...
					diststr,radfact,commastr,lonORaz,commastr,...
					'[',num2str(mapstruct.geoid),']', commastr,'''degrees'');'];
		eval(evalstr, 'uiwait(errordlg(lasterr,''Small Circle Error'',''modal''))');
	end

	if ~isempty(lasterr);  return;   end

%  If no errors, then the scircle1 or scircle2 command successfully
%  completed.  Now display the small circle(s).

	lat = angledim(lat,'degrees',mapstruct.angleunits);
	lon = angledim(lon,'degrees',mapstruct.angleunits);

    if isempty(otherprop)      otherprop = [',''Tag'',',tagstr];
	    else;    otherprop = [',',otherprop,',''Tag'',',tagstr];
    end
	eval(['linem(lat,lon,znumber',otherprop,')'],...
	     'uiwait(errordlg(lasterr,''Small Circle Error'',''modal''))')

	set(0,'CurrentFigure',h.figure);

case 'bigedit'      %  Bring up a modal expanded edit box
    ExpandedEdit(titlestr)

case 'rangeunits'   %  Callback for the range units button
    h = get(get(0,'CurrentFigure'),'UserData');

	if ~ishandle(h.mapaxes)     %  Abort tool if axes is gone
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Circle Tool No Longer Appropriate'},...
							  'Circle Tool Error','modal'));
	    trackui('close');
		 return
	end

	hmodal = RangeUnitsBox(h);    %  Display the modal dialog box
	scirclui('rangepopup')         %  Process/initialize the popup menu
	uiwait(hmodal.figure)         %  Wait until closed

   if ~ishandle(hmodal.figure);   return;   end

    btn      = get(hmodal.figure,'CurrentObject');   %  Get needed info
	indx     = get(hmodal.poprng,'Value');           %  before deleting
	units    = get(hmodal.poprng,'String');          %  dialog
	geoidstr = get(hmodal.geoidedit,'String');

	delete(hmodal.figure)

	if btn == hmodal.apply    %  Apply button pushed.  Update units definition
	    h.unitstring = deblank(units(indx,:));    h.geoidstr = geoidstr;
		set(h.figure,'UserData',h)
        scirclui('rangestring')       %  Update units string display
	end

case 'rangepopup'     %  Range popup callback
    h = get(get(0,'CurrentFigure'),'UserData');   %  These are the modal handles

    if get(h.poprng,'Value') == 4
		set(h.geoidlabel,'UserData',get(h.geoidedit,'String'),...
		    'String','Normalizing Geoid')
        set(h.geoidedit,'Style','text',...
		                'String',get(h.geoidedit,'UserData'))
    else
		set(h.geoidlabel, 'String','Normalizing Geoid (km)')
	    set(h.geoidedit,'Style','edit',...
		                'String',get(h.geoidlabel,'UserData'))
	end

case 'geoidedit'       %  Callback for normalizing geoid edit.
                       %  Simply save current entry for later restoration
     h = get(get(0,'CurrentFigure'),'UserData');    %  Modal handles
     set(h.geoidlabel,'UserData', get(h.geoidedit,'String'))

case 'rangeapply'      %  Range units apply button callback
    h = get(get(0,'CurrentFigure'),'UserData');    %  Modal handles
	str = get(h.geoidedit,'String');               %  Normalizing entry


%  Reset the last error function and then try to evaluate the
%  normalizing entry

	lasterr('')

	if ~isempty(str);    eval(['r=',str,';'],'')
	    else;            r = [];
	end

    if ~isempty(lasterr)     %  Incorrect string entry
         uiwait(errordlg(lasterr,'Normalizing Geoid','modal'))
    elseif isempty(r)    %  Empty string entry
         uiwait(errordlg('Invalid geoid expression','Normalizing Geoid','modal'))
    else                 %  Correct string entry
		 uiresume        %  Returns to the uiwait in 'rangeunits'
	end

case 'close'     %  Close Request Function;  Return to call fig if it exists
    h = get(get(0,'CurrentFigure'),'UserData');
	delete(h.figure)
    if ishandle(h.mapaxes);   figure(get(h.mapaxes,'Parent'));   end

end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function scircluiBox(axeshandle)

%  SCIRCLUIBOX will construct the scirclui gui.


h.mapaxes = axeshandle;              %  Save associated map axes handle
h.unitstring = 'Kilometers';         %  Initialize range units string
h.geoidstr = 'almanac(''earth'',''radius'')';    %  and normalizing geoid definition

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

h.figure =  figure('Units','Points',  'Position',PixelFactor*[40 80 280 350], ...
	'NumberTitle','off', 'Name','Define Small Circles', ...
	'CloseRequestFcn','scirclui(''close'')', ...
	'Resize','off',  'Visible','off');
colordef(h.figure,'white');
figclr = get(h.figure,'Color');
frameclr = brighten(figclr,0.5);

% shift window if it comes up partly offscreen

shiftwin(h.figure)

%  Mode and style frame

h.modeframe = uicontrol(h.figure, 'Style','frame', ...
	'Units','Points',  'Position',PixelFactor*[10 270 260 70], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

%  Style title and radio buttons

h.styletext = uicontrol(h.figure, 'Style','text', 'String', 'Style:', ...
	'Units','Points',  'Position',PixelFactor*[15 315 45 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.gc = uicontrol(h.figure, 'Style','radio', 'String', 'Great Circle', ...
	'Units','Points',  'Position',PixelFactor*[70 318 90 15], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value', 1, ...
	'FontSize',FontScaling*10,  'FontWeight', 'bold', 'HorizontalAlignment','left', ...
	'CallBack','set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

h.rh = uicontrol(h.figure, 'Style','radio', 'String', 'Rhumb Line', ...
	'Units','Points',  'Position',PixelFactor*[170 318 90 15], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value', 0, ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'CallBack','set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0)');

set(h.gc,'UserData',h.rh)     %  Set userdata for callback operation
set(h.rh,'UserData',h.gc)

%  Mode title and radio buttons

h.modetext = uicontrol(h.figure, 'Style','text', 'String', 'Mode:', ...
	'Units','Points',  'Position',PixelFactor*[15 295 45 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.onept = uicontrol(h.figure, 'Style','radio', 'String', '1 Point', ...
	'Units','Points',  'Position',PixelFactor*[70 298 90 15], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'Value', 0, 'CallBack','scirclui(''onepoint'')');

h.twopt = uicontrol(h.figure, 'Style','radio', 'String', '2 Point', ...
	'Units','Points',  'Position',PixelFactor*[170 298 90 15], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'Value', 1, 'CallBack','scirclui(''twopoint'')');

%  Angle Units label and text

h.anglabel = uicontrol(h.figure, 'Style','text', ...
    'String', 'All Angles are in Degrees', ...
	'Units','Points',  'Position',PixelFactor*[15 275 253 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Starting point frame and title

h.stframe = uicontrol(h.figure, 'Style','frame', ...
	'Units','Points',  'Position',PixelFactor*[10 205 260 60], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.sttitle = uicontrol(h.figure, 'Style','text', 'String', 'Center Point:', ...
	'Units','Points',  'Position',PixelFactor*[15 240 100 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Starting latitude text and edit box

h.stlatlabel = uicontrol(h.figure, 'Style','push', 'String', 'Lat', ...
	'Units','Points',  'Position',PixelFactor*[15 215 30 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'Interruptible','on',...
	'CallBack','scirclui(''bigedit'',''Center Latitude'')');

h.stlatedit = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[50 215 85 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max', 2, ...
	'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Starting longitude text and edit box

h.stlonlabel = uicontrol(h.figure, 'Style','push', 'String', 'Lon', ...
	'Units','Points',  'Position',PixelFactor*[145 215 30 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'Interruptible','on',...
	'CallBack','scirclui(''bigedit'',''Center Longitude'')');

h.stlonedit = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[180 215 85 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max', 2, ...
	'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Starting point select button

h.stselect = uicontrol(h.figure, 'Style','push', 'String', 'Mouse Select', ...
	'Units','Points',  'Position',PixelFactor*[165 240 100 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'UserData',[h.stlatedit h.stlonedit],  'Callback', 'scirclui(''select'')');

%  Ending point frame and title

h.endframe = uicontrol(h.figure, 'Style','frame', ...
	'Units','Points',  'Position',PixelFactor*[10 140 260 60], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.endORdirtitle = uicontrol(h.figure, 'Style','text', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[15 175 100 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Ending latitude text and edit box

h.latORrnglabel = uicontrol(h.figure, 'Style','push', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[15 150 30 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'Interruptible','on');

h.latORrng = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[50 150 85 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max', 2, ...
	'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Ending longitude text and edit box

h.lonORazlabel = uicontrol(h.figure, 'Style','push', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[145 150 30 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'Interruptible','on');

h.lonORaz = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[180 150 85 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max', 2, ...
	'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Ending point select button

h.endselect = uicontrol(h.figure, 'Style','push', 'String', 'Mouse Select', ...
	'Units','Points',  'Position',PixelFactor*[165 175 100 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'UserData',[h.latORrng h.lonORaz],  'Callback', 'scirclui(''select'')');

%  Other properties frame

h.endframe = uicontrol(h.figure, 'Style','frame', ...
	'Units','Points',  'Position',PixelFactor*[10 45 260 90], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

%  Altitude label and edit

h.altlabel = uicontrol(h.figure, 'Style','text', 'String', 'Z Plane:', ...
	'Units','Points',  'Position',PixelFactor*[15 110 60 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.altedit = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[80 110 100 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max',1, ...
	'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Other Property label and edit

h.proplabel = uicontrol(h.figure, 'Style','text', 'String', 'Other Properties:', ...
	'Units','Points',  'Position',PixelFactor*[15 85 125 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.propedit = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[15 50 250 33], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max',2, ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Apply, help and cancel buttons

h.cancel = uicontrol(h.figure, 'Style','push', 'String', 'Close', ...
	'Units','Points',  'Position',PixelFactor*[23 8 65 30], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'Callback', 'close');

h.help = uicontrol(h.figure, 'Style','push', 'String', 'Help', ...
	'Units','Points',  'Position',PixelFactor*[108 8 65 30], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'Callback', 'maphlp2(''initialize'',''scirclui'')');

h.apply = uicontrol(h.figure, 'Style','push', 'String', 'Apply', ...
	'Units','Points',  'Position',PixelFactor*[193 8 65 30], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'Callback', 'scirclui(''apply'')');

%  Save handle links for Expanded Edit calls

set(h.stlatlabel,'UserData',h.stlatedit)
set(h.stlonlabel,'UserData',h.stlonedit)
set(h.latORrnglabel,'UserData',h.latORrng)
set(h.lonORazlabel,'UserData',h.lonORaz)

%  Work around a bug on the the PC, geck 37070 

if strcmp(computer,'PCWIN'); 
	set(h.figure,'MenuBar','None')
end

%  Save object handles and turn figure on

set(h.figure,'Visible','on','UserData',h)


%*************************************************************************
%*************************************************************************
%*************************************************************************


function ExpandedEdit(titlestr)

%  EXPANDEDEDIT will activate a modal dialog box to allow edits of
%  large entries in the edit boxes.  The button activating this
%  function must store the associated edit box handle in its
%  UserData slot.


hndl = get(get(0,'CurrentFigure'),'CurrentObject');
edithndl = get(hndl,'UserData');

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

h.figure = dialog('Name','Expanded Edit Field', ...
                  'Units','Points',  'Position',PixelFactor*72*[2 1 3.5 2], 'Visible','off');
colordef(h.figure,'white');
figclr = get(h.figure,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.figure)

%  Display title string and edit box

h.text = uicontrol(h.figure, 'Style','text', 'String',titlestr,...
            'Units','normalized', 'Position',[.05 .85 .90 .10], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', ...
	        'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.edit = uicontrol(h.figure, 'Style','edit', 'String', get(edithndl,'String'), ...
	        'Units','normalized', 'Position',[0.05 0.20 0.90 0.60], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', 'Max',2, ...
	        'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.apply = uicontrol(h.figure, 'Style','push', 'String', 'OK', ...
	'Units','normalized', 'Position',[0.35 0.03 0.30 0.14], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'Callback', 'uiresume');

set(h.figure,'Visible','on')

uiwait(h.figure)

if ~ishandle(h.figure);   return;   end

set(edithndl,'String',get(h.edit,'String'))   %  Update associated edit box
delete(h.figure)


%*************************************************************************
%*************************************************************************
%*************************************************************************


function h = RangeUnitsBox(callhndls)

%  RANGEUNITSBOX will construct the modal dialog allowing the
%  definition of range units and corresponding normalizing geoid.


units = strvcat('Kilometers','Miles','Nautical Miles','Radians');
indx = strmatch(callhndls.unitstring,units);  %  Current units

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

h.figure = dialog('Name','Define Radius Units', ...
                  'Units','Points',  'Position',PixelFactor*72*[0.10 0.5 5.3 1.5], 'Visible','off');
colordef(h.figure,'white');
figclr = get(h.figure,'Color');


% shift window if it comes up partly offscreen

shiftwin(h.figure)

%  Range unit label and popup box

h.poplabel = uicontrol(h.figure, 'Style','text', 'String','Radius Units',...
            'Units','normalized', 'Position',[.05 .73 .40 .20], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', ...
	        'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.poprng = uicontrol(h.figure, 'Style','popup', 'String',units,...
            'Units','normalized', 'Position',[.48 .75 .47 .20], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', ...
			'HorizontalAlignment','left', 'Value',indx,...
	        'FontSize',FontScaling*10,  'FontWeight','bold', ...
			'Callback','scirclui(''rangepopup'')');

%  Normalizing geoid label and edit box

h.geoidlabel = uicontrol(h.figure, 'Style','text', 'String','',...
            'Units','normalized', 'Position',[.05 .45 .40 .20], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', ...
	        'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.geoidedit = uicontrol(h.figure, 'Style','edit', 'String',callhndls.geoidstr,...
            'Units','normalized', 'Position',[.48 .45 .47 .20], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', 'Max',1,...
	        'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left',...
			'Callback', 'scirclui(''geoidedit'')');

%  Apply, help and cancel buttons

h.cancel = uicontrol(h.figure, 'Style','push', 'String', 'Cancel', ...
	'Units','normalized', 'Position',[0.07 0.05 0.24 0.30], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'Callback', 'uiresume');

h.help = uicontrol(h.figure, 'Style','push', 'String', 'Help', ...
	'Units','normalized', 'Position',[0.38 0.05 0.24 0.30], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold',...
	'Callback', 'maphlp2(''initialize'',''rangeunits'')');%RadiusUnits

h.apply = uicontrol(h.figure, 'Style','push', 'String', 'Apply', ...
	'Units','normalized', 'Position',[0.69 0.05 0.24 0.30], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold',...
	'Callback', 'scirclui(''rangeapply'')');

%  Set data needed for callback processing

mapstruct = get(callhndls.mapaxes,'UserData');
displaygeoid = ['[',num2str(mapstruct.geoid(1),'%8.3f'),'  ', ...
                    num2str(mapstruct.geoid(2),'%8.5f'),']'];

set(h.geoidedit,'UserData',displaygeoid)
set(h.geoidlabel,'UserData',get(h.geoidedit,'String'))

%  Turn dialog on and save object handles

set(h.figure,'Visible','on','UserData',h)

