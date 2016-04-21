function [out1,out2] = trackg(varargin)

%TRACKG  Display of great circles and rhumb lines defined via a mouse input
%
%  TRACKG(n) will compute and display n great circles on the
%  current map axes.  The great circles are defined by
%  a mouse click on the starting and ending point of the track.
%  The circles are interactive. See below for a description of 
%  the interactive mode.
%
%  TRACKG(n,npts) uses the inputs npts to define the number
%  of points per circle computed for each great circle.
%
%  TRACKG(n,'LineSpec') and TRACKG(n,npts,'LineSpec') uses
%  any valid LineSpec string to display the great circles.
%
%  TRACKG(n,'PropertyName',PropertyValue,...) and
%  TRACKG(n,npts,'PropertyName',PropertyValue,...) uses the
%  specified line properties to display the great circles.
%
%  TRACKG('track',...) uses the track string to define
%  the track drawn.  If 'track' = 'gc', then great circles
%  are drawn.  If 'track' = 'rh', then rhumb lines are drawn.
%  If omitted, 'track' = 'gc' is assumed.
%
%  h = TRACKG(...) returns the handles of the tracks drawn.
%
%  [lat,lon] = TRACKG(...) returns the latitude and longitude
%  matrices corresponding to the tracks drawn.
%
%  Extend (shift) clicking on the track displays two control points 
%  (starting point and ending point) and the associated control window.  
%  To translate either point, click and drag the appropriate control.  
%  The starting point is denoted by a 'x' marker, while the ending point 
%  is denoted by a 'o' marker.  The control window allows modification 
%  of certain parameters of the track.  The starting point coordinates 
%  (latitude and longitude) and azimuth can be changed using 
%  edit boxes.  Likewise, the ending point coordinates (latitude
%  and longitude) and azimuth can also be changed from the edit boxes.
%  The distance units (kilometers, miles, nautical miles, radians) and 
%  track (great circle or rhumb line) can be modified using the 
%  appropriate pop-up menus.  The radius and number of points used
%  for the track can be modified using the edit boxes.  A valid map 
%  axes must exist prior to running this function.  DO NOT rename 
%  the tags of the small circle or control points since doing so will 
%  make the call-backs inoperable.
%
%  See also TRACK1, TRACK2, SCIRCLEG

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.13.4.1 $  $Date: 2003/08/01 18:23:01 $
%  Written by:  E. Byrns, E. Brown, Interactive Controls by: L. Job
%  111098


str   = [];     ntrak = [];      npts  = [];

if nargin == 1 & isstr(varargin{1})
   
   % GUI callbacks
   trackui2(varargin{:});
   return
   
elseif nargin ~= 0 & isstr(varargin{1})
   
   str = varargin{1};     varargin(1) = [];

   if length(varargin) == 1 & ~isstr(varargin{1})
          ntrak = varargin{1};    varargin(1) = [];   npts  = [];
   elseif length(varargin) == 1 & isstr(varargin{1})
          ntrak = [];      npts  = [];
   elseif length(varargin) >= 2 & isstr(varargin{2})
          ntrak = varargin{1};   varargin(1) = [];
   elseif length(varargin) >= 2 & ~isstr(varargin{2})
          ntrak = varargin{1};   npts = varargin{2};   varargin(1:2) = [];
   end

elseif nargin ~= 0 & ~isstr(varargin{1})
   str = [];
   ntrak = varargin{1};    varargin(1) = [];

   if length(varargin) >= 1 & ~isstr(varargin{1})
          npts  = varargin{1};   varargin(1) = [];
   end
end

if ~ismap;  error('Not a map axes');  end

%  Use 100 points by default
s.npts = npts;
if isempty(s.npts) | s.npts < 2; 
	s.npts = 100; 
end

%  Test for a valid number of tracks

if isempty(ntrak)
    ntrak = 1;
elseif max(size(ntrak)) ~= 1
    error('Number of tracks must be a scalar')
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
		tagstr = 'InteractiveTrack';
		s.trk = 'gc';
	case 'rh'   
		tagstr = 'InteractiveTrack';
		s.trk = 'rh';
end

%  Pre-allocate some memory space

lat1(ntrak,1) = 0;     lon1(ntrak,1) = 0;
lat2(ntrak,1) = 0;     lon2(ntrak,1) = 0;
rad(ntrak,1) = 0;      saz(ntrak,1) = 0;
eaz(ntrak,1) = 0;
num = rand(size(rad));

%  Get the track definition
%  Enforce that ntrak must be real (avoids messy warning message
%  with colon operator)

for i = 1:real(ntrak)
       disp(['Track',num2str(i),':  Click on starting and ending points'])

       [latpts,lonpts] = inputm(2);
	   if isempty(latpts);   warning('Wrong view for TRACKG');  return;  end

	   lat1(i) = latpts(1);      lon1(i) = lonpts(1);
       lat2(i) = latpts(2);     lon2(i) = lonpts(2);
	   rad(i) = distance(s.trk,lat1(i),lon1(i),lat2(i),lon2(i));
	   saz(i) = azimuth(s.trk,lat1(i),lon1(i),lat2(i),lon2(i));
	   eaz(i) = azimuth(s.trk,lat2(i),lon2(i),lat1(i),lon1(i));	   
 
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


%  Compute tracks

[lattrk,lontrk] = track2(str,lat1,lon1,lat2,lon2,geoid,units,s.npts);

%  Plot the tracks

if ~isempty(varargin)
%  VARARGIN may contain a LineSpec string so it must come before
%  the property 'Tag'.  This has the drawback that any
%  user 'TAG' passed in will be overwritten by tagstr.  However,
%  this is a small price to pay for potentially complex parsing if
%  VARARGIN contains the property 'Tag'.

    hndl = plotm(lattrk,lontrk,varargin{:},'Tag',tagstr);
else
    hndl = plotm(lattrk,lontrk,'Tag',tagstr);
end

%  Set the correct structures
for i = 1:real(ntrak)
	s.slat = lat1(i);
	s.slon = lon1(i);
	s.elat = lat2(i);
	s.elon = lon2(i);
	s.rad = rad(i);
	s.saz = saz(i);
	s.eaz = eaz(i);
	s.units = 'Kilometers';
	s.controls = 'off';
	s.hcontrol = [];
	s.hend = [];
	s.htrack = hndl(i);
	s.parent = get(s.htrack,'parent');	
	s.num = num(i);
    
    structm = getm(hndl(i));
    s.clipped = structm.clipped;
    s.trimmed = structm.clipped;
    
	set(hndl(i),'userdata',s,'buttondownfcn','trackg(''trackdown'')');
end	


%  Set output arguments

if nargout == 1
     out1 = hndl;
elseif nargout == 2
     out1 = lattrk;    out2 = lontrk;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function trackui2(action)
%  trackui2  Callbacks for adding and manipulating tracks on a map
%
%  trackg prompts the user to mouse click two points to define
%  the endpoints of a track.  Double clicking on the track activates
%  the propedit menu.  Normal clicking on the track displays
%  the track's tag.  Alternate (option) clicking on the track 
%  executes the scribe callback.  Extend (shift) clicking on the track 
%  displays two control points (starting point and ending point) 
%  and the associated control window.  To translate either point
%  click and dragging the appropriate control.  The starting point
%  is denoted by a 'x' marker, while the ending point is denoted by
%  a 'o' marker.  The control window allows modification of certain 
%  parameters of the track.  The starting point coordinates (latitude
%  and longitude) and azimuth can be changed using the appropriate
%  edit boxes.  Likewise, the ending point coordinates (latitude
%  and longitude) and azimuth can also be changed from the edit boxes.
%  The distance units (kilometers, miles, nautical miles, radians) and 
%  track (great circle or rhumb line) can be modified using the 
%  appropriate pop-up menus.  The radius and number of points used
%  for the track can be modified using the edit boxes.  A valid map 
%  axes must exist prior to running this function.  DO NOT rename 
%  the tags of the small circle or control points since doing so will 
%  make the call-backs inoperable.
%
%  See also TRACKUI

%  Tags used: 
%  track: InteractiveTrack
%  starting point:  InteractiveTrackStart
%  ending point:    InteractiveTrackEnd

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
	'Click on starting and ending points of track'
	% geographic data
	[s.slat,s.slon] = inputm(1); % center
	[s.elat,s.elon] = inputm(1); % perimeter
	s.trk = 'gc'; % great circle computation by default
	s.npts = 100; % number of points by default	
	s.rad = distance(s.trk,s.slat,s.slon,s.elat,s.elon); % radius
	s.saz = azimuth(s.trk,s.slat,s.slon,s.elat,s.elon); % starting azimuth
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon); % ending azimuth
	% graphic object data
	s.controls = 'off';
	s.hcontrol = [];
	s.hstart = [];
	s.hend = [];
	s.units = 'Kilometers';
	s.num = rand;
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	s.htrack = plotm(trklat,trklon,'b-','linewidth',2,'tag','InteractiveTrack');						 
	s.parent = get(s.htrack,'parent');
	% set buttondown functions of the circle
	set(s.htrack,'userdata',s,'buttondownfcn',...
		'trackg(''trackdown'')');

% reconstruct the track if it has been deleted
case 'reconstruct'		
	s = get(gco,'userdata');
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	s.htrack = plotm(trklat,trklon,'b-','linewidth',2,'tag','InteractiveTrack');						 
	s.parent = get(s.htrack,'parent');	
	axes(s.parent)	
	% set buttondown functions of the circle
	set(s.htrack,'userdata',s,'buttondownfcn',...
		'trackg(''trackdown'')');
	% delete the controls
	delete(s.hstart);
	delete(s.hend);
	
% reproject data	
case 'reproject'
	% track
	htrack = findobj(gca,'tag','InteractiveTrack');
	if ~isempty(htrack)
		for i = 1:length(htrack)
			s =  get(htrack(i),'userdata');
			[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
									 'deg',s.npts);
			% update the track 
			[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
			s.clipped = t.clipped;
			s.trimmed = t.trimmed;
			% slip in the x and y data
			set(htrack(i),'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
		end
	end
	% starting point
	hstart = findobj(gca,'tag','InteractiveTrackStart');
	if ~isempty(hstart)
		for i = 1:length(hstart)
			s =  get(hstart(i),'userdata');
			% update the starting point 
			[x,y] = mfwdtran(s.slat,s.slon); z = 0;
			% slip in the x and y data
			set(hstart(i),'xdata',x,'ydata',y,'zdata',z);
		end
	end
	% starting point
	hend = findobj(gca,'tag','InteractiveTrackEnd');
	if ~isempty(hend)
		for i = 1:length(hend)
			s =  get(hend(i),'userdata');
			% update the ending point 
			[x,y] = mfwdtran(s.elat,s.elon); z = 0;
			% slip in the x and y data
			set(hend(i),'xdata',x,'ydata',y,'zdata',z);
		end
	end
		
% create GUI controls
case 'createcontrols'
	s = get(gco,'userdata');
	h = figure('units','char','pos',...
		[20   5   36.8000   25.4615],...
		'numbertitle','off','name','Track','tag','trkcontrol',...
		'resize','off','HandleVisibility','Callback','Menubar','none');
	framecolor = [0.8944 0.8944 0.8944];	
	frame1 = uicontrol('style','frame','units','char',...
					   'pos',[1.0010   18.2305   34.4    6.8466],...
					   'backgroundcolor',framecolor);
	frame2 = uicontrol('style','frame','units','char',...
					   'pos',[1.0010   10.8466   34.4    6.9994],...
					   'backgroundcolor',framecolor);
	frame3 = uicontrol('style','frame','units','char',...
					   'pos',[1.0010    2.0769   34.4    8.5385],...
					   'backgroundcolor',framecolor);
	htitle1= uicontrol('style','text','string','Starting Point',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995   21.6143   18.4000    3.2311],...
					   'backgroundcolor',framecolor);
	htitle2= uicontrol('style','text','string','Ending Point',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995   14.3858   18.4000    3.2311],...
					   'backgroundcolor',framecolor);
	htitle3= uicontrol('style','text','string','Size',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995    6.9994   18.4000    3.2311],...
					   'backgroundcolor',framecolor);
	hlabel1= uicontrol('style','text','string','Lat',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995   21.8460   18.9998    1.3087],...
					   'backgroundcolor',framecolor);
	hlabel2= uicontrol('style','text','string','Lon',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995   20.2317   18.9998    1.3087],...
					   'backgroundcolor',framecolor);
	hlabel3= uicontrol('style','text','string','Az',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995   18.6175   18.9998    1.3087],...
					   'backgroundcolor',framecolor);
	hlabel4= uicontrol('style','text','string','Lat',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995   14.6149   18.9998    1.3087],...
					   'backgroundcolor',framecolor);
	hlabel5= uicontrol('style','text','string','Lon',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995   13.0007   18.9998    1.3087],...
					   'backgroundcolor',framecolor);
	hlabel6= uicontrol('style','text','string','Az',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995   11.3864   18.9998    1.3087],...
					   'backgroundcolor',framecolor);
	hlabel7= uicontrol('style','text','string','Units',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995    7.3838   18.9998    1.3087],...
					   'backgroundcolor',framecolor);
    hlabel8= uicontrol('style','text','string','Distance',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995    5.7696   18.9998    1.3087],...
					   'backgroundcolor',framecolor);
    hlabel9= uicontrol('style','text','string','Track',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [1.7995    4.1553   18.9998    1.3087],...
					   'backgroundcolor',framecolor);
    hlabel10=uicontrol('style','text','string','Npts',...
					   'fontweight','bold','horizontalalignment','left',...
					   'fontweight','bold',...
					   'units','char','pos',...
					   [1.7995    2.5411   18.9998    1.3087],...
					   'backgroundcolor',framecolor);
	hedit1 = uicontrol('style','edit','units','char','pos',...
					   [12.0005   21.8460   21.6016    1.4615],...
					   'fontsize',9,'tag','slat','string','1',...
					   'fontweight','bold',...
					   'callback','trackg(''slat'')');
	hedit2 = uicontrol('style','edit','units','char','pos',...
					   [12.0005   20.2317   21.6016    1.4615],...
					   'fontsize',9,'tag','slon','string','2',...
					   'fontweight','bold',...
					   'callback','trackg(''slon'')');
	hedit3 = uicontrol('style','edit','units','char','pos',...
					   [12.0005   18.6175   21.6016    1.4615],...
					   'fontsize',9,'tag','saz','string','3',...
    				   'fontweight','bold',...
					   'callback','trackg(''saz'')');
	hedit4 = uicontrol('style','edit','units','char','pos',...
					   [12.0005   14.6149   21.6016    1.4615],...
					   'fontsize',9,'tag','elat','string','4',...
     				   'fontweight','bold',...
					   'callback','trackg(''elat'')');
	hedit5 = uicontrol('style','edit','units','char','pos',...
					   [12.0005   13.0007   21.6016    1.4615],...
					   'fontsize',9,'tag','elon','string','5',...
     				   'fontweight','bold',...
					   'callback','trackg(''elon'')');
	hedit6 = uicontrol('style','edit','units','char','pos',...
					   [12.0005   11.3864   21.6016    1.4615],...
					   'fontsize',9,'tag','eaz','string','6',...
    				   'fontweight','bold',...
					   'callback','trackg(''eaz'')');
	hedit7 = uicontrol('style','edit','units','char','pos',...
					   [12.0005    5.7696   21.6016    1.4615],...
					   'fontsize',9,'tag','rad','string','7',...
    				   'fontweight','bold',...
					   'callback','trackg(''rad'')');
	hedit8 = uicontrol('style','edit','units','char','pos',...
					   [12.0005    2.5411   21.6016    1.4615],...
					   'fontsize',9,'tag','npts','string','8',...
					   'fontweight','bold',...
					   'callback','trackg(''npts'')');
	popstr = {'Kilometers','Miles','Nautical Miles','Radians'};				   
	hpop1 = uicontrol('style','popup','units','char','pos',...
					[12.0005    7.3075   21.6016    1.4615],...
					'string',popstr,'tag','units','fontsize',9,...
					'fontweight','bold',...
					'callback','trackg(''changeunits'')');
	popstr = {'Great Circle','Rhumb Line'};				   
	hpop2 = uicontrol('style','popup','units','char','pos',...
					[12.0005    4.0789   21.6016    1.4615],...
					'string',popstr,'tag','tracktype','fontsize',9,...
					'fontweight','bold',...
					'callback','trackg(''changetrack'')');
	hbutton1 = uicontrol('style','push','units','char','pos',...
					   [11.4000    0.3846   15.2000    1.3077],...
					   'string','Close','fontweight','bold',...
					   'selectionhighlight','on',...
					   'callback','trackg(''close'')');
	set(gca,'visible','off')						
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	% update userdata
	s.hcontrol = h;
	s.parent = get(s.htrack,'parent');	
	% update track type
	switch s.trk
		case 'gc'
			set(findobj(h,'tag','tracktype'),'value',1)
		case 'rh', trkval = 2;	
			set(findobj(h,'tag','tracktype'),'value',2)			
	end
	% update the units
	switch s.units
		case 'Kilometers'
			set(findobj(h,'tag','units'),'value',1);
			dist = distdim(s.rad,'deg','km');
			set(findobj(h,'tag','rad'),'string',num2str(dist));
		case 'Miles'          
			set(findobj(h,'tag','units'),'value',2);
			dist = distdim(s.rad,'deg','mi');
			set(findobj(h,'tag','rad'),'string',num2str(dist));
		case 'Nautical Miles' 
			set(findobj(h,'tag','units'),'value',2);
			dist = distdim(s.rad,'deg','nm');
			set(findobj(h,'tag','rad'),'string',num2str(dist));
		case 'Radians'        
			set(findobj(h,'tag','units'),'value',2);
			dist = distdim(s.rad,'deg','rad');
			set(findobj(h,'tag','rad'),'string',num2str(dist));
	end		
	% update the values in the window
	set(findobj(h,'tag','slat'),'string',num2str(s.slat));
	set(findobj(h,'tag','slon'),'string',num2str(s.slon));
	set(findobj(h,'tag','saz'),'string',num2str(s.saz));
	set(findobj(h,'tag','elat'),'string',num2str(s.elat));
	set(findobj(h,'tag','elon'),'string',num2str(s.elon));
	set(findobj(h,'tag','eaz'),'string',num2str(s.eaz));
	set(findobj(h,'tag','npts'),'string',num2str(s.npts));
	% update the values in the objects
	set(s.hcontrol,'userdata',s)
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)
		
% mouse down on track
case 'trackdown'
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
								case 'trkcontrol'	
									delete(s.hcontrol)
									s.hcontrol = [];
							end		
						end	
						% delete center
						hstart = findobj(gca,'tag','InteractiveTrackStart');
						for i = 1:length(hstart)
							r = get(hstart(i),'userdata');
							if r.slat == s.slat & r.num == s.num
								delete(hstart(i))
							end
						end
						% delete end
						hend = findobj(gca,'tag','InteractiveTrackEnd');
						for i = 1:length(hend)
							r = get(hend(i),'userdata');
							if r.slat == s.slat & r.num == s.num
								delete(hend(i))
							end
						end
						s.hstart = [];
						s.hend = [];
						s.controls = 'off';
						set(gco,'userdata',s)
					case 'off'
						s.controls = 'on';
						s.htrack = gco;
						set(gco,'userdata',s)
						s.hstart = plotm(s.slat,s.slon,'rx','linewidth',2,'tag',...
							  'InteractiveTrackStart','userdata',s,'buttondownfcn',...
							  'trackg(''startdown'')');
						s.hend = plotm(s.elat,s.elon,'ro','linewidth',2,'tag','InteractiveTrackEnd',...
							  'markerfacecolor','r','userdata',s,...						
							  'buttondownfcn','trackg(''enddown'')');
						% display the control window
						trackg('createcontrols')
						% turn off handle visibility
						hcontrol = findobj('tag','trkcontrol');
						for i = 1:length(hcontrol)
							r = get(hcontrol(i),'userdata');
							if r.slat == s.slat & r.num == s.num
								s.hcontrol = hcontrol(i);
								set(hcontrol(i),'handlevisibility','off')
							end	
						end	
						% update the data
						set(s.hstart,'userdata',s)
						set(s.hend,'userdata',s)
						set(s.htrack,'userdata',s)
						set(s.hcontrol,'userdata',s)
				end
	end		
	
% mouse down on starting point	
case 'startdown'	
	s = get(gco,'userdata');
	% change the erasemode
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');	
	% kill the control if the other control has been deleted
	if ~ishandle(s.hend)
		% code from trackui
	    uiwait(errordlg({'Ending Control Point No Longer Exists',' ',...
						     'Extend Click on Track Again to Drag'},...
							  'Control Point Error','modal'));
		delete(gco)
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			delete(s.hcontrol)
		end	
		return	
	end	
	% check to see that track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Track No Longer Exists',' ',...
						     'Extend Click on Track Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			delete(s.hcontrol)
		end	
		trackg('reconstruct')
		return
	end		
	set(s.hstart,'userdata',s,'erasemode','xor')
	set(s.hend,'userdata',s,'erasemode','xor')
	set(s.htrack,'userdata',s,'erasemode','xor')
	set(gcf,'windowbuttonmotionfcn','trackg(''startmove'')')
	set(gcf,'windowbuttonupfcn','trackg(''startup'')')
	
% move the starting point	
case 'startmove'
	s = get(gco,'userdata');
	cpoint = get(gca,'currentpoint');
	x = cpoint(1,1);
	y = cpoint(1,2);
	% starting point
	[s.slat,s.slon] = minvtran(x,y);
	% other properties
	s.rad = distance(s.trk,s.slat,s.slon,s.elat,s.elon); % radius
	s.saz = azimuth(s.trk,s.slat,s.slon,s.elat,s.elon); % starting azimuth
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon); % ending azimuth
	% track data
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hstart,'xdata',x,'ydata',y,'zdata',0)
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'trkcontrol'	
				% update the units
				switch s.units
					case 'Kilometers'
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the values in the window
				set(findobj(s.hcontrol,'tag','slat'),'string',num2str(s.slat));
				set(findobj(s.hcontrol,'tag','slon'),'string',num2str(s.slon));
				set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','elat'),'string',num2str(s.elat));
				set(findobj(s.hcontrol,'tag','elon'),'string',num2str(s.elon));
				set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
		end	
	end	

% mouse up from starting point	
case 'startup'
	s = get(gco,'userdata');
	cpoint = get(gca,'currentpoint');
	x = cpoint(1,1);
	y = cpoint(1,2);
	% starting point
	[s.slat,s.slon] = minvtran(x,y);
	% other properties
	s.rad = distance(s.trk,s.slat,s.slon,s.elat,s.elon); % radius
	s.saz = azimuth(s.trk,s.slat,s.slon,s.elat,s.elon); % starting azimuth
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon); % ending azimuth
	% track data
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hstart,'xdata',x,'ydata',y,'zdata',0)
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'trkcontrol'	
				% update the units
				switch s.units
					case 'Kilometers'
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the values in the window
				set(findobj(s.hcontrol,'tag','slat'),'string',num2str(s.slat));
				set(findobj(s.hcontrol,'tag','slon'),'string',num2str(s.slon));
				set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','elat'),'string',num2str(s.elat));
				set(findobj(s.hcontrol,'tag','elon'),'string',num2str(s.elon));
				set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
		end		
	end	
	% restore erasemodes
	set(s.hstart,'userdata',s,'erasemode','normal')
	set(s.hend,'userdata',s,'erasemode','normal')
	set(s.htrack,'userdata',s,'erasemode','normal')
	set(gcf,'windowbuttonmotionfcn','')
	set(gcf,'windowbuttonupfcn','')
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% mouse down on ending point	
case 'enddown'	
	s = get(gco,'userdata');
	% change the erasemode
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');	
	% kill the control if the other control has been deleted
	if ~ishandle(s.hstart)
	    uiwait(errordlg({'Starting Control Point No Longer Exists',' ',...
						     'Extend Click on Track Again to Drag'},...
							  'Control Point Error','modal'));
		delete(gco)
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			delete(s.hcontrol)
		end	
		return	
	end	
	% check to see that track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Track No Longer Exists',' ',...
						     'Extend Click on Track Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			delete(s.hcontrol)
		end	
		trackg('reconstruct')
		return
	end		
	set(s.hstart,'userdata',s,'erasemode','xor')
	set(s.hend,'userdata',s,'erasemode','xor')
	set(s.htrack,'userdata',s,'erasemode','xor')
	set(gcf,'windowbuttonmotionfcn','trackg(''endmove'')')
	set(gcf,'windowbuttonupfcn','trackg(''endup'')')

% move the starting point	
case 'endmove'
	s = get(gco,'userdata');
	cpoint = get(gca,'currentpoint');
	x = cpoint(1,1);
	y = cpoint(1,2);
	% ending point
	[s.elat,s.elon] = minvtran(x,y);
	% other properties
	s.rad = distance(s.trk,s.slat,s.slon,s.elat,s.elon); % radius
	s.saz = azimuth(s.trk,s.slat,s.slon,s.elat,s.elon); % starting azimuth
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon); % ending azimuth
	% track data
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hend,'xdata',x,'ydata',y,'zdata',0)
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'trkcontrol'	
				% update the units
				switch s.units
					case 'Kilometers'
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the values in the window
				set(findobj(s.hcontrol,'tag','slat'),'string',num2str(s.slat));
				set(findobj(s.hcontrol,'tag','slon'),'string',num2str(s.slon));
				set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','elat'),'string',num2str(s.elat));
				set(findobj(s.hcontrol,'tag','elon'),'string',num2str(s.elon));
				set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
		end		
	end	

% mouse up from ending point	
case 'endup'
	s = get(gco,'userdata');
	cpoint = get(gca,'currentpoint');
	x = cpoint(1,1);
	y = cpoint(1,2);
	% ending point
	[s.elat,s.elon] = minvtran(x,y);
	% other properties
	s.rad = distance(s.trk,s.slat,s.slon,s.elat,s.elon); % radius
	s.saz = azimuth(s.trk,s.slat,s.slon,s.elat,s.elon); % starting azimuth
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon); % ending azimuth
	% track data
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hend,'xdata',x,'ydata',y,'zdata',0)
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'trkcontrol'	
				% update the units
				switch s.units
					case 'Kilometers'
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the values in the window
				set(findobj(s.hcontrol,'tag','slat'),'string',num2str(s.slat));
				set(findobj(s.hcontrol,'tag','slon'),'string',num2str(s.slon));
				set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','elat'),'string',num2str(s.elat));
				set(findobj(s.hcontrol,'tag','elon'),'string',num2str(s.elon));
				set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
		end		
	end	
	% restore erasemodes
	set(s.hstart,'userdata',s,'erasemode','normal')
	set(s.hend,'userdata',s,'erasemode','normal')
	set(s.htrack,'userdata',s,'erasemode','normal')
	set(gcf,'windowbuttonmotionfcn','')
	set(gcf,'windowbuttonupfcn','')
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% change the starting latitude from the control window	
case 'slat'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.slat))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Track Tool No Longer Appropriate'},...
							  'Track Tool Error','modal'));
	    trackg('close');
		return
	end
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');	
	axes(s.parent)	
	% update changes
	s.slat = str2num(get(gcbo,'string'));
	s.saz = azimuth(s.trk,s.slat,s.slon,s.elat,s.elon);
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon);
	s.rad = distance(s.trk,s.slat,s.slon,s.elat,s.elon);
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		% update the units
		switch s.units
			case 'Kilometers'
				dist = distdim(s.rad,'deg','km');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Miles'          
				dist = distdim(s.rad,'deg','mi');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Nautical Miles' 
				dist = distdim(s.rad,'deg','nm');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Radians'        
				dist = distdim(s.rad,'deg','rad');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
		end		
		% update the values in the window
		set(findobj(s.hcontrol,'tag','slat'),'string',num2str(s.slat));
		set(findobj(s.hcontrol,'tag','slon'),'string',num2str(s.slon));
		set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
		set(findobj(s.hcontrol,'tag','elat'),'string',num2str(s.elat));
		set(findobj(s.hcontrol,'tag','elon'),'string',num2str(s.elon));
		set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
	end	
	% update the graphics object
	[x,y] = mfwdtran(s.slat,s.slon); z = 0;
	% track data
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hstart,'xdata',x,'ydata',y,'zdata',0)
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% change the starting longitude from the control window	
case 'slon'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.slon))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Track Tool No Longer Appropriate'},...
							  'Track Tool Error','modal'));
	    trackg('close');
		return
	end
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');
	axes(s.parent)	
	% update changes
	s.slon = str2num(get(gcbo,'string'));
	s.saz = azimuth(s.trk,s.slat,s.slon,s.elat,s.elon);
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon);
	s.rad = distance(s.trk,s.slat,s.slon,s.elat,s.elon);
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		% update the units
		switch s.units
			case 'Kilometers'
				dist = distdim(s.rad,'deg','km');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Miles'          
				dist = distdim(s.rad,'deg','mi');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Nautical Miles' 
				dist = distdim(s.rad,'deg','nm');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Radians'        
				dist = distdim(s.rad,'deg','rad');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
		end		
		% update the values in the window
		set(findobj(s.hcontrol,'tag','slat'),'string',num2str(s.slat));
		set(findobj(s.hcontrol,'tag','slon'),'string',num2str(s.slon));
		set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
		set(findobj(s.hcontrol,'tag','elat'),'string',num2str(s.elat));
		set(findobj(s.hcontrol,'tag','elon'),'string',num2str(s.elon));
		set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
	end	
	% update the graphics object
	[x,y] = mfwdtran(s.slat,s.slon); z = 0;
	% track data
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hstart,'xdata',x,'ydata',y,'zdata',0)
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% change the starting azimuth from the control window	
case 'saz'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.saz))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Track Tool No Longer Appropriate'},...
							  'Track Tool Error','modal'));
	    trackg('close');
		return
	end
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');	
	axes(s.parent)	
	% update changes
	s.saz = str2num(get(gcbo,'string'));
	[s.elat,s.elon] = reckon(s.trk,s.slat,s.slon,...
							 s.rad,s.saz);
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon);
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		% update the values in the window
		set(findobj(s.hcontrol,'tag','slat'),'string',num2str(s.slat));
		set(findobj(s.hcontrol,'tag','slon'),'string',num2str(s.slon));
		set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
		set(findobj(s.hcontrol,'tag','elat'),'string',num2str(s.elat));
		set(findobj(s.hcontrol,'tag','elon'),'string',num2str(s.elon));
		set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
	end	
	% update the graphics object
	[x,y] = mfwdtran(s.elat,s.elon); z = 0;
	% track data
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hend,'xdata',x,'ydata',y,'zdata',0)
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% change the ending latitude from the control window	
case 'elat'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.elat))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Track Tool No Longer Appropriate'},...
							  'Track Tool Error','modal'));
	    trackg('close');
		return
	end
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');
	axes(s.parent)	
	% update changes
	s.elat = str2num(get(gcbo,'string'));
	s.saz = azimuth(s.trk,s.slat,s.slon,s.elat,s.elon);
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon);
	s.rad = distance(s.trk,s.slat,s.slon,s.elat,s.elon);
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		% update the units
		switch s.units
			case 'Kilometers'
				dist = distdim(s.rad,'deg','km');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Miles'          
				dist = distdim(s.rad,'deg','mi');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Nautical Miles' 
				dist = distdim(s.rad,'deg','nm');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Radians'        
				dist = distdim(s.rad,'deg','rad');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
		end		
		% update the values in the window
		set(findobj(s.hcontrol,'tag','slat'),'string',num2str(s.slat));
		set(findobj(s.hcontrol,'tag','slon'),'string',num2str(s.slon));
		set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
		set(findobj(s.hcontrol,'tag','elat'),'string',num2str(s.elat));
		set(findobj(s.hcontrol,'tag','elon'),'string',num2str(s.elon));
		set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
	end	
	% update the graphics object
	[x,y] = mfwdtran(s.elat,s.elon); z = 0;
	% track data
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hend,'xdata',x,'ydata',y,'zdata',0)
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% change the ending longitude from the control window	
case 'elon'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.elon))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Track Tool No Longer Appropriate'},...
							  'Track Tool Error','modal'));
	    trackg('close');
		return
	end
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');	
	axes(s.parent)	
	% update changes
	s.elon = str2num(get(gcbo,'string'));
	s.saz = azimuth(s.trk,s.slat,s.slon,s.elat,s.elon);
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon);
	s.rad = distance(s.trk,s.slat,s.slon,s.elat,s.elon);
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		% update the units
		switch s.units
			case 'Kilometers'
				dist = distdim(s.rad,'deg','km');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Miles'          
				dist = distdim(s.rad,'deg','mi');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Nautical Miles' 
				dist = distdim(s.rad,'deg','nm');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Radians'        
				dist = distdim(s.rad,'deg','rad');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
		end		
		% update the values in the window
		set(findobj(s.hcontrol,'tag','slat'),'string',num2str(s.slat));
		set(findobj(s.hcontrol,'tag','slon'),'string',num2str(s.slon));
		set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
		set(findobj(s.hcontrol,'tag','elat'),'string',num2str(s.elat));
		set(findobj(s.hcontrol,'tag','elon'),'string',num2str(s.elon));
		set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
	end	
	% update the graphics object
	[x,y] = mfwdtran(s.elat,s.elon); z = 0;
	% track data
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hend,'xdata',x,'ydata',y,'zdata',0)
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% change the ending azimuth from the control window	
case 'eaz'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.eaz))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Track Tool No Longer Appropriate'},...
							  'Track Tool Error','modal'));
	    trackg('close');
		return
	end
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');	
	axes(s.parent)	
	% update changes
	s.eaz = str2num(get(gcbo,'string'));
	[s.slat,s.slon] = reckon(s.trk,s.elat,s.elon,...
							 s.rad,s.eaz);
	s.saz = azimuth(s.trk,s.slat,s.slon,s.elat,s.elon);
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		% update the values in the window
		set(findobj(s.hcontrol,'tag','slat'),'string',num2str(s.slat));
		set(findobj(s.hcontrol,'tag','slon'),'string',num2str(s.slon));
		set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
		set(findobj(s.hcontrol,'tag','elat'),'string',num2str(s.elat));
		set(findobj(s.hcontrol,'tag','elon'),'string',num2str(s.elon));
		set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
	end	
	% update the graphics object
	[x,y] = mfwdtran(s.slat,s.slon); z = 0;
	% track data
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hstart,'xdata',x,'ydata',y,'zdata',0)
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% change the units from the control window	
case 'changeunits'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% check to see if track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Track Tool No Longer Appropriate'},...
							  'Track Tool Error','modal'));
	    trackg('close');
		return
	end
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');	
	axes(s.parent)	
	% update changes
	s.units = popupstr(gcbo);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		% update the units
		switch s.units
			case 'Kilometers'
				dist = distdim(s.rad,'deg','km');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Miles'          
				dist = distdim(s.rad,'deg','mi');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Nautical Miles' 
				dist = distdim(s.rad,'deg','nm');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Radians'        
				dist = distdim(s.rad,'deg','rad');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
		end	
	end			
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% change the radius from the control window	
case 'rad'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string'))) | str2num(get(gcbo,'string')) <= 0
		switch s.units
			case 'Kilometers'
				dist = distdim(s.rad,'deg','km');
			case 'Miles'          
				dist = distdim(s.rad,'deg','mi');
			case 'Nautical Miles' 
				dist = distdim(s.rad,'deg','nm');
			case 'Radians'        
				dist = distdim(s.rad,'deg','rad');
		end	
		set(gcbo,'string',num2str(dist))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Track Tool No Longer Appropriate'},...
							  'Track Tool Error','modal'));
	    trackg('close');
		return
	end
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');	
	axes(s.parent)	
	% update changes
	radius = str2num(get(gcbo,'string'));
	switch s.units
		case 'Kilometers'
			dist = distdim(radius,'km','deg');
		case 'Miles'          
			dist = distdim(radius,'mi','deg');
		case 'Nautical Miles' 
			dist = distdim(radius,'nm','deg');
		case 'Radians'        
			dist = distdim(radius,'rad','deg');
	end	
	s.rad = dist;	
	[s.elat,s.elon] = reckon(s.trk,s.slat,s.slon,...
							 s.rad,s.saz);
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon);	
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		% update the values in the window
		set(findobj(s.hcontrol,'tag','slat'),'string',num2str(s.slat));
		set(findobj(s.hcontrol,'tag','slon'),'string',num2str(s.slon));
		set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
		set(findobj(s.hcontrol,'tag','elat'),'string',num2str(s.elat));
		set(findobj(s.hcontrol,'tag','elon'),'string',num2str(s.elon));
		set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
	end	
	% update the graphics object
	[x,y] = mfwdtran(s.elat,s.elon); z = 0;
	% track data
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.hend,'xdata',x,'ydata',y,'zdata',0)
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% change the track type	
case 'changetrack'	
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% check to see if track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Track Tool No Longer Appropriate'},...
							  'Track Tool Error','modal'));
	    trackg('close');
		return
	end
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');	
	axes(s.parent)	
	% update changes
	tracktype = popupstr(gcbo);
	% update track type
	switch tracktype
		case 'Great Circle'
			s.trk = 'gc';
		case 'Rhumb Line'
			s.trk = 'rh';
	end
	s.rad = distance(s.trk,s.slat,s.slon,s.elat,s.elon); % radius
	s.saz = azimuth(s.trk,s.slat,s.slon,s.elat,s.elon); % starting az
	s.eaz = azimuth(s.trk,s.elat,s.elon,s.slat,s.slon); % ending az	
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		set(findobj(s.hcontrol,'tag','saz'),'string',num2str(s.saz));
		set(findobj(s.hcontrol,'tag','eaz'),'string',num2str(s.eaz));
		% update the units
		switch s.units
			case 'Kilometers'
				dist = distdim(s.rad,'deg','km');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Miles'          
				dist = distdim(s.rad,'deg','mi');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Nautical Miles' 
				dist = distdim(s.rad,'deg','nm');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
			case 'Radians'        
				dist = distdim(s.rad,'deg','rad');
				set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
		end	
	end			
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% change the number of points for the track	
case 'npts'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user entries incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.npts))
		return
	elseif str2num(get(gcbo,'string')) < 2
		set(gcbo,'string',num2str(s.npts))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.htrack)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Track Tool No Longer Appropriate'},...
							  'Track Tool Error','modal'));
	    trackg('close');
		return
	end
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	s.parent = get(s.htrack,'parent');	
	axes(s.parent)	
	% update changes
	s.npts = str2num(get(gcbo,'string'));
	[trklat,trklon] = track2(s.trk,s.slat,s.slon,s.elat,s.elon,[1 0],...
							 'deg',s.npts);
	% update the starting point and track interactively
	[trkx,trky,trkz,t] = mfwdtran(trklat,trklon,zeros(size(trklat)),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	% slip in the x and y data
	set(s.htrack,'xdata',trkx,'ydata',trky,'zdata',trkz,'userdata',s);
	% update the userdata
	if ishandle(s.hcontrol)
		set(s.hcontrol,'userdata',s)
	end
	set(s.hstart,'userdata',s)
	set(s.hend,'userdata',s)
	set(s.htrack,'userdata',s)	

% close the control window and kill the controls	
case 'close'	
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% track
	htrack = findobj('tag','InteractiveTrack');
	for i = 1:length(htrack)
		r = get(htrack(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.htrack = htrack(i);
		end
	end
	% starting point
	hstart = findobj('tag','InteractiveTrackStart');
	for i = 1:length(hstart)
		r = get(hstart(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hstart = hstart(i);
		end
	end
	% ending point
	hend = findobj('tag','InteractiveTrackEnd');
	for i = 1:length(hend)
		r = get(hend(i),'userdata');
		if r.slat == s.slat & r.num == s.num
			s.hend = hend(i);
		end
	end
	if ishandle(s.htrack)
		s.parent = get(s.htrack,'parent');	
		axes(s.parent)
	end	
	% delete the objects
	if ishandle(s.hstart); delete(s.hstart); end
	if ishandle(s.hend);   delete(s.hend);   end
	if ishandle(s.hcontrol); 
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'trkcontrol'	
				delete(s.hcontrol); 
		end
	end
	s.controls = 'off';
	s.hcontrol = [];
	s.hstart = [];
	s.hend = [];
	if ishandle(s.htrack);
		set(s.htrack,'userdata',s)	
	end	
end		


