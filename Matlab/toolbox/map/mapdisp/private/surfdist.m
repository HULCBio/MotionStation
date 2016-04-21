function surfdist(action,titlestr)

%  SURFDIST  Interactive tool for distance, azimuth and reckoning calculations
%
%  SURFDIST activates the interactive tool.  If the current axes have a
%  proper map definition, then the tool will be associated with the axes.
%  Otherwise, the tool will not be associated with any axes.
%
%  SURFDIST(hndl)  activates the interactive tool and associates it
%  with the axes specified by hndl. The axes specified by hndl
%  must be a map axes.
%
%  SURFDIST([]) activates the tool and does not associate it with any
%  axes, regardless of whether the current axes has a valid map definition.
%
%  SURFDIST is obsolete. TRACKG interactive tracks also compute distance.
%
%  See also SCIRCLUI, TRACKUI

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:55:24 $
%  Written by:  E. Byrns, E. Brown


%  Parse the inputs

if nargin == 0
    if ~isempty(get(0,'CurrentFigure')) & ...
	   ~isempty(get(get(0,'CurrentFigure'),'CurrentAxes')) & ...
	    ismap(get(get(0,'CurrentFigure'),'CurrentAxes'))
          hndl = gca;     action = 'initialize';
	else
		hndl = [];        action = 'initialize';
    end

elseif ~isstr(action)
    hndl = action;    action = 'initialize';
end


%  Switch yard

switch action
case 'initialize'       %  Activate the tool

    if ~isempty(hndl)
	    [mstruct,msg] = gcm(hndl);     %  Axes handle test performed here too.
        if ~isempty(msg);    error(msg);   end
    end

    surfdistBox(hndl)               %  Construct the gui
    surfdist('twopoint')            %  Initialize for two point operation
    surfdist('rangestring')         %  Update the unit string
	set(gcf,'HandleVisibility','Callback')

case 'circlestyle'         %  Callback for the style radio buttons
    h = get(get(0,'CurrentFigure'),'UserData');

    if get(h.twopt,'Value')
        if isempty(get(h.stlatedit,'String')) & ...
		   isempty(get(h.stlonedit,'String')) & ...
		   isempty(get(h.endlatedit,'String')) & ...
		   isempty(get(h.endlonedit,'String'))
		       return
		else
	          surfdist('twopointcalc')
		end
	else
        if isempty(get(h.stlatedit,'String')) & ...
		   isempty(get(h.stlonedit,'String')) & ...
		   isempty(get(h.azedit,'String')) & ...
		   isempty(get(h.rngedit,'String'))
		       return
		else
	          surfdist('onepointcalc')
		end
	end

case 'onepoint'         %  Callback for the one point mode radio button
    h = get(get(0,'CurrentFigure'),'UserData');

%  Make mode radio buttons mutually exclusive

    set(h.onept,'Value',1);    set(h.twopt,'Value',0)

%  Set the strings and callbacks to correspond to one point mode

	set([h.endlatedit; h.endlonedit],'Style','text')
	set([h.azedit; h.rngedit],'Style','edit')
    set(h.endselect,'Enable','off')
	set(h.apply,'Callback','surfdist(''onepointcalc'')')

case 'twopoint'         %  Callback for the two point mode radio button
    h = get(get(0,'CurrentFigure'),'UserData');

%  Make mode radio buttons mutually exclusive

    set(h.onept,'Value',0);    set(h.twopt,'Value',1)

%  Set the strings and callbacks to correspond to two point mode

	set([h.endlatedit; h.endlonedit],'Style','edit')
	set([h.azedit; h.rngedit],'Style','text')
    if ~isempty(h.mapaxes);  set(h.endselect,'Enable','on');  end
	set(h.apply,'Callback','surfdist(''twopointcalc'')')

case 'rangestring'       %  Update the range string display
    h = get(get(0,'CurrentFigure'),'UserData');

    switch h.unitstring
	case 'Kilometers'
	    set(h.anglabel,'String','Angles in degrees;  Range in kilometers')
	case 'Miles'
	    set(h.anglabel,'String','Angles in degrees;  Range in miles')
	case 'Nautical Miles'
	    set(h.anglabel,'String','Angles in degrees;  Range in nautical miles')
	case 'Radians'
	    set(h.anglabel,'String','Angles in degrees;  Range in radians')
    otherwise
	    error('Unrecognized range unit string')
    end

case 'select'           %  Callback associated with the Mouse Select button
    h = get(get(0,'CurrentFigure'),'UserData');
	if ~ishandle(h.mapaxes)     %  Abort tool if axes is gone
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Distance Tool No Longer Appropriate'},...
							  'Distance Tool Error','modal'));
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
	set([h.rngedit;h.azedit],'String','')
	figure(h.figure)

case 'twopointcalc'        %  Compute distance and azimuth
	commastr  = ',';                        %  Useful string needed later
	h = get(get(0,'CurrentFigure'),'UserData');

	if get(h.gc,'Value');    trackstr = '''gc''';   %  Define measurement type
	   else;                 trackstr = '''rh''';
	end

%  Get the edit box entries.  If the entries are required, abort if empty

    startlat = get(h.stlatedit,'String');
	startlon = get(h.stlonedit,'String');
	if isempty(startlat) | isempty(startlon)
	     uiwait(errordlg('Starting Latitude and Longitude Required',...
		                  'Surface Distance Error','modal'));  return
	end

    endlat = get(h.endlatedit,'String');
	endlon = get(h.endlonedit,'String');
	if isempty(endlat) | isempty(endlon)
	     uiwait(errordlg('Ending Latitude and Longitude Required',...
		                  'Surface Distance Error','modal'));  return
    end

%  Make a potentially multi-line strings into a single row vector.
%  Eliminate any padding 0s since they mess up a string

    startlat = startlat';   startlat = startlat(:)';
    startlat = startlat(find(startlat));

    startlon = startlon';   startlon = startlon(:)';
    startlon = startlon(find(startlon));

    endlat = endlat';   endlat = endlat(:)';
    endlat = endlat(find(endlat));

    endlon = endlon';   endlon = endlon(:)';
    endlon = endlon(find(endlon));

%  Reset the last error function and evaluate the function calls

    lasterr('')

    evalstr = ['rng = distance(',trackstr,commastr,startlat,commastr,...
	            startlon,commastr,endlat,commastr,endlon,commastr,...
			   '[',num2str(h.basegeoid),']',commastr,'''degrees'');'];
	eval(evalstr, 'uiwait(errordlg(lasterr,''Surface Distance Error'',''modal''))');
	if ~isempty(lasterr);  return;   end

    evalstr = ['az = azimuth(',trackstr,commastr,startlat,commastr,...
	            startlon,commastr,endlat,commastr,endlon,commastr,...
			   '[',num2str(h.basegeoid),']',commastr,'''degrees'');'];
	eval(evalstr, 'uiwait(errordlg(lasterr,''Surface Distance Error'',''modal''))');
	if ~isempty(lasterr);  return;   end

%  Determine the geoid/radius to use as the normalizing radius for
%  the range entries.

    if strcmp(h.unitstring,'Radians');            normalize = 1;
        else;              eval(['normalize = ',h.geoidstr,';'])
    end

%  Compute the range in the proper units

    if get(h.gc,'Value')
        if ~strcmp(h.unitstring,'Radians')
            diststr = h.unitstring;   diststr(find(diststr==' ')) = [];
		    normalize = distdim(normalize(1),'kilometers',diststr);
	    end
        rng = rng*normalize/h.basegeoid(1);
    else
        radius = rsphere('rectifying',h.basegeoid);
	    normalize = rsphere('rectifying',normalize);
        if ~strcmp(h.unitstring,'Radians')
            diststr = h.unitstring;   diststr(find(diststr==' ')) = [];
		    normalize = distdim(normalize(1),'kilometers',diststr);
	    end

	    rng = rng*normalize/radius;
    end

    set(h.rngedit,'String',num2str(rng,'%6.1f'))
    set(h.azedit,'String',num2str(az,'%6.1f'))

%  Display the track if requested.

    if isfield(h,'trackline')
        if ishandle(h.trackline);  delete(h.trackline);  end
    end
    
    if ismap(h.mapaxes) & get(h.showtrack,'Value')
	   trackstr([1 length(trackstr)]) = [];
	   [lat,lon] = track2(trackstr,eval(startlat),eval(startlon),...
	                eval(endlat),eval(endlon),h.basegeoid,'degrees',40);
	   set(0,'CurrentFigure',get(h.mapaxes,'Parent'))
	   set(get(h.mapaxes,'Parent'),'CurrentAxes',h.mapaxes)
	   h.trackline = linem(lat,lon,max(get(h.mapaxes,'Zlim')),...
	                       'r','EraseMode','background');
	   set(0,'CurrentFigure',h.figure)
	   set(h.figure,'UserData',h)
	end

case 'onepointcalc'        %  Compute reckoning measurements
	commastr  = ',';                        %  Useful string needed later
	h = get(get(0,'CurrentFigure'),'UserData');

	if get(h.gc,'Value');    trackstr = '''gc''';   %  Define measurement type
	   else;                 trackstr = '''rh''';
	end

%  Get the edit box entries.  If the entries are required, abort if empty

    startlat = get(h.stlatedit,'String');
	startlon = get(h.stlonedit,'String');
	if isempty(startlat) | isempty(startlon)
	     uiwait(errordlg('Starting Latitude and Longitude Required',...
		                  'Surface Distance Error','modal'));  return
	end

    az = get(h.azedit,'String');
	rng = get(h.rngedit,'String');
	if isempty(az) | isempty(rng)
	     uiwait(errordlg('Azimuth and Range Required',...
		                  'Surface Distance Error','modal'));  return
    end

%  Make a potentially multi-line strings into a single row vector.
%  Eliminate any padding 0s since they mess up a string

    startlat = startlat';   startlat = startlat(:)';
    startlat = startlat(find(startlat));

    startlon = startlon';   startlon = startlon(:)';
    startlon = startlon(find(startlon));

    az = az';     az = az(:)';    az = az(find(az));
    rng = rng';   rng = rng(:)';  rng = rng(find(rng));

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
	    radfact = ['*',num2str(h.basegeoid(1)/normalize(1),'%16.12f')];
	else
        radius = rsphere('rectifying',h.basegeoid);
		normalize = rsphere('rectifying',normalize);
		radfact = ['*',num2str(radius/normalize,'%16.12f')];
	end

%  Construct the range string.  Account for unit changes if necessary.

    diststr = h.unitstring;   diststr(find(diststr==' ')) = [];
    if strcmp(h.unitstring,'Radians')
	    diststr = rng;
	else
        diststr = ['distdim(',rng,',''',diststr,''',''kilometers'')'];
	end

%  Reset the last error function and evaluate the function calls

    lasterr('')

    evalstr = ['[endlat,endlon]=reckon(',trackstr,commastr,startlat,commastr,...
		       startlon,commastr,diststr,radfact,commastr,az,commastr,...
			  '[',num2str(h.basegeoid),'],''degrees'');'];
	eval(evalstr, 'uiwait(errordlg(lasterr,''Surface Distance Error'',''modal''))');
	if ~isempty(lasterr);  return;   end

    set(h.endlatedit,'String',num2str(endlat,'%6.1f'))
    set(h.endlonedit,'String',num2str(endlon,'%6.1f'))

%  Display the track if requested.

    if isfield(h,'trackline')
        if ishandle(h.trackline);  delete(h.trackline);  end
    end
    if ismap(h.mapaxes) & get(h.showtrack,'Value')
       evalstr = ['[lat,lon]=track1(',trackstr,commastr,startlat,...
		  commastr,startlon,commastr,az,commastr,diststr,radfact,commastr,...
		  '[',num2str(h.basegeoid),'],''degrees'');'];
       eval(evalstr,'')
	   set(0,'CurrentFigure',get(h.mapaxes,'Parent'))
	   set(get(h.mapaxes,'Parent'),'CurrentAxes',h.mapaxes)
	   h.trackline = linem(lat,lon,max(get(h.mapaxes,'Zlim')),...
	                       'r','EraseMode','background');
	   set(0,'CurrentFigure',h.figure)
	   set(h.figure,'UserData',h)
	end

case 'rangeunits'   %  Callback for the range units button
    h = get(get(0,'CurrentFigure'),'UserData');

	hmodal = RangeUnitsBox(h);    %  Display the modal dialog box
	surfdist('rangepopup')        %  Process/initialize the popup menu
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
        surfdist('rangestring')       %  Update units string display
        if get(h.twopt,'Value');  surfdist('twopointcalc');  end
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
    if ishandle(h.mapaxes)
	     figure(get(h.mapaxes,'Parent'))
         if isfield(h,'trackline')
             if ishandle(h.trackline)
			       fighndl = get(get(h.trackline,'Parent'),'Parent');
				   delete(h.trackline);  refresh(fighndl)
		     end
         end    
    end

end


%*************************************************************************
%*************************************************************************
%*************************************************************************


function surfdistBox(axeshandle)

%  SURFDISTBOX will construct the surfdist gui.


h.mapaxes = axeshandle;              %  Save associated map axes handle
h.unitstring = 'Kilometers';         %  Initialize range units string
h.geoidstr = 'almanac(''earth'',''radius'')';    %  and normalizing geoid definition

%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

h.figure =  figure('Units','Points',  'Position',PixelFactor*[40 80 280 350], ...
	'NumberTitle','off', 'Name','Surface Distance', ...
	'CloseRequestFcn','surfdist(''close'')', ...
	'Resize','off',  'Visible','off');
colordef(h.figure,'white');
figclr = get(h.figure,'Color');
frameclr = brighten(figclr,0.5);

% shift window if it comes up partly offscreen

shiftwin(h.figure)

%  Mode and style frame

h.modeframe = uicontrol(h.figure, 'Style','frame', ...
	'Units','Points',  'Position',PixelFactor*[10 250 260 90], ...
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
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0);surfdist(''circlestyle'')');

h.rh = uicontrol(h.figure, 'Style','radio', 'String', 'Rhumb Line', ...
	'Units','Points',  'Position',PixelFactor*[170 318 90 15], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Value', 0, ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'CallBack',...
	'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0);surfdist(''circlestyle'')');

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
	'Value', 0, 'CallBack','surfdist(''onepoint'')');

h.twopt = uicontrol(h.figure, 'Style','radio', 'String', '2 Point', ...
	'Units','Points',  'Position',PixelFactor*[170 298 90 15], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left', ...
	'Value', 1, 'CallBack','surfdist(''twopoint'')');

%  Show Track check box

h.showtrack = uicontrol(h.figure, 'Style','check', 'String', 'Show Track', ...
	'Units','Points',  'Position',PixelFactor*[15 276 100 18], 'Value',0, ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Angle Units label and text

h.anglabel = uicontrol(h.figure, 'Style','text', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[15 255 253 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Starting point frame and title

h.stframe = uicontrol(h.figure, 'Style','frame', ...
	'Units','Points',  'Position',PixelFactor*[10 185 260 60], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.sttitle = uicontrol(h.figure, 'Style','text', 'String', 'Starting Point:', ...
	'Units','Points',  'Position',PixelFactor*[15 220 100 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Starting latitude text and edit box

h.stlatlabel = uicontrol(h.figure, 'Style','text', 'String', 'Lat:', ...
	'Units','Points',  'Position',PixelFactor*[15 195 30 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.stlatedit = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[50 195 85 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max', 1, ...
	'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Starting longitude text and edit box

h.stlonlabel = uicontrol(h.figure, 'Style','text', 'String', 'Lon:', ...
	'Units','Points',  'Position',PixelFactor*[145 195 30 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.stlonedit = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[180 195 85 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max', 1, ...
	'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Starting point select button

h.stselect = uicontrol(h.figure, 'Style','push', 'String', 'Mouse Select', ...
	'Units','Points',  'Position',PixelFactor*[165 220 100 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'UserData',[h.stlatedit h.stlonedit], 'Callback', 'surfdist(''select'')');

%  Ending point frame and title

h.endframe = uicontrol(h.figure, 'Style','frame', ...
	'Units','Points',  'Position',PixelFactor*[10 120 260 60], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.endtitle = uicontrol(h.figure, 'Style','text', 'String', 'Ending Point:', ...
	'Units','Points',  'Position',PixelFactor*[15 155 100 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Ending latitude text and edit box

h.endlatlabel = uicontrol(h.figure, 'Style','text', 'String', 'Lat:', ...
	'Units','Points',  'Position',PixelFactor*[15 130 30 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.endlatedit = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[50 130 85 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max', 1, ...
	'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Ending longitude text and edit box

h.endlonlabel = uicontrol(h.figure, 'Style','text', 'String', 'Lon:', ...
	'Units','Points',  'Position',PixelFactor*[145 130 30 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.endlonedit = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[180 130 85 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max', 1, ...
	'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Ending point select button

h.endselect = uicontrol(h.figure, 'Style','push', 'String', 'Mouse Select', ...
	'Units','Points',  'Position',PixelFactor*[165 155 100 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'UserData',[h.endlatedit h.endlonedit],  'Callback', 'surfdist(''select'')');

%  Direction frame and title

h.dirframe = uicontrol(h.figure, 'Style','frame', ...
	'Units','Points',  'Position',PixelFactor*[10 55 260 60], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

h.dirtitle = uicontrol(h.figure, 'Style','text', 'String', 'Direction:', ...
	'Units','Points',  'Position',PixelFactor*[15 90 100 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Azimuth text and edit box

h.azlabel = uicontrol(h.figure, 'Style','text', 'String', 'Az:', ...
	'Units','Points',  'Position',PixelFactor*[15 65 30 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.azedit = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[50 65 85 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max', 1, ...
	'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Range text and edit box

h.rnglabel = uicontrol(h.figure, 'Style','text', 'String', 'Rng:', ...
	'Units','Points',  'Position',PixelFactor*[145 65 30 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.rngedit = uicontrol(h.figure, 'Style','edit', 'String', '', ...
	'Units','Points',  'Position',PixelFactor*[180 65 85 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', 'Max', 1, ...
	'FontSize',FontScaling*9,  'FontWeight','bold', 'HorizontalAlignment','left');

%  Range units select button

h.rngselect = uicontrol(h.figure, 'Style','push', 'String', 'Range Units', ...
	'Units','Points',  'Position',PixelFactor*[165 90 100 18], ...
	'BackgroundColor',frameclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
 	'UserData',[h.azedit h.rngedit],  'Callback', 'surfdist(''rangeunits'')');

%  Apply, help and cancel buttons

h.cancel = uicontrol(h.figure, 'Style','push', 'String', 'Close', ...
	'Units','Points',  'Position',PixelFactor*[23 15 65 30], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'Callback', 'close');

h.help = uicontrol(h.figure, 'Style','push', 'String', 'Help', ...
	'Units','Points',  'Position',PixelFactor*[108 15 65 30], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'Callback', 'maphlp2(''initialize'',''surfdist'')');

h.apply = uicontrol(h.figure, 'Style','push', 'String', 'Compute', ...
	'Units','Points',  'Position',PixelFactor*[193 15 65 30], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold', ...
	'Callback', 'surfdist(''apply'')');

%  Enable mouse select buttons if tool is linked to a map

if isempty(h.mapaxes);    set([h.stselect;h.endselect;h.showtrack],'Enable','off')
                          h.basegeoid = [1 0];
    else;                 set([h.stselect;h.endselect;h.showtrack],'Enable','on')
	                      mstruct = gcm(h.mapaxes);
						  h.basegeoid = mstruct.geoid;
						  h.trackline = [];
end

%  Work around a bug on the the PC, geck 37070 

if strcmp(computer,'PCWIN'); 
	set(h.figure,'MenuBar','None')
end

%  Save object handles and turn figure on

set(h.figure,'Visible','on','UserData',h)


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

h.figure = dialog('Name','Define Range Units', ...
                  'Units','Points',  'Position',PixelFactor*72*[0.10 0.5 5.3 1.5], 'Visible','off');
colordef(h.figure,'white');
figclr = get(h.figure,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.figure)


%  Range unit label and popup box

h.poplabel = uicontrol(h.figure, 'Style','text', 'String','Range Units',...
            'Units','normalized', 'Position',[.05 .73 .40 .20], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', ...
	        'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.poprng = uicontrol(h.figure, 'Style','popup', 'String',units,...
            'Units','normalized', 'Position',[.48 .75 .47 .20], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', ...
			'HorizontalAlignment','left', 'Value',indx,...
	        'FontSize',FontScaling*10,  'FontWeight','bold', ...
			'Callback','surfdist(''rangepopup'')');

%  Normalizing geoid label and edit box

h.geoidlabel = uicontrol(h.figure, 'Style','text', 'String','',...
            'Units','normalized', 'Position',[.05 .45 .40 .20], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', ...
	        'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left');

h.geoidedit = uicontrol(h.figure, 'Style','edit', 'String',callhndls.geoidstr,...
            'Units','normalized', 'Position',[.48 .45 .47 .20], ...
	        'BackgroundColor',figclr, 'ForegroundColor','black', 'Max',1,...
	        'FontSize',FontScaling*10,  'FontWeight','bold', 'HorizontalAlignment','left',...
			'Callback', 'surfdist(''geoidedit'')');

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
	'Callback', 'maphlp2(''initialize'',''rangeunits'')');

h.apply = uicontrol(h.figure, 'Style','push', 'String', 'Apply', ...
	'Units','normalized', 'Position',[0.69 0.05 0.24 0.30], ...
	'BackgroundColor',figclr, 'ForegroundColor','black', ...
	'FontSize',FontScaling*10,  'FontWeight','bold',...
	'Callback', 'surfdist(''rangeapply'')');

%  Set data needed for callback processing

displaygeoid = ['[',num2str(callhndls.basegeoid(1),'%8.3f'),'  ', ...
                    num2str(callhndls.basegeoid(2),'%8.5f'),']'];

set(h.geoidedit,'UserData',displaygeoid)
set(h.geoidlabel,'UserData',get(h.geoidedit,'String'))

%  Turn dialog on and save object handles

set(h.figure,'Visible','on','UserData',h)

