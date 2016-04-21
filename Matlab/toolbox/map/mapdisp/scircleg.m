function [out1,out2] = scircleg(varargin)

%SCIRCLEG:  Display of interactive small circles defined via 
%           mouse clicks.
%
%  SCIRCLEG(n) will compute and display n small circles on the
%  current map axes.  The small circles are defined by
%  a mouse click on the center of the circle and then by
%  a mouse click on the circle, thereby defining its radius.
%  Extend (shift) clicking on a circle displays two control 
%  points (center point and radial point) and the associated 
%  control window.  To translate the circle, click and drag the 
%  center (x) control.  To resize the circle, click and drag the 
%  radial (o) control.  The control buttons can be hidden by extend 
%  clicking on the circle again.  The control window allows modification 
%  of certain parameters of the small circle.  The center point 
%  (latitude and longitude), radius, and number of points (npts) 
%  can be changed using the appropriate edit boxes.  The distance 
%  units (kilometers, miles, nautical miles, radians) and track 
%  (great circle or rhumb line) can be modified using the appropriate 
%  pop-up menus.  
%
%  SCIRCLEG(n,npts) uses the inputs npts to define the number
%  of points per circle computed for each small circle.
%
%  SCIRCLEG(n,'LineSpec') and SCIRCLEG(n,npts,'LineSpec') uses
%  any valid LineSpec string to display the small circles.
%
%  SCIRCLEG(n,'PropertyName',PropertyValue,...) and
%  SCIRCLEG(n,npts,'PropertyName',PropertyValue,...) uses the
%  specified line properties to display the small circles.
%
%  SCIRCLEG('track',...) uses the track string to define
%  the distance calculation for the circle radius.  If
%  'track' = 'gc', then great circle distance is used as
%  the circle radius.  If 'track' = 'rh', then rhumb line
%  distance is used as the circle radius.  If omitted,
%  'track' = 'gc' is assumed.
%
%  h = SCIRCLEG(...) returns the handles of the circles drawn.
%
%  [lat,lon] = SCIRCLEG(...) returns the latitude and longitude
%  matrices corresponding to the circles drawn.
%
%  See also SCIRCLE1, SCIRCLE2, TRACKG

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.14.4.1 $ $Date: 2003/08/01 18:22:38 $
%  Written by:  E. Byrns, E. Brown, Interactive Controls by: L. Job

str   = [];     ncirc = [];      s.npts  = [];

if nargin == 1 & isstr(varargin{1})
   
   % GUI callbacks
   scirclui2(varargin{:});
   return
   
elseif nargin ~= 0 & isstr(varargin{1})
   str = varargin{1};     varargin(1) = [];

   if length(varargin) == 1 & ~isstr(varargin{1})
          ncirc = varargin{1};    varargin(1) = [];   s.npts  = [];
   elseif length(varargin) == 1 & isstr(varargin{1})
          ncirc = [];      s.npts  = [];
   elseif length(varargin) >= 2 & isstr(varargin{2})
          ncirc = varargin{1};   varargin(1) = [];
   elseif length(varargin) >= 2 & ~isstr(varargin{2})
          ncirc = varargin{1};   s.npts = varargin{2};   varargin(1:2) = [];
   end

elseif nargin ~= 0 & ~isstr(varargin{1})
   str = [];
   ncirc = varargin{1};    varargin(1) = [];

   if length(varargin) >= 1 & ~isstr(varargin{1})
          s.npts  = varargin{1};   varargin(1) = [];
   end
end

if ~ismap;   error('Not a map axes');  end

%  Use 100 points by default
if isempty(s.npts) | s.npts < 4; 
	s.npts = 100; 
end

%  Test for a valid number of circles

if isempty(ncirc)
    ncirc = 1;
elseif isstr(ncirc)
    error('Number of circles not specified.')
elseif max(size(ncirc)) > 1
    error('Number of small circles must be a scalar')
end

%  Test the track string

if isempty(str)
    str = 'gc';
else
    validstr = strvcat('gc','rh');
	indx     = strmatch(lower(str),validstr);
	if length(indx) ~= 1;       error('Unrecognized track string')
          else;                 str = deblank(validstr(indx,:));
    end
end

%  Set the tag string

switch str
    case 'gc'
		tagstr = 'InteractiveCircle';
		s.trk = 'gc';
	case 'rh'   
		tagstr = 'InteractiveCircle';
		s.trk = 'rh';
end

%  Pre-allocate some memory space

lat1(ncirc,1) = 0;     lon1(ncirc,1) = 0;
lat2(ncirc,1) = 0;     lon2(ncirc,1) = 0;
rad(ncirc,1) = 0;      az(ncirc,1) = 0;
num = rand(size(rad));

%  Get the circle definition.
%  Enforce that ncirc must be real (avoids messy warning message
%  with colon operator)

for i = 1:real(ncirc)
       disp(['Circle ',num2str(i),':  Click on center and perimeter'])

       [latpts,lonpts] = inputm(2);
	   if isempty(latpts);   warning('Wrong view for SCIRCLEG');  return;  end

	   lat1(i) = latpts(1);      lon1(i) = lonpts(1);
	   lat2(i) = latpts(2);      lon2(i) = lonpts(2);
	   rad(i) = distance(s.trk,lat1(i),lon1(i),lat2(i),lon2(i));
	   az(i) = azimuth(s.trk,lat1(i),lon1(i),lat2(i),lon2(i));	   
end

%  Get geoid and unit parameters

geoid = getm(gca,'Geoid');
units = getm(gca,'AngleUnits');

% Change the units and geoid if necessary

if geoid(1) ~=1 | geoid(2) ~= 0
	setm(gca,'geoid',[1 0])
	geoid = [1 0];
end
switch units
	case 'degrees'
	otherwise	
		setm(gca,'AngleUnits','deg')
end
	
%  Compute circles

[latc,lonc] = scircle2(str,lat1,lon1,lat2,lon2,geoid,units,s.npts);

%  Plot the circles

if ~isempty(varargin)
%  VARARGIN may contain a LineSpec string so it must come before
%  the property 'Tag'.  This has the drawback that any
%  user 'TAG' passed in will be overwritten by tagstr.  However,
%  this is a small price to pay for potentially complex parsing if
%  VARARGIN contains the property 'Tag'.

    hndl = plotm(latc,lonc,varargin{:},'Tag',tagstr);
else
    hndl = plotm(latc,lonc,'Tag',tagstr);
end

%  Set the correct structures
for i = 1:real(ncirc)
    s.clat = lat1(i);
    s.clon = lon1(i);
    s.rlat = lat2(i);
    s.rlon = lon2(i);
    s.rad = rad(i);
    s.az = az(i);
    s.controls = 'off';
    s.hcontrol = [];
    s.hcenter = [];
    s.hcirc = hndl(i);
    s.hend = [];
    s.parent = get(s.hcirc,'parent');	
    s.num = num(i);
	
    structm = getm(hndl(i));
    s.clipped = structm.clipped;
    s.trimmed = structm.clipped;
    
	set(hndl(i),'userdata',s,'buttondownfcn','scircleg(''circlemousedown'')');
end	

%  Set output arguments

if nargout == 1
     out1 = hndl;
elseif nargout == 2
     out1 = latc;    out2 = lonc;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function scirclui2(action)

%scirclui2  Callbacks for adding and manipulating small circles on a map
%
%  scircleg prompts the user to mouse click two points to define
%  the center and perimeter of the small circle.  Normal clicking 
%  on the track displays the circle's tag.  Alternate (option) 
%  clicking on the track executes the scribe callback. Extend (shift)
%  clicking on the circle displays two control points (center
%  point and radial) and the associated control window.  To translate
%  the circle, click and drag the center (x) control.  To resize
%  the circle, click and drag the radial (o) control.  The control
%  buttons can be hidden by extend clicking on the circle.  The
%  control window allows modification of certain parameters of the
%  small circle.  The center point (latitude and longitude),
%  radius, and number of points (npts) can be changed using 
%  the appropriate edit boxes.  The distance units (kilometers,
%  miles, nautical miles, radians) and track (great circle or
%  rhumb line) can be modified using the appropriate pop-up
%  menus.  A valid map axes must exist prior to running this function.  
%  DO NOT rename the tags of the small circle or control points 
%  since doing so will make the call-backs inoperable.
%
%  See also SCIRCLUI

% default action is initialize
switch nargin
case 0
	% error checking
	kids = get(0,'children');
	if isempty(kids);
		h = errordlg('Valid Map Axes Required','Map Error');
		set(h,'windowstyle','modal');
		return
	else
		if ~ismap(gca)	
			h = errordlg('Valid Map Axes Required','Map Error');
			set(h,'windowstyle','modal');
		end	
	end	
	action = 'initialize';
end	

% switch on action
switch action

% define center and radius via mouse clicks
case 'initialize'
	% change view
	vw = get(gca,'view');
	if any(vw ~= [0 90])
	    btn = questdlg(...
		       strvcat('Must be in 2D view for operation.','Change to 2D view?'),...
			   'Incorrect View','Change','Cancel','Change');
	    switch btn
		    case 'Change',      view(2);
			case 'Cancel',      return
	    end
	end
	'Click on center and perimeter to define circle'
	[s.clat,s.clon] = inputm(1); % center
	[s.rlat,s.rlon] = inputm(1); % perimeter
	s.trk = 'gc'; % great circle computation by default
	s.npts = 100; % number of points	
	s.rad = distance(s.trk,s.clat,s.clon,s.rlat,s.rlon); % radius
	s.az = azimuth(s.trk,s.clat,s.clon,s.rlat,s.rlon); % azimuth
	[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							 'deg',s.npts);
	% draw objects
	hcirc = plotm(crlat,crlon,'b-','linewidth',2,'tag','InteractiveCircle');
	s.controls = 'off';
	s.hcontrol = [];
	s.hcenter = [];
	s.hcirc = hcirc;
	s.hend = [];
	s.parent = get(s.hcirc,'parent');	
	s.num = rand;
	% set buttondown functions of the circle
	set(hcirc,'userdata',s,'buttondownfcn',...
		'scircleg(''circlemousedown'')');

% reconstruct the small circle if it has been deleted
case 'reconstruct'		
	s = get(gco,'userdata');
	[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							 'deg',s.npts);
	% draw objects
	s.hcirc = plotm(crlat,crlon,'b-','linewidth',2,'tag','InteractiveCircle');
	s.parent = get(s.hcirc,'parent');	
	% set buttondown functions of the circle
	set(s.hcirc,'userdata',s,'buttondownfcn',...
		'scircleg(''circlemousedown'')');
	% delete the controls
	delete(s.hcenter);
	delete(s.hend);
		
% reproject data	
case 'reproject'
	% circle
	hcirc = findobj(gca,'tag','InteractiveCircle');
	if ~isempty(hcirc)
		for i = 1:length(hcirc)
			s =  get(hcirc(i),'userdata');
			[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
									 'deg',s.npts);
			% update the track 
			[crx,cry,crz,t] = mfwdtran(crlat,crlon,zeros(size(crlat)),'line');
			s.clipped = t.clipped;
			s.trimmed = t.trimmed;
			% slip in the x and y data
			set(hcirc(i),'xdata',crx,'ydata',cry,'zdata',crz,'userdata',s);
		end
	end
	% center point
	hcenter = findobj(gca,'tag','InteractiveCircleCenter');
	if ~isempty(hcenter)
		for i = 1:length(hcenter)
			s =  get(hcenter(i),'userdata');
			% update the starting point 
			[x,y] = mfwdtran(s.clat,s.clon); z = 0;
			% slip in the x and y data
			set(hcenter(i),'xdata',x,'ydata',y,'zdata',z);
		end
	end
	% radial point
	hend = findobj(gca,'tag','InteractiveCircleEnd');
	if ~isempty(hend)
		for i = 1:length(hend)
			s =  get(hend(i),'userdata');
			% update the ending point
			[rlat,rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.az);
			[x,y] = mfwdtran(rlat,rlon); z = 0;
			% slip in the x and y data
			set(hend(i),'xdata',x,'ydata',y,'zdata',z);
		end
	end
	
% create GUI controls
case 'createcontrols'
	s = get(gco,'userdata');
	h = figure('units','char','pos',[20 5 36.4000   16.8462],...
		'numbertitle','off','name','Small Circles','tag','sccontrol',...
		'resize','off','HandleVisibility','Callback','Menubar','none');
	framecolor = [0.8944 0.8944 0.8944];	
	frame1 = uicontrol('style','frame','units','char',...
					   'pos',[1.1866   10.9113   34.0000    5.2375],...
					   'backgroundcolor',framecolor);
	frame2 = uicontrol('style','frame','units','char',...
					   'pos',[1.1866    2.0081   34.0000    8.6421],...
					   'backgroundcolor',framecolor);
	htext1 = uicontrol('style','text','string','Center Point',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',[2.4000   14.6154   18.4000    1.3087],...
					   'backgroundcolor',framecolor);
	htext2 = uicontrol('style','text','string','Size',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',[2.4000    9.1538   18.4000    1.3087],...
					   'backgroundcolor',framecolor);
	htext3 = uicontrol('style','text','string','Lat',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',[2.4000   13.0769   18.4000    1.3087],...
					   'backgroundcolor',framecolor);
	htext4 = uicontrol('style','text','string','Lon',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',[2.4000   11.3846   18.4000    1.3087],...
					   'backgroundcolor',framecolor);
	htext5 = uicontrol('style','text','string','Units',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',[2.4000    7.0769   18.4000    1.3087],...
					   'backgroundcolor',framecolor);
    htext6 = uicontrol('style','text','string','Radius',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',[2.4000    5.6154   18.4000    1.3087],...
					   'backgroundcolor',framecolor);
    htext7 = uicontrol('style','text','string','Track',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',[2.4000    4.0769   18.4000    1.3087],...
					   'backgroundcolor',framecolor);
    htext8 = uicontrol('style','text','string','Npts',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',[2.4000    2.5385   18.4000    1.3087],...
					   'backgroundcolor',framecolor);
	hedit1 = uicontrol('style','edit','units','char','pos',...
					   [11.8000   13.0769  21.6016    1.4615],...
					   'fontsize',9,'fontweight','bold','tag','lat','string','1',...
					   'callback','scircleg(''changelat'')');
	hedit2 = uicontrol('style','edit','units','char','pos',...
					   [11.8000   11.3846   21.6016    1.4615],...
					   'fontsize',9,'fontweight','bold','tag','lon','string','2',...
					   'callback','scircleg(''changelon'')');
	hedit3 = uicontrol('style','edit','units','char','pos',...
					   [11.8000    5.6923   21.6016    1.4615],...
					   'fontsize',9,'fontweight','bold','tag','rad','string','3',...
					   'callback','scircleg(''changeradius'')');
	hedit4 = uicontrol('style','edit','units','char','pos',...
					   [11.8000    2.5385   21.6016    1.4615],...
					   'fontsize',9,'fontweight','bold','tag','npts','string','4',...
					   'callback','scircleg(''npts'')');
	hbutton1 = uicontrol('style','push','units','char','pos',...
					   [11.4000    0.3077   15.2000    1.3077],...
					   'string','Close','fontweight','bold',...
					   'callback','scircleg(''close'')');
	popstr = {'Kilometers','Miles','Nautical Miles','Radians'};				   
	hpop1 = uicontrol('style','popup','units','char','pos',...
					[11.8000    7.0769   21.6016    1.4615],...
					'string',popstr,'tag','units','fontsize',9,...
					'fontweight','bold',...
					'callback','scircleg(''changeunits'')');
	popstr = {'Great Circle','Rhumb Line'};				   
	hpop2 = uicontrol('style','popup','units','char','pos',...
					[11.8000    3.9231   21.6016    1.4615],...
					'string',popstr,'tag','tracktype','fontsize',9,...
					'fontweight','bold',...
					'callback','scircleg(''changetrack'')');
	set(gca,'visible','off')						
	% circles
	hcircles = findobj('tag','InteractiveCircle');
	for i = 1:length(hcircles)
		r = get(hcircles(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcirc = hcircles(i);
			set(hcircles(i),'userdata',s)
		end
	end
	% center point
	hcenters = findobj('tag','InteractiveCircleCenter');
	for i = 1:length(hcenters)
		r = get(hcenters(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = hcenters(i);
		end
	end
	% radial point
	hends = findobj('tag','InteractiveCircleEnd');
	for i = 1:length(hends)
		r = get(hends(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hend = hends(i);
		end
	end
	% update userdata
	s.hcontrol = h;
	s.parent = get(s.hcirc,'parent');	
	set(h,'userdata',s);
	% update track type
	switch s.trk
		case 'gc', val = 1;
		case 'rh', val = 2;	
	end
	set(findobj(h,'tag','tracktype'),'value',val);
	set(findobj(h,'tag','lat'),'string',num2str(s.clat));
	set(findobj(h,'tag','lon'),'string',num2str(s.clon));
	set(findobj(h,'tag','rad'),'string',num2str(deg2km(s.rad)));
	set(findobj(h,'tag','npts'),'string',num2str(s.npts));
	% update the values in the objects
	set(s.hcontrol,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.hcirc,'userdata',s)

% change the number of points	
case 'npts'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.npts))
		return
	elseif str2num(get(gcbo,'string')) < 4
		set(gcbo,'string',num2str(s.npts))
		return
	end	
	% check to see if circle exists
	if ~ishandle(s.hcirc)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Small Circle Tool No Longer Appropriate'},...
							  'Small Circle Tool Error','modal'));
	    scircleg('close');
		return
	end
	s.npts = str2num(get(gcbo,'string'));
	% center point
	hcenters = findobj(gca,'tag','InteractiveCircleCenter');
	for i = 1:length(hcenters)
		r = get(hcenters(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = hcenters(i);
		end
	end
	% radial point
	hends = findobj(gca,'tag','InteractiveCircleEnd');
	for i = 1:length(hends)
		r = get(hends(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hend = hends(i);
		end
	end
	% circle
	hcircles = findobj(gca,'tag','InteractiveCircle');
	for i = 1:length(hcircles)
		r = get(hcircles(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcirc = hcircles(i);
		end
	end
	s.parent = get(s.hcirc,'parent');
	axes(s.parent)	
	% compute the new radial points
	[s.rlat,s.rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.az);	
	% new circle data
	[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							'deg',s.npts);
	% geographic to cartesian
	[x,y] = mfwdtran(s.clat,s.clon);	z = zeros(size(x));
	[rx,ry] = mfwdtran(s.rlat,s.rlon);	rz = zeros(size(rx));
	[crx,cry,crz,t] = mfwdtran(crlat,crlon,zeros(size(crlat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hcenter,'xdata',x,'ydata',y,'zdata',z);
	set(s.hend,'xdata',rx,'ydata',ry,'zdata',rz);
	set(s.hcirc,'xdata',crx,'ydata',cry,'zdata',crz);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	% save the userdata	
	set(par,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcirc,'userdata',s)
	set(s.hend,'userdata',s)

% change the latitude
case 'changelat'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.clat))
		return
	end	
	% check to see if circle exists
	if ~ishandle(s.hcirc)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Small Circle Tool No Longer Appropriate'},...
							  'Small Circle Tool Error','modal'));
	    scircleg('close');
		return
	end
	clat = str2num(get(gcbo,'string'));
	s.clat = clat;	
% 	s.rad = distance(s.trk,clat,s.clon,s.rlat,s.rlon);
	s.az = azimuth(s.trk,s.clat,s.clon,s.rlat,s.rlon);
	% compute the new radial points
	[s.rlat,s.rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.az);	
	% update data in control window
	units = popupstr(findobj(par,'tag','units'));
	switch units
		case 'Kilometers'
			ndist = num2str(deg2km(distance(s.trk,clat,s.clon,s.rlat,s.rlon)));
		case 'Miles'
			dist = distance(s.trk,clat,s.clon,s.rlat,s.rlon);
			d = distdim(dist,'deg','mi');
			ndist = num2str(d);
		case 'Nautical Miles'
			ndist = num2str(deg2nm(distance(s.trk,clat,s.clon,s.rlat,s.rlon)));
		case 'Radians'
			ndist = num2str(deg2rad(distance(s.trk,clat,s.clon,s.rlat,s.rlon)));
	end
	set(findobj(par,'tag','rad'),'string',ndist);
	% center point
	hcenters = findobj(gca,'tag','InteractiveCircleCenter');
	for i = 1:length(hcenters)
		r = get(hcenters(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = hcenters(i);
		end
	end
	% radial point
	hends = findobj(gca,'tag','InteractiveCircleEnd');
	for i = 1:length(hends)
		r = get(hends(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hend = hends(i);
		end
	end
	% circles
	hcircles = findobj(gca,'tag','InteractiveCircle');
	for i = 1:length(hcircles)
		r = get(hcircles(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcirc = hcircles(i);
		end
	end
	s.parent = get(s.hcirc,'parent');	
	axes(s.parent)	
% 	% compute the new radial points
% 	[s.rlat,s.rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.az);	
	% new circle data
	[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							'deg',s.npts);
	% geographic to cartesian
	[x,y] = mfwdtran(s.clat,s.clon);	z = zeros(size(x));
	[rx,ry] = mfwdtran(s.rlat,s.rlon);	rz = zeros(size(rx));
	[crx,cry,crz,t] = mfwdtran(crlat,crlon,zeros(size(crlat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hcenter,'xdata',x,'ydata',y,'zdata',z);
	set(s.hend,'xdata',rx,'ydata',ry,'zdata',rz);
	set(s.hcirc,'xdata',crx,'ydata',cry,'zdata',crz);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	% save the userdata	
	set(par,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcirc,'userdata',s)
	set(s.hend,'userdata',s)
	
% change the longitude
case 'changelon'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.clon))
		return
	end	
	% check to see if circle exists
	if ~ishandle(s.hcirc)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Small Circle Tool No Longer Appropriate'},...
							  'Small Circle Tool Error','modal'));
	    scircleg('close');
		return
	end
	s.clon = str2num(get(gcbo,'string'));
% 	s.rad = distance(s.trk,clat,s.clon,s.rlat,s.rlon);
	s.az = azimuth(s.trk,s.clat,s.clon,s.rlat,s.rlon);
	% compute the new radial points
	[s.rlat,s.rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.az);	
	% update data in control window
	units = popupstr(findobj(par,'tag','units'));
	switch units
		case 'Kilometers'
			ndist = num2str(deg2km(distance(s.trk,s.clat,s.clon,s.rlat,s.rlon)));
		case 'Miles'
			dist = distance(s.trk,s.clat,s.clon,s.rlat,s.rlon);
			d = distdim(dist,'deg','mi');
			ndist = num2str(d);
		case 'Nautical Miles'
			ndist = num2str(deg2nm(distance(s.trk,s.clat,s.clon,s.rlat,s.rlon)));
		case 'Radians'
			ndist = num2str(deg2rad(distance(s.trk,s.clat,s.clon,s.rlat,s.rlon)));
	end
	set(findobj(par,'tag','rad'),'string',ndist);
	% center point
	hcenters = findobj(gca,'tag','InteractiveCircleCenter');
	for i = 1:length(hcenters)
		r = get(hcenters(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = hcenters(i);
		end
	end
	% radial point
	hends = findobj(gca,'tag','InteractiveCircleEnd');
	for i = 1:length(hends)
		r = get(hends(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hend = hends(i);
		end
	end
	% search for the object to update
	hcircles = findobj(gca,'tag','InteractiveCircle');
	for i = 1:length(hcircles)
		r = get(hcircles(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcirc = hcircles(i);
		end
	end
	s.parent = get(s.hcirc,'parent');	
	axes(s.parent)	
	% compute the new radial points
	[s.rlat,s.rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.az);	
	% new circle data
	[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,...
							[1 0],'deg',s.npts);
	% geographic to cartesian
	[x,y] = mfwdtran(s.clat,s.clon);	z = zeros(size(x));
	[rx,ry] = mfwdtran(s.rlat,s.rlon);	rz = zeros(size(rx));
	[crx,cry,crz,t] = mfwdtran(crlat,crlon,zeros(size(crlat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hcenter,'xdata',x,'ydata',y,'zdata',z);
	set(s.hend,'xdata',rx,'ydata',ry,'zdata',rz);
	set(s.hcirc,'xdata',crx,'ydata',cry,'zdata',crz);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	% save the userdata	
	set(par,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcirc,'userdata',s)
	set(s.hend,'userdata',s)
	
% change the radius
case 'changeradius'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string'))) | str2num(get(gcbo,'string')) <=0
		units = popupstr(findobj(par,'tag','units'));
		switch units
			case 'Kilometers'
				ndist = num2str(deg2km(distance(s.trk,s.clat,s.clon,s.rlat,s.rlon)));
			case 'Miles'
				dist = distance(s.trk,s.clat,s.clon,s.rlat,s.rlon);
				d = distdim(dist,'deg','mi');
				ndist = num2str(d);
			case 'Nautical Miles'
				ndist = num2str(deg2nm(distance(s.trk,s.lat,s.lon,s.rlat,s.rlon)));
			case 'Radians'
				ndist = num2str(deg2rad(distance(s.trk,s.lat,s.lon,s.rlat,s.rlon)));
		end
		set(gcbo,'string',ndist)
		return
	end	
	% check to see if circle exists
	if ~ishandle(s.hcirc)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Small Circle Tool No Longer Appropriate'},...
							  'Small Circle Tool Error','modal'));
	    scircleg('close');
		return
	end
	radius = str2num(get(gcbo,'string'));
	% update data in control window
	units = popupstr(findobj(par,'tag','units'));
	switch units
		case 'Kilometers'
			ndist = distdim(radius,'km','deg');
		case 'Miles'
			ndist = distdim(radius,'mi','deg');
		case 'Nautical Miles'
			ndist = distdim(radius,'nm','deg');
		case 'Radians'
			ndist = distdim(radius,'rad','deg');
	end
	s.rad = ndist;
	% center point
	hcenters = findobj(gca,'tag','InteractiveCircleCenter');
	for i = 1:length(hcenters)
		r = get(hcenters(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = hcenters(i);
		end
	end
	% radial point
	hends = findobj(gca,'tag','InteractiveCircleEnd');
	for i = 1:length(hends)
		r = get(hends(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hend = hends(i);
		end
	end
	% search for the object to update
	hcircles = findobj(gca,'tag','InteractiveCircle');
	for i = 1:length(hcircles)
		r = get(hcircles(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcirc = hcircles(i);
		end
	end
	s.parent = get(s.hcirc,'parent');	
	axes(s.parent)	
	% compute the new radial points
	[s.rlat,s.rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.az);	
	% new circle data
	[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,...
							[1 0],'deg',s.npts);
	% geographic to cartesian
	[rx,ry] = mfwdtran(s.rlat,s.rlon);	rz = zeros(size(rx));
	[crx,cry,crz,t] = mfwdtran(crlat,crlon,zeros(size(crlat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hend,'xdata',rx,'ydata',ry,'zdata',rz);
	set(s.hcirc,'xdata',crx,'ydata',cry,'zdata',crz,'userdata',s);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	% save the userdata	
	set(par,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcirc,'userdata',s)
	set(s.hend,'userdata',s)
	
% change the track measurements
case 'changetrack'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% check to see if circle exists
	if ~ishandle(s.hcirc)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Small Circle Tool No Longer Appropriate'},...
							  'Small Circle Tool Error','modal'));
	    scircleg('close');
		return
	end
	val = get(gcbo,'value');
	units = get(gcbo,'string');
	tracktype = units{val};
	switch tracktype
		case 'Great Circle'
			s.trk = 'gc';
		case 'Rhumb Line'	
			s.trk = 'rh';
	end		
	s.rad = distance(s.trk,s.clat,s.clon,s.rlat,s.rlon);
	% center point
	hcenters = findobj(gca,'tag','InteractiveCircleCenter');
	for i = 1:length(hcenters)
		r = get(hcenters(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = hcenters(i);
		end
	end
	% radial point
	hends = findobj(gca,'tag','InteractiveCircleEnd');
	for i = 1:length(hends)
		r = get(hends(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hend = hends(i);
		end
	end
	% small circle
	hcircles = findobj(gca,'tag','InteractiveCircle');
	for i = 1:length(hcircles)
		r = get(hcircles(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcirc = hcircles(i);
		end
	end
	s.parent = get(s.hcirc,'parent');	
	axes(s.parent)	
	% update small circle
	[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							'deg',s.npts);
	[crx,cry,crz,t] = mfwdtran(crlat,crlon,zeros(size(crlat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hcirc,'xdata',crx,'ydata',cry,'zdata',crz,'userdata',s);
	% update data in control window
	units = popupstr(findobj(par,'tag','units'));
	switch units
		case 'Kilometers'
			ndist = num2str(deg2km(distance(s.trk,s.clat,s.clon,s.rlat,s.rlon)));
		case 'Miles'
			dist = distance(s.trk,s.clat,s.clon,s.rlat,s.rlon);
			d = distdim(dist,'deg','mi');
			ndist = num2str(d);
		case 'Nautical Miles'
			ndist = num2str(deg2nm(distance(s.trk,s.clat,s.clon,s.rlat,s.rlon)));
		case 'Radians'
			ndist = num2str(deg2rad(distance(s.trk,s.clat,s.clon,s.rlat,s.rlon)));
	end
	set(findobj(par,'tag','rad'),'string',ndist);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	% save the data
	set(par,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hend,'userdata',s)	
	set(s.hcirc,'userdata',s)
	
% change the units	
case 'changeunits'	
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% check to see if circle exists
	if ~ishandle(s.hcirc)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Small Circle Tool No Longer Appropriate'},...
							  'Small Circle Tool Error','modal'));
	    scircleg('close');
		return
	end
	% circle
	obj = findobj('tag','InteractiveCircle');
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcirc = obj(i);
		end
	end
	s.parent = get(s.hcirc,'parent');	
	axes(s.parent)	
	% center point
	hcenters = findobj(gca,'tag','InteractiveCircleCenter');
	for i = 1:length(hcenters)
		r = get(hcenters(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = hcenters(i);
		end
	end
	x = get(s.hcenter,'xdata');
	y = get(s.hcenter,'ydata');
	[lat,lon] = minvtran(x,y);
	% radial point
	hends = findobj(gca,'tag','InteractiveCircleEnd');
	for i = 1:length(hends)
		r = get(hends(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hend = hends(i);
		end
	end
	rx = get(s.hend,'xdata');
	ry = get(s.hend,'ydata');
	[rlat,rlon] = minvtran(rx,ry);
	units = popupstr(gcbo);
	switch units
		case 'Kilometers'
			ndist = num2str(deg2km(distance(s.trk,lat,lon,rlat,rlon)));
		case 'Miles'
			dist = distance(s.trk,lat,lon,rlat,rlon);
			d = distdim(dist,'deg','mi');
			ndist = num2str(d);
		case 'Nautical Miles'
			ndist = num2str(deg2nm(distance(s.trk,lat,lon,rlat,rlon)));
		case 'Radians'
			ndist = num2str(deg2rad(distance(s.trk,lat,lon,rlat,rlon)));
	end
	set(findobj(par,'tag','rad'),'string',ndist);
		
% close control window and hide controls
case 'close'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% center point
	hcenters = findobj('tag','InteractiveCircleCenter');
	for i = 1:length(hcenters)
		r = get(hcenters(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = hcenters(i);
		end
	end
	% radial point
	hends = findobj('tag','InteractiveCircleEnd');
	for i = 1:length(hends)
		r = get(hends(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hend = hends(i);
		end
	end
	% small circle
	hcircles = findobj('tag','InteractiveCircle');
	for i = 1:length(hcircles)
		r = get(hcircles(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcirc = hcircles(i);
		end
	end
	if ishandle(s.hcirc)
		s.parent = get(s.hcirc,'parent');	
		if ishandle(s.parent)
			axes(s.parent);
		end
	end
	% delete the objects
	if ishandle(s.hcenter); delete(s.hcenter); end
	if ishandle(s.hend);   delete(s.hend);   end
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sccontrol'	
				delete(s.hcontrol); 
		end		
	end
	s.controls = 'off';
	s.hcontrol = [];
	s.hcenter = [];
	s.hend = [];
	if ishandle(s.hcirc);
		set(s.hcirc,'userdata',s)	
	end	
% mouse down on circle
case 'circlemousedown'
	stype = get(gcf,'selectiontype');
	s = get(gco,'userdata');
	s.parent = get(gco,'parent');	
	switch stype % shift-click to toggle control points
		case 'open'
			uimaptbx
		case 'alt'
			uimaptbx
		case 'normal'
			uimaptbx
		case 'extend'
				switch s.controls
					case 'on'
						% kill the control window if its open
						if ishandle(s.hcontrol)
							objtype = get(s.hcontrol,'tag');
							switch objtype
								case 'sccontrol'	
									delete(s.hcontrol)
									s.hcontrol = [];
							end		
						end	
						% delete center
						hcenter = findobj(gca,'tag','InteractiveCircleCenter');
						for i = 1:length(hcenter)
							r = get(hcenter(i),'userdata');
							if r.clat == s.clat & r.num == s.num
								delete(hcenter(i))
							end
						end
						% delete end
						hend = findobj(gca,'tag','InteractiveCircleEnd');
						for i = 1:length(hend)
							r = get(hend(i),'userdata');
							if r.clat == s.clat & r.num == s.num
								delete(hend(i))
							end
						end
						s.controls = 'off';
						set(gco,'userdata',s)
					case 'off'
						s.controls = 'on';
						hcirc = gco;
						set(gco,'userdata',s)
						hcent = plotm(s.clat,s.clon,'rx','linewidth',2,'tag',...
							  'InteractiveCircleCenter','userdata',s,'buttondownfcn',...
							  'scircleg(''centerdown'')');
						hend = plotm(s.rlat,s.rlon,'ro','linewidth',2,'tag','InteractiveCircleEnd',...
							  'markerfacecolor','r','userdata',s,...						
							  'buttondownfcn','scircleg(''enddown'')');
						% display the control window
						scircleg('createcontrols')
						% turn off handle visibility
						hcontrol = findobj('tag','sccontrol');
						for i = 1:length(hcontrol)
							r = get(hcontrol(i),'userdata');
							if r.clat == s.clat & r.num == s.num
								s.hcontrol = hcontrol(i);
								set(hcontrol(i),'handlevisibility','off')
							end	
						end	
						set(hcent,'userdata',s)
						set(hend,'userdata',s)
						set(hcirc,'userdata',s)
				end
	end		

% mouse down on center of circle	
case 'centerdown'
	s = get(gco,'userdata');
	% change the erasemode
	s.hcenter = gco;
	set(s.hcenter,'erasemode','xor')
	% change erasemode of radial control
	hend = findobj(gca,'tag','InteractiveCircleEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hend = hend(i);
			set(hend(i),'erasemode','xor')
		end
	end
	% change erasemode of circle
	hcirc = findobj(gca,'tag','InteractiveCircle');
	for i = 1:length(hcirc)
		r = get(hcirc(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcirc = hcirc(i);
			set(hcirc(i),'erasemode','xor')
		end
	end
	s.parent = get(s.hcirc,'parent');	
	% kill the control if the other control has been deleted
	if ~ishandle(s.hend)
		% code from trackui
	    uiwait(errordlg({'Radial Control Point No Longer Exists',' ',...
						     'Extend Click on Small Circle Again to Drag'},...
							  'Control Point Error','modal'));
		delete(gco)
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			delete(s.hcontrol)
		end	
		return	
	end	
	% check to see that track exists
	if ~ishandle(s.hcirc)
		% code from trackui
	    uiwait(errordlg({'Small Circle No Longer Exists',' ',...
						     'Extend Click on Small Circle Again to Drag'},...
							  'Small Circle Tool Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			delete(s.hcontrol)
		end	
		scircleg('reconstruct')
		return
	end		
	set(s.hcenter,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.hcirc,'userdata',s)
	set(gcf,'windowbuttonmotionfcn','scircleg(''translate'')')
	set(gcf,'windowbuttonupfcn','scircleg(''centerup'')')

% translate location of small circle	
case 'translate'
	s = get(gco,'userdata');
	cpoint = get(gca,'currentpoint');
	x = cpoint(1,1);
	y = cpoint(1,2);
	% compute updated geographic coordinates on the fly
	[s.clat,s.clon] = minvtran(x,y);
	[s.rlat,s.rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.az);
	[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,...
							[1 0],'deg',s.npts);
	% convert geographic coordinates to cartesian coordinates
	[rx,ry] = mfwdtran(s.rlat,s.rlon);
	rad = distance(s.trk,s.clat,s.clon,s.rlat,s.rlon);
	z = zeros(size(x));
	rz = zeros(size(rx));
	[crx,cry,crz,t] = mfwdtran(crlat,crlon,zeros(size(crlat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data in the correct objects
	set(s.hcenter,'xdata',x,'ydata',y,'zdata',z,'userdata',s);
	set(s.hend,'xdata',rx,'ydata',ry,'zdata',rz,'userdata',s);
	set(s.hcirc,'xdata',crx,'ydata',cry,'zdata',crz,'userdata',s);
	% update data in controls window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sccontrol'	
				set(findobj(s.hcontrol,'tag','lat'),'string',num2str(s.clat));
				set(findobj(s.hcontrol,'tag','lon'),'string',num2str(s.clon));
				units = popupstr(findobj(s.hcontrol,'style','popupmenu','tag','units'));
				switch units
					case 'Kilometers'
						rad = deg2km(rad);
					case 'Miles'
						rad = distdim(rad,'deg','mi');
					case 'Nautical Miles'
						rad = deg2nm(rad);
					case 'Radians'
						rad = deg2rad(rad);
				end
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(rad));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
				set(s.hcontrol,'userdata',s)
		end		
	end	

% mouse up from center	
case 'centerup'
	s = get(gco,'userdata');
	% restore erasemode to normal
	set(s.hcenter,'erasemode','normal');
	set(s.hend,'erasemode','normal');
	set(s.hcirc,'erasemode','normal');
	cpoint = get(gca,'currentpoint');
	x = cpoint(1,1);
	y = cpoint(1,2);
	% compute updated geographic coordinates
	[s.clat,s.clon] = minvtran(x,y);
	[s.rlat,s.rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.az);
	[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							'deg',s.npts);
	rad = distance(s.trk,s.clat,s.clon,s.rlat,s.rlon); % radius
	s.az = azimuth(s.trk,s.clat,s.clon,s.rlat,s.rlon); % azimuth
	[crx,cry,crz,t] = mfwdtran(crlat,crlon,zeros(size(crlat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hcenter,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.hcirc,'userdata',s)
	set(gcf,'windowbuttonmotionfcn','')
	set(gcf,'windowbuttonupfcn','')
	% update data in controls window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sccontrol'	
				set(findobj(s.hcontrol,'tag','lat'),'string',num2str(s.clat));
				set(findobj(s.hcontrol,'tag','lon'),'string',num2str(s.clon));
				units = popupstr(findobj(s.hcontrol,'style','popupmenu','tag','units'));
				switch units
					case 'Kilometers'
						rad = deg2km(rad);
					case 'Miles'
						rad = distdim(rad,'deg','mi');
					case 'Nautical Miles'
						rad = deg2nm(rad);
					case 'Radians'
						rad = deg2rad(rad);
				end
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(rad));
				set(s.hcontrol,'userdata',s)
		end		
	end	

% mouse down on end of circle	
case 'enddown'
	s = get(gco,'userdata');
	% change the erasemode
	s.hend = gco;
	set(s.hend,'erasemode','xor')
	% change erasemode of radial control
	hcenter = findobj(gca,'tag','InteractiveCircleCenter');
	for i = 1:length(hcenter)
		r = get(hcenter(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = hcenter(i);
			set(hcenter(i),'erasemode','xor')
		end
	end
	% change erasemode of circle
	hcirc = findobj(gca,'tag','InteractiveCircle');
	for i = 1:length(hcirc)
		r = get(hcirc(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcirc = hcirc(i);
			set(hcirc(i),'erasemode','xor')
		end
	end
	s.parent = get(s.hcirc,'parent');	
	% kill the control if the other control has been deleted
	if ~ishandle(s.hcenter)
		% code from trackui
	    uiwait(errordlg({'Center Control Point No Longer Exists',' ',...
						     'Extend Click on Small Circle Again to Drag'},...
							  'Control Point Error','modal'));
		delete(gco)
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			delete(s.hcontrol)
		end	
		return	
	end	
	% check to see that track exists
	if ~ishandle(s.hcirc)
		% code from trackui
	    uiwait(errordlg({'Small Circle No Longer Exists',' ',...
						     'Extend Click on Small Circle Again to Drag'},...
							  'Small Circle Tool Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			delete(s.hcontrol)
		end	
		scircleg('reconstruct')
		return
	end		
	set(s.hcenter,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.hcirc,'userdata',s)
	set(gcf,'windowbuttonmotionfcn','scircleg(''resize'')')
	set(gcf,'windowbuttonupfcn','scircleg(''endup'')')
	
% resize small circle	
case 'resize'
	s = get(gco,'userdata');
	cpoint = get(gca,'currentpoint');
	rx = cpoint(1,1);
	ry = cpoint(1,2);
	% compute updated geographic coordinates on the fly
	cx = get(s.hcenter,'xdata');
	cy = get(s.hcenter,'ydata');
	[s.clat,s.clon] = minvtran(cx,cy);
	[s.rlat,s.rlon] = minvtran(rx,ry);
	[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,...
							 [1 0],'deg',s.npts);
	s.rad = distance(s.trk,s.clat,s.clon,s.rlat,s.rlon); % radius
	% convert geographic coordinates to cartesian coordinates
	rz = zeros(size(rx));
	[crx,cry,crz,t] = mfwdtran(crlat,crlon,zeros(size(crlat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hend,'xdata',rx,'ydata',ry,'zdata',rz,'userdata',s);
	set(s.hcirc,'xdata',crx,'ydata',cry,'zdata',crz,'userdata',s);
	set(s.hcenter,'userdata',s)
	% update data in controls window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sccontrol'	
				units = popupstr(findobj(s.hcontrol,'style','popupmenu','tag','units'));
				switch units
					case 'Kilometers'
						rad = deg2km(s.rad);
					case 'Miles'
						rad = distdim(s.rad,'deg','mi');
					case 'Nautical Miles'
						rad = deg2nm(s.rad);
					case 'Radians'
						rad = deg2rad(s.rad);
				end
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(rad));
				set(s.hcontrol,'userdata',s)
		end		
	end	

% mouse up from end	
case 'endup'
	s = get(gco,'userdata');
	% change the erasemode
	s.hend = gco;
	set(s.hend,'erasemode','normal')
	% change erasemode of radial control
	hcenter = findobj(gca,'tag','InteractiveCircleCenter');
	for i = 1:length(hcenter)
		r = get(hcenter(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = hcenter(i);
			set(hcenter(i),'erasemode','normal')
		end
	end
	% change erasemode of circle
	hcirc = findobj(gca,'tag','InteractiveCircle');
	for i = 1:length(hcirc)
		r = get(hcirc(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcirc = hcirc(i);
			set(hcirc(i),'erasemode','normal')
		end
	end
	s.parent = get(s.hcirc,'parent');	
	% current point
	cpoint = get(gca,'currentpoint');
	rx = cpoint(1,1);
	ry = cpoint(1,2);
	% compute updated geographic coordinates on the fly
	cx = get(s.hcenter,'xdata');
	cy = get(s.hcenter,'ydata');
	[s.clat,s.clon] = minvtran(cx,cy);
	[s.rlat,s.rlon] = minvtran(rx,ry);
	[crlat,crlon] = scircle2(s.trk,s.clat,s.clon,s.rlat,s.rlon,...
							[1 0],'deg',s.npts);
	s.rad = distance(s.trk,s.clat,s.clon,s.rlat,s.rlon); % radius
	s.az = azimuth(s.trk,s.clat,s.clon,s.rlat,s.rlon); % azimuth
	% convert geographic coordinates to cartesian coordinates
	rz = zeros(size(rx));
	[crx,cry,crz,t] = mfwdtran(crlat,crlon,zeros(size(crlat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hend,'xdata',rx,'ydata',ry,'zdata',rz,'userdata',s);
	set(s.hcirc,'xdata',crx,'ydata',cry,'zdata',crz,'userdata',s);
	set(s.hcenter,'userdata',s)
	% change window motion functions
	set(gcf,'windowbuttonmotionfcn','')
	set(gcf,'windowbuttonupfcn','')
	% update data in controls window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sccontrol'	
				units = popupstr(findobj(s.hcontrol,'style','popupmenu','tag','units'));
				switch units
					case 'Kilometers'
						rad = deg2km(s.rad);
					case 'Miles'
						rad = distdim(s.rad,'deg','mi');
					case 'Nautical Miles'
						rad = deg2nm(s.rad);
					case 'Radians'
						rad = deg2rad(s.rad);
				end
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(rad));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
				set(s.hcontrol,'userdata',s)
		end		
	end	
	
end	

