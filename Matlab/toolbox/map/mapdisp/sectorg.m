function sectorg(action)

%SECTORG display of small circle sectors defined via a mouse input
%
%  SECTORG prompts the user to mouse click two points to define
%  the center and radius of a small circle arc.   By default
%  a 60 degree sector is constructed using the edge defined
%  by the mouse clicks as the reference azimuth.  Extend (shift)
%  clicking on the arc displays four control points (center
%  point, arc resize, radial resize, and rotation controls) 
%  and the associated control window.  To translate
%  the circle, click and drag the center (o) control.  To change the
%  arc size, click and drag the resize control (square).
%  To change the radial size of the sector, click and drag the 
%  radial control (down triangle).  To rotate the arc, click
%  and drag the rotation control (x).  Changes can be also made 
%  by entering the appropriate values in the control window and 
%  clicking the apply button.  Display of the control buttons is
%  toggled by extend clicking the arc.  A valid map axes must exist 
%  prior to running this function.  
%
%  See also SCIRCLEG, TRACKG

%  Copyright 1996-2003 The MathWorks, Inc.
%  L. Job
%  $Revision: 1.6.4.1 $    $Date: 2003/08/01 18:22:40 $


if nargin == 0;
   action = 1;
end

if isnumeric(action)
   n = action;
   for i=1:n
      sectorui
   end
   
elseif isstr(action)
   
   sectorui(action)
   
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sectorui(action)
%  sectorui  Callbacks for adding and manipulating sectors on a map
%
%  sectorg prompts the user to mouse click two points to define
%  the center point, radius, and central azimuth of a sector.  A sector
%  is created from the center point to points on the radius oriented
%  about the azimuth.  By default, the edges of the sector are created
%  using TRACK2 with azimuths of +30 deg and -30 deg about the central
%  azimuth.  The radial arc is created using SCIRCLE2.  The following 
%  selection types are supported. Double clicking on the sector activates 
%  the propedit menu.  Normal clicking on the sector displays the sector's tag.  
%  Alternate (option) clicking on the sector executes the scribe callback.  
%  Extend (shift) clicking on the sector displays four control points 
%  (azimuth resize control point, radial resize control point, rotation control
%  point, translation control point) and the associated control window.  
%  To translate the sector, click and drag the circular control point.
%  The changes in latitude and longitude are reflected in the control window.
%  To change the sector width, click and drag the square control point.
%  To change the radial size of the sector, click and drag the triangular
%  control point.  To rotate the sector, click and drag the 'x' control point.
%  The orientation and size of the sector can be also modified via the
%  control window.  A valid map axes must exist prior to running this
%  function.  DO NOT rename the tags of the sector or control points since
%  doing so will make the call-backs inoperable.

%  Tags used: 
%  sector: InteractiveSector
%  center: InteractiveSectorCenter
%  resize: InteractiveSectorResize
%  centeraz:  InteractiveSectorCenterAz
%  radius: InteractiveSectorRadius
%  rotate: InteractiveSectorRotate

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
	'Click on center and perimeter to define sector'
	% geographic data
	[s.clat,s.clon] = inputm(1); % center
	[s.rlat,s.rlon] = inputm(1); % perimeter
	s.trk = 'gc'; % great circle by default
	s.rad = distance(s.trk, s.clat, s.clon, s.rlat, s.rlon); % radius
	s.caz = azimuth(s.trk,s.clat,s.clon,s.rlat,s.rlon); % azimuth
	s.npts = 24; % number of points by default	
	s.units = 'Kilometers'; % kilometers by default
	s.sectorwidth = 60; % default
	s.saz = zero22pi(s.caz-s.sectorwidth/2); % starting azimuth
	s.eaz = zero22pi(s.caz+s.sectorwidth/2); % ending azimuth
	[s.slat,s.slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz); % starting point
	[s.elat,s.elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz); % ending point
	s.azlimits = [s.saz s.eaz]; % azimuth limits
	% face 1
	[lat1,lon1] = track2(s.trk,s.clat,s.clon,s.slat,s.slon,[1 0],...
						 'deg',s.npts/3);
	% face 2
	[lat2,lon2] = scircle1(s.trk,s.clat,s.clon,s.rad,[s.saz s.eaz],...
						   [rad2deg(1) 0],'deg',s.npts/3);
	% face 3
	[lat3,lon3] = track2(s.trk,s.elat,s.elon,s.clat,s.clon,[1 0],...
						 'deg',s.npts/3);
	% plot sector
	mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
	s.hsector = plotm(mat(:,1),mat(:,2),'b-','linewidth',2,'tag',...
					  'InteractiveSector');
	% graphics object data
	s.hcenter = [];
	s.hcaz = [];
	s.hresize = [];
	s.hrotate = [];
	s.hradius = [];
	s.controls = 'off';
	s.hcontrol = [];
	s.parent = get(s.hsector,'parent');
	s.num = rand;
    
    structm = getm(s.hsector);
    s.clipped = structm.clipped;
    s.trimmed = structm.clipped;
    
	% set buttondown functions of the circle
	set(s.hsector,'userdata',s,'buttondownfcn','sectorg(''trackdown'')');
	
% reconstruct the track if it has been deleted
case 'reconstruct'		
	s = get(gco,'userdata');
	if ishandle(s.hsector); delete(s.hsector); end
	if ishandle(s.hcenter); delete(s.hcenter); end
	if ishandle(s.hcaz);    delete(s.hcaz);    end
	if ishandle(s.hresize); delete(s.hresize); end
	if ishandle(s.hrotate); delete(s.hrotate); end
	if ishandle(s.hradius); delete(s.hradius); end
	% face 1
	[lat1,lon1] = track2(s.trk,s.clat,s.clon,s.slat,s.slon,[1 0],...
						 'deg',s.npts/3);
	% face 2
	[lat2,lon2] = scircle1(s.trk,s.clat,s.clon,s.rad,[s.saz s.eaz],...
						   [rad2deg(1) 0],'deg',s.npts/3);
	% face 3
	[lat3,lon3] = track2(s.trk,s.elat,s.elon,s.clat,s.clon,[1 0],...
						 'deg',s.npts/3);
	% plot sector
	mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
	s.hsector = plotm(mat(:,1),mat(:,2),'b-','linewidth',2,'tag',...
					  'InteractiveSector');
	% graphics object data
	s.hcenter = [];
	s.hcaz = [];
	s.hresize = [];
	s.hrotate = [];
	s.hradius = [];
	s.controls = 'off';
	s.hcontrol = [];
	% set buttondown functions of the circle
	set(s.hsector,'userdata',s,'buttondownfcn','sectorg(''trackdown'')');
	% delete the controls
	delete(s.hcenter)
	delete(s.hcaz)
	delete(s.hresize)
	delete(s.hrotate)
	delete(s.hradius)
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'	
				delete(s.hcontrol)
		end		
	end	

% reproject data	
case 'reproject'
	% sector
	obj = findobj(gca,'tag','InteractiveSector');
	for i = 1:length(obj)
		s = get(obj(i),'userdata');
		% face 1
		[lat1,lon1] = track2(s.trk,s.clat,s.clon,s.slat,s.slon,[1 0],...
							 'deg',s.npts/3);
		% face 2
		[lat2,lon2] = scircle1(s.trk,s.clat,s.clon,s.rad,[s.saz s.eaz],...
							   [rad2deg(1) 0],'deg',s.npts/3);
		% face 3
		[lat3,lon3] = track2(s.trk,s.elat,s.elon,s.clat,s.clon,[1 0],...
							 'deg',s.npts/3);
		% sector data
		mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
		[x,y,z,t] = mfwdtran(mat(:,1),mat(:,2),zeros(size(mat(:,1))),'line');
		s.clipped = t.clipped;
		s.trimmed = t.trimmed;
		% slip in the x and y data
		set(obj(i),'xdata',x,'ydata',y,'zdata',z,'userdata',s);
	end	
	% center
	obj = findobj(gca,'tag','InteractiveSectorCenter');
	for i = 1:length(obj)
		s = get(obj(i),'userdata');
		[x,y,z] = mfwdtran(s.clat,s.clon,zeros(size(s.clat)));
		% slip in the x and y data
		set(obj(i),'xdata',x,'ydata',y,'zdata',z);
	end	
	% resize
	obj = findobj(gca,'tag','InteractiveSectorResize');
	for i = 1:length(obj)
		s = get(obj(i),'userdata');
		[x,y,z] = mfwdtran(s.slat,s.slon,zeros(size(s.slat)));
		% slip in the x and y data
		set(obj(i),'xdata',x,'ydata',y,'zdata',z);
	end	
	% radius
	obj = findobj(gca,'tag','InteractiveSectorRadius');
	for i = 1:length(obj)
		s = get(obj(i),'userdata');
		[x,y,z] = mfwdtran(s.rlat,s.rlon,zeros(size(s.rlat)));
		% slip in the x and y data
		set(obj(i),'xdata',x,'ydata',y,'zdata',z);
	end	
	% rotate
	obj = findobj(gca,'tag','InteractiveSectorRotate');
	for i = 1:length(obj)
		s = get(obj(i),'userdata');
		[x,y,z] = mfwdtran(s.elat,s.elon,zeros(size(s.elat)));
		% slip in the x and y data
		set(obj(i),'xdata',x,'ydata',y,'zdata',z);
	end	
	% center azimuth
	obj = findobj(gca,'tag','InteractiveSectorCenterAz');
	for i = 1:length(obj)
		s = get(obj(i),'userdata');
		[cazlat,cazlon] = track2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							 'deg',s.npts/3);
		[x,y,z] = mfwdtran(cazlat,cazlon,zeros(size(cazlat))); 
		% slip in the x and y data
		set(obj(i),'xdata',x,'ydata',y,'zdata',z);
	end	
	
% create control window
case 'createcontrols'
	s = get(gco,'userdata');
	h = figure('units','char','pos',...
		[20 5   37.4000   32.8462],...
		'numbertitle','off','name','Sector','tag','sectorcontrol',...
		'resize','off','HandleVisibility','Callback','Menubar','none');
	framecolor = [0.8944 0.8944 0.8944];	
	frame1 = uicontrol('style','frame','units','char',...
					   'pos',[1.2000   25.0769   34.4000    6.9231],...
					   'backgroundcolor',framecolor);
	frame2 = uicontrol('style','frame','units','char',...
					   'pos',[1.2000   11.6923   34.4000   12.9231],...
					   'backgroundcolor',framecolor);
	frame3 = uicontrol('style','frame','units','char',...
					   'pos',[1.2000    2.2308   34.4000    9.0000],...
					   'backgroundcolor',framecolor);
 	y1 = 30.5385; y2 = 23.0770; y3 = 9.6154;				   
	htitle1= uicontrol('style','text','string','Center Point',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   y1   18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	htitle2= uicontrol('style','text','string','Size',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   y2   18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	htitle3= uicontrol('style','text','string','Orientation',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   y3   18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	delta1 = 2.3846; delta2 = 1.9231;				   
	d1 = y1-delta1; d2 = y2-delta1; d3 = y3-delta1;
	hlabel1= uicontrol('style','text','string','Lat',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000  d1   18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	hlabel2= uicontrol('style','text','string','Lon',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   d1-1*delta2   18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	hlabel3= uicontrol('style','text','string','Units',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   d2  18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	hlabel4= uicontrol('style','text','string','Radius',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   d2-1*delta2   18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	hlabel5= uicontrol('style','text','string','Track',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   d2-2*delta2   18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	hlabel6= uicontrol('style','text','string','Arc Width (deg)',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   d2-3*delta2   18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	hlabel7= uicontrol('style','text','string','Npts',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   d2-4*delta2   18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	hlabel8= uicontrol('style','text','string','Starting Angle',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   d3   18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	hlabel9= uicontrol('style','text','string','Center Angle',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   d3-1*delta2  18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	hlabel10=uicontrol('style','text','string','Ending Angle',...
					   'fontweight','bold','horizontalalignment','left',...
					   'units','char','pos',...
					   [2.8000   d3-2*delta2  18.4000    1.0000],...
					   'backgroundcolor',framecolor);
	hbutton1 = uicontrol('style','push','units','char','pos',...
					   [12.0000    0.4615   15.2000    1.3077],...
					   'string','Close','fontweight','bold',...
					   'selectionhighlight','on',...
					   'callback','sectorg(''close'')');
	hedit1 = uicontrol('style','edit','units','char','pos',...
					   [21.0000    d1   13.4000    1.3077],...
					   'fontsize',9,'tag','clat','string','1',...
					   'fontweight','bold',...
					   'callback','sectorg(''clat'')');
	hedit2 = uicontrol('style','edit','units','char','pos',...
					   [21.0000    d1-1*delta2   13.4000    1.3077],...
					   'fontsize',9,'tag','clon','string','2',...
					   'fontweight','bold',...
					   'callback','sectorg(''clon'')');
	hedit3 = uicontrol('style','edit','units','char','pos',...
					   [21.0000    d2-1*delta2   13.4000    1.3077],...
					   'fontsize',9,'tag','rad','string','3',...
					   'fontweight','bold',...
					   'callback','sectorg(''rad'')');
	hedit4 = uicontrol('style','edit','units','char','pos',...
					   [21.0000    d2-3*delta2   13.4000    1.3077],...
					   'fontsize',9,'tag','arcwidth','string','4',...
					   'fontweight','bold',...
					   'callback','sectorg(''arcwidth'')');
	hedit5 = uicontrol('style','edit','units','char','pos',...
					   [21.0000    d2-4*delta2   13.4000    1.3077],...
					   'fontsize',9,'tag','npts','string','5',...
					   'fontweight','bold',...
					   'callback','sectorg(''npts'')');
	hedit6 = uicontrol('style','edit','units','char','pos',...
					   [21.0000    d3   13.4000    1.3077],...
					   'fontsize',9,'tag','startang','string','6',...
					   'fontweight','bold',...
					   'callback','sectorg(''startang'')');
	hedit7 = uicontrol('style','edit','units','char','pos',...
					   [21.0000    d3-1*delta2   13.4000    1.3077],...
					   'fontsize',9,'tag','centerang','string','7',...
					   'fontweight','bold',...
					   'callback','sectorg(''centerang'')');
	hedit8 = uicontrol('style','edit','units','char','pos',...
					   [21.0000    d3-2*delta2   13.4000    1.3077],...
					   'fontsize',9,'tag','endang','string','8',...
					   'fontweight','bold',...
					   'callback','sectorg(''endang'')');
	popstr = {'Kilometers','Miles','Nautical Miles','Radians'};				   
	hpop1 = uicontrol('style','popup','units','char','pos',...
					[14.4000    d2   20.0000    1.3077],...
					'string',popstr,'tag','units','fontsize',9,...
					'fontweight','bold',...
					'callback','sectorg(''units'')');
	popstr = {'Great Circle','Rhumb Line'};				   
	hpop2 = uicontrol('style','popup','units','char','pos',...
					[14.4000    d2-2*delta2   20.0000    1.3077],...
					'string',popstr,'tag','tracktype','fontsize',9,...
					'fontweight','bold',...
					'callback','sectorg(''tracktype'')');
	set(gca,'visible','off')
	%%%%% SEARCH FOR THE OBJECTS %%%%%%
	% sector
	obj = findobj('tag','InteractiveSector');
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hsector = obj(i);
		end
	end	
	% center
	hcenter = findobj('tag','InteractiveSectorCenter');
	obj = hcenter;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = obj(i);
		end
	end
	% resize
	hresize = findobj('tag','InteractiveSectorResize');
	obj = hresize;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hresize = obj(i);
		end
	end
	% radius
	hradius = findobj('tag','InteractiveSectorRadius');
	obj = hradius;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hradius = obj(i);
		end
	end
	% rotate
	hrotate = findobj('tag','InteractiveSectorRotate');
	obj = hrotate;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hrotate = obj(i);
		end
	end
	% center az
	hcaz = findobj('tag','InteractiveSectorCenterAz');
	obj = hcaz;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcaz = obj(i);
		end
	end
	s.parent = get(s.hsector,'parent');
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	% update userdata
	s.hcontrol = h;
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
	set(findobj(h,'tag','clat'),'string',num2str(s.clat));
	set(findobj(h,'tag','clon'),'string',num2str(s.clon));
	set(findobj(h,'tag','arcwidth'),'string',num2str(s.sectorwidth));
	set(findobj(h,'tag','npts'),'string',num2str(s.npts));
	set(findobj(h,'tag','startang'),'string',num2str(s.saz));
	set(findobj(h,'tag','centerang'),'string',num2str(s.caz));
	set(findobj(h,'tag','endang'),'string',num2str(s.eaz));
	% update the values in the objects
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hcontrol,'userdata',s)
	
% mouse down on track
case 'trackdown'
	stype = get(gcf,'selectiontype');
	s = get(gco,'userdata');
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
								case 'sectorcontrol'	
									delete(s.hcontrol)
									s.hcontrol = [];
							end		
						end	
						% delete center
						hcenter = findobj(gca,'tag','InteractiveSectorCenter');
						for i = 1:length(hcenter)
							r = get(hcenter(i),'userdata');
							if r.clat == s.clat & r.num == s.num
								delete(hcenter(i))
							end
						end
						% delete resize
						hresize = findobj(gca,'tag','InteractiveSectorResize');
						for i = 1:length(hresize)
							r = get(hresize(i),'userdata');
							if r.clat == s.clat & r.num == s.num
								delete(hresize(i))
							end
						end
						% delete radius
						hradius = findobj(gca,'tag','InteractiveSectorRadius');
						for i = 1:length(hradius)
							r = get(hradius(i),'userdata');
							if r.clat == s.clat & r.num == s.num
								delete(hradius(i))
							end
						end
						% delete rotate
						hrotate = findobj(gca,'tag','InteractiveSectorRotate');
						for i = 1:length(hrotate)
							r = get(hrotate(i),'userdata');
							if r.clat == s.clat & r.num == s.num
								delete(hrotate(i))
							end
						end
						% delete center azimuth
						hcaz = findobj(gca,'tag','InteractiveSectorCenterAz');
						for i = 1:length(hcaz)
							r = get(hcaz(i),'userdata');
							if r.clat == s.clat & r.num == s.num
								delete(hcaz(i))
							end
						end
						s.hsector = gco;
						s.hcenter = [];
						s.hresize = [];
						s.hradius = [];
						s.hrotate = [];
						s.hcaz = [];
						s.controls = 'off';
						set(gco,'userdata',s)
					case 'off'
						s.controls = 'on';
						s.hsector = gco;
						[cazlat,cazlon] = track2(s.trk,s.clat,s.clon,...
												 s.rlat,s.rlon,[1 0],...
												 'deg',s.npts/3);
						s.hcaz = plotm(cazlat,cazlon,'r--',...
									   'linewidth',2,...
									   'userdata',s,...
									   'tag','InteractiveSectorCenterAz');
						s.hcenter = plotm(s.clat,s.clon,'ro','linewidth',2,...
										  'tag','InteractiveSectorCenter',...
					   				      'markerfacecolor','r',...
 									      'userdata',s,...
										  'buttondownfcn','sectorg(''centerdown'')');	
						s.hresize = plotm(s.slat,s.slon,'rs','linewidth',2,...
										  'tag','InteractiveSectorResize',...
						                  'markerfacecolor','r',...
										  'userdata',s,...
										  'buttondownfcn','sectorg(''resizedown'')');
						s.hradius = plotm(s.rlat,s.rlon,'rv','linewidth',2,...
										  'tag','InteractiveSectorRadius',...
			 						      'markerfacecolor','r',...
										  'userdata',s,...
										  'buttondownfcn','sectorg(''radiusdown'')');
						s.hrotate = plotm(s.elat,s.elon,'rx','linewidth',2,...
										  'tag','InteractiveSectorRotate',...
						                  'markerfacecolor','r',...
										  'userdata',s,...
										  'buttondownfcn','sectorg(''rotatedown'')');
						% display the control window
						sectorg('createcontrols')
						% turn off handle visibility
						hcontrol = findobj('tag','sectorcontrol');
						for i = 1:length(hcontrol)
							r = get(hcontrol(i),'userdata');
							if r.clat == s.clat & r.num == s.num
								s.hcontrol = hcontrol(i);
								set(hcontrol(i),'handlevisibility','off')
							end	
						end	
						% update the data
						set(s.hsector,'userdata',s)
						set(s.hcenter,'userdata',s)
						set(s.hcaz,'userdata',s)
						set(s.hresize,'userdata',s)
						set(s.hradius,'userdata',s)
						set(s.hrotate,'userdata',s)
						set(s.hcontrol,'userdata',s)
				end
	end		

% change the erasemode to xor	
case 'erasexor'
	s = get(gco,'userdata');
	%%%%% SEARCH FOR THE OBJECTS %%%%%%
	% sector
	hsector = findobj('tag','InteractiveSector');
	obj = hsector;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hsector = obj(i);
		end
	end
	% center
	hcenter = findobj('tag','InteractiveSectorCenter');
	obj = hcenter;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = obj(i);
		end
	end
	% resize
	hresize = findobj('tag','InteractiveSectorResize');
	obj = hresize;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hresize = obj(i);
		end
	end
	% radius
	hradius = findobj('tag','InteractiveSectorRadius');
	obj = hradius;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hradius = obj(i);
		end
	end
	% rotate
	hrotate = findobj('tag','InteractiveSectorRotate');
	obj = hrotate;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hrotate = obj(i);
		end
	end
	% center az
	hcaz = findobj('tag','InteractiveSectorCenterAz');
	obj = hcaz;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcaz = obj(i);
		end
	end
	s.parent = get(s.hsector,'parent');	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	% check to see that sector exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Sector No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			objtype = get(s.hcontrol,'tag');
			switch objtype
				case 'sectorcontrol'	
					delete(s.hcontrol)
					s.hcontrol = [];
			end		
		end	
		sectorg('reconstruct')
		return
	end		
	% check to see if other controls exist
	if ~ishandle(s.hcenter) | ~ishandle(s.hresize) | ~ishandle(s.hradius) | ~ishandle(s.hrotate) | ~ishandle(s.hcaz)
		% code from trackui
	    uiwait(errordlg({'One or More Controls No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			objtype = get(s.hcontrol,'tag');
			switch objtype
				case 'sectorcontrol'	
					delete(s.hcontrol)
					s.hcontrol = [];
			end		
		end	
		% delete remaining controls
		if ishandle(s.hcenter); delete(s.hcenter); end
		if ishandle(s.hresize); delete(s.hresize); end
		if ishandle(s.hradius); delete(s.hradius); end
		if ishandle(s.hrotate); delete(s.hrotate); end
		if ishandle(s.hcaz); delete(s.hcaz); end
% 		sectorg('reconstruct')
		return
	end	
	% change erasemodes
	set(s.hsector,'erasemode','xor','userdata',s)
	set(s.hcenter,'erasemode','xor','userdata',s)
	set(s.hcaz,'erasemode','xor','userdata',s)
	set(s.hresize,'erasemode','xor','userdata',s)
	set(s.hradius,'erasemode','xor','userdata',s)
	set(s.hrotate,'erasemode','xor','userdata',s)

	
% mouse down on translation control	
case 'centerdown'	
% 	sectorg('erasexor')
	s = get(gco,'userdata');
	%%%%% SEARCH FOR THE OBJECTS %%%%%%
	% sector
	hsector = findobj('tag','InteractiveSector');
	obj = hsector;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hsector = obj(i);
		end
	end
	% center
	hcenter = findobj('tag','InteractiveSectorCenter');
	obj = hcenter;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = obj(i);
		end
	end
	% resize
	hresize = findobj('tag','InteractiveSectorResize');
	obj = hresize;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hresize = obj(i);
		end
	end
	% radius
	hradius = findobj('tag','InteractiveSectorRadius');
	obj = hradius;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hradius = obj(i);
		end
	end
	% rotate
	hrotate = findobj('tag','InteractiveSectorRotate');
	obj = hrotate;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hrotate = obj(i);
		end
	end
	% center az
	hcaz = findobj('tag','InteractiveSectorCenterAz');
	obj = hcaz;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcaz = obj(i);
		end
	end
	s.parent = get(s.hsector,'parent');	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	% check to see that sector exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Sector No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			objtype = get(s.hcontrol,'tag');
			switch objtype
				case 'sectorcontrol'	
					delete(s.hcontrol)
					s.hcontrol = [];
			end		
		end	
		sectorg('reconstruct')
		return
	end		
	% check to see if other controls exist
	if ~ishandle(s.hcenter) | ~ishandle(s.hresize) | ~ishandle(s.hradius) | ~ishandle(s.hrotate) | ~ishandle(s.hcaz)
		% code from trackui
	    uiwait(errordlg({'One or More Controls No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			objtype = get(s.hcontrol,'tag');
			switch objtype
				case 'sectorcontrol'	
					delete(s.hcontrol)
					s.hcontrol = [];
			end		
		end	
		% delete remaining controls
		if ishandle(s.hcenter); delete(s.hcenter); end
		if ishandle(s.hresize); delete(s.hresize); end
		if ishandle(s.hradius); delete(s.hradius); end
		if ishandle(s.hrotate); delete(s.hrotate); end
		if ishandle(s.hcaz); delete(s.hcaz); end
% 		sectorg('reconstruct')
		return
	end	
	% change erasemodes
	set(s.hsector,'erasemode','xor','userdata',s)
	set(s.hcenter,'erasemode','xor','userdata',s)
	set(s.hcaz,'erasemode','xor','userdata',s)
	set(s.hresize,'erasemode','xor','userdata',s)
	set(s.hradius,'erasemode','xor','userdata',s)
	set(s.hrotate,'erasemode','xor','userdata',s)
	set(gcf,'windowbuttonmotionfcn','sectorg(''centermove'')')
	set(gcf,'windowbuttonupfcn','sectorg(''centerup'')')

% translate sector	
case 'centermove'
	s = get(gco,'userdata');
	% current point
	cpoint = get(gca,'currentpoint');	
	cx = cpoint(1,1);
	cy = cpoint(1,2);
	cz = 0;
	[clat,clon] = minvtran(cx,cy);	
	% update center control point
	set(s.hcenter,'xdata',cx,'ydata',cy,'zdata',cz)
	% update resize control point
	[slat,slon] = reckon(s.trk,clat,clon,s.rad,s.saz); 
	[x,y,z] = mfwdtran(slat,slon,zeros(size(slat))); 
	set(s.hresize,'xdata',x,'ydata',y,'zdata',z)
	% update rotate control point
	[elat,elon] = reckon(s.trk,clat,clon,s.rad,s.eaz);
	[x,y,z] = mfwdtran(elat,elon,zeros(size(elat))); 
	set(s.hrotate,'xdata',x,'ydata',y,'zdata',z)
	% update radius control point
	[rlat,rlon] = reckon(s.trk,clat,clon,s.rad,s.caz);
	[x,y,z] = mfwdtran(rlat,rlon,zeros(size(rlat))); 
	set(s.hradius,'xdata',x,'ydata',y,'zdata',z)
	% update center azimuth
	[cazlat,cazlon] = track2(s.trk,clat,clon,rlat,rlon,[1 0],...
							 'deg',s.npts/3);
	[x,y,z] = mfwdtran(cazlat,cazlon,zeros(size(cazlat))); 
	set(s.hcaz,'xdata',x,'ydata',y,'zdata',z);
	% update sector
	% face 1
	[lat1,lon1] = track2(s.trk,clat,clon,slat,slon,[1 0],...
						 'deg',s.npts/3);
	% face 2
	[lat2,lon2] = scircle1(s.trk,clat,clon,s.rad,[s.saz s.eaz],...
						   [rad2deg(1) 0],'deg',s.npts/3);
	% face 3
	[lat3,lon3] = track2(s.trk,elat,elon,clat,clon,[1 0],...
						 'deg',s.npts/3);
	% plot sector
	mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
	[sectx,secty,sectz,t] = mfwdtran(mat(:,1),mat(:,2),zeros(size(mat(:,1))),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	set(s.hsector,'xdata',sectx,'ydata',secty,'zdata',sectz,'userdata',s)
	% update the userdata
	s.clat = clat; s.clon = clon; s.rlat = rlat; s.rlon = rlon;
	s.slat = slat; s.slon = slon; s.elat = elat; s.elon = elon;
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'	
				% update the units
				switch s.units
					case 'Kilometers'
						set(findobj(s.hcontrol,'tag','units'),'value',1);
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the remaining values					
				set(findobj(s.hcontrol,'tag','clat'),'string',num2str(s.clat));
				set(findobj(s.hcontrol,'tag','clon'),'string',num2str(s.clon));
				set(findobj(s.hcontrol,'tag','arcwidth'),'string',num2str(s.sectorwidth));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
				set(findobj(s.hcontrol,'tag','startang'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','centerang'),'string',num2str(s.caz));
				set(findobj(s.hcontrol,'tag','endang'),'string',num2str(s.eaz));
		end		
	end	

% mouse up from translation control	
case 'centerup'
	s = get(gco,'userdata');
	% current point
	cpoint = get(gca,'currentpoint');	
	cx = cpoint(1,1);
	cy = cpoint(1,2);
	cz = 0;
	[clat,clon] = minvtran(cx,cy);	
	% update center control point
	set(s.hcenter,'xdata',cx,'ydata',cy,'zdata',cz)
	% update resize control point
	[slat,slon] = reckon(s.trk,clat,clon,s.rad,s.saz); 
	[x,y,z] = mfwdtran(slat,slon,zeros(size(slat))); 
	set(s.hresize,'xdata',x,'ydata',y,'zdata',z)
	% update rotate control point
	[elat,elon] = reckon(s.trk,clat,clon,s.rad,s.eaz);
	[x,y,z] = mfwdtran(elat,elon,zeros(size(elat))); 
	set(s.hrotate,'xdata',x,'ydata',y,'zdata',z)
	% update radius control point
	[rlat,rlon] = reckon(s.trk,clat,clon,s.rad,s.caz);
	[x,y,z] = mfwdtran(rlat,rlon,zeros(size(rlat))); 
	set(s.hradius,'xdata',x,'ydata',y,'zdata',z)
	% update center azimuth
	[cazlat,cazlon] = track2(s.trk,clat,clon,rlat,rlon,[1 0],...
							 'deg',s.npts/3);
	[x,y,z] = mfwdtran(cazlat,cazlon,zeros(size(cazlat))); 
	set(s.hcaz,'xdata',x,'ydata',y,'zdata',z);
	% update sector
	% face 1
	[lat1,lon1] = track2(s.trk,clat,clon,slat,slon,[1 0],...
						 'deg',s.npts/3);
	% face 2
	[lat2,lon2] = scircle1(s.trk,clat,clon,s.rad,[s.saz s.eaz],...
						   [rad2deg(1) 0],'deg',s.npts/3);
	% face 3
	[lat3,lon3] = track2(s.trk,elat,elon,clat,clon,[1 0],...
						 'deg',s.npts/3);
	% plot sector
	mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
	[sectx,secty,sectz,t] = mfwdtran(mat(:,1),mat(:,2),zeros(size(mat(:,1))),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	set(s.hsector,'xdata',sectx,'ydata',secty,'zdata',sectz,'userdata',s)
	% update the userdata
	s.clat = clat; s.clon = clon; s.rlat = rlat; s.rlon = rlon;
	s.slat = slat; s.slon = slon; s.elat = elat; s.elon = elon;
	set(s.hsector,'erasemode','normal','userdata',s)
	set(s.hcenter,'erasemode','normal','userdata',s)
	set(s.hcaz,'erasemode','normal','userdata',s)
	set(s.hresize,'erasemode','normal','userdata',s)
	set(s.hradius,'erasemode','normal','userdata',s)
	set(s.hrotate,'erasemode','normal','userdata',s)
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'	
				set(s.hcontrol,'userdata',s)
				% update the units
				switch s.units
					case 'Kilometers'
						set(findobj(s.hcontrol,'tag','units'),'value',1);
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the remaining values					
				set(findobj(s.hcontrol,'tag','clat'),'string',num2str(s.clat));
				set(findobj(s.hcontrol,'tag','clon'),'string',num2str(s.clon));
				set(findobj(s.hcontrol,'tag','arcwidth'),'string',num2str(s.sectorwidth));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
				set(findobj(s.hcontrol,'tag','startang'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','centerang'),'string',num2str(s.caz));
				set(findobj(s.hcontrol,'tag','endang'),'string',num2str(s.eaz));
		end		
	end	
	% restore windowbuttonmotion functions
	set(gcf,'windowbuttonmotionfcn','')
	set(gcf,'windowbuttonupfcn','')
	
% mouse down on arc width selection tool	
case 'resizedown'
% 	sectorg('erasexor')	
	s = get(gco,'userdata');
	%%%%% SEARCH FOR THE OBJECTS %%%%%%
	% sector
	hsector = findobj('tag','InteractiveSector');
	obj = hsector;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hsector = obj(i);
		end
	end
	% center
	hcenter = findobj('tag','InteractiveSectorCenter');
	obj = hcenter;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = obj(i);
		end
	end
	% resize
	hresize = findobj('tag','InteractiveSectorResize');
	obj = hresize;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hresize = obj(i);
		end
	end
	% radius
	hradius = findobj('tag','InteractiveSectorRadius');
	obj = hradius;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hradius = obj(i);
		end
	end
	% rotate
	hrotate = findobj('tag','InteractiveSectorRotate');
	obj = hrotate;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hrotate = obj(i);
		end
	end
	% center az
	hcaz = findobj('tag','InteractiveSectorCenterAz');
	obj = hcaz;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcaz = obj(i);
		end
	end
	s.parent = get(s.hsector,'parent');	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	% check to see that sector exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Sector No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			objtype = get(s.hcontrol,'tag');
			switch objtype
				case 'sectorcontrol'	
					delete(s.hcontrol)
					s.hcontrol = [];
			end		
		end	
		sectorg('reconstruct')
		return
	end		
	% check to see if other controls exist
	if ~ishandle(s.hcenter) | ~ishandle(s.hresize) | ~ishandle(s.hradius) | ~ishandle(s.hrotate) | ~ishandle(s.hcaz)
		% code from trackui
	    uiwait(errordlg({'One or More Controls No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			objtype = get(s.hcontrol,'tag');
			switch objtype
				case 'sectorcontrol'	
					delete(s.hcontrol)
					s.hcontrol = [];
			end		
		end	
		% delete remaining controls
		if ishandle(s.hcenter); delete(s.hcenter); end
		if ishandle(s.hresize); delete(s.hresize); end
		if ishandle(s.hradius); delete(s.hradius); end
		if ishandle(s.hrotate); delete(s.hrotate); end
		if ishandle(s.hcaz); delete(s.hcaz); end
% 		sectorg('reconstruct')
		return
	end	
	% change erasemodes
	set(s.hsector,'erasemode','xor','userdata',s)
	set(s.hcenter,'erasemode','xor','userdata',s)
	set(s.hcaz,'erasemode','xor','userdata',s)
	set(s.hresize,'erasemode','xor','userdata',s)
	set(s.hradius,'erasemode','xor','userdata',s)
	set(s.hrotate,'erasemode','xor','userdata',s)
	set(gcf,'windowbuttonmotionfcn','sectorg(''resizemove'')')
	set(gcf,'windowbuttonupfcn','sectorg(''resizeup'')')

% resize the arc width of the sector	
case 'resizemove'
	s = get(gco,'userdata');
	% current point
	cpoint = get(gca,'currentpoint');	
	cx = cpoint(1,1);
	cy = cpoint(1,2);
	cz = 0;
	[slat,slon] = minvtran(cx,cy); 	
	% update center control point
	[x,y,z] = mfwdtran(s.clat,s.clon,zeros(size(s.clat))); 
	set(s.hcenter,'xdata',x,'ydata',y,'zdata',z)
	% update resize control point
	saz = azimuth(s.trk,s.clat,s.clon,slat,slon); s.saz = saz;
	[slat,slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz);
	s.slat = slat; s.slon = slon;
	[x,y,z] = mfwdtran(s.slat,s.slon,zeros(size(s.slat)));
	set(s.hresize,'xdata',x,'ydata',y,'zdata',z)
	% update rotate control point
	[elat,elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz);
	s.elat = elat; s.elon = elon;
	[x,y,z] = mfwdtran(elat,elon,zeros(size(elat))); 
	set(s.hrotate,'xdata',x,'ydata',y,'zdata',z)
	% sectorwidth
	if s.saz > s.eaz
		s.sectorwidth = (360-s.saz)+s.eaz;
	elseif s.saz <= s.eaz
		s.sectorwidth = s.eaz-s.saz;
	end	
	% center azimuth
	s.caz = s.eaz - s.sectorwidth/2;
	if s.caz < 0; s.caz = s.caz+360; end
	% update radius control point
	[rlat,rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz);
	s.rlat = rlat; s.rlon = rlon;
	[x,y,z] = mfwdtran(rlat,rlon,zeros(size(rlat))); 
	set(s.hradius,'xdata',x,'ydata',y,'zdata',z)
	% update center azimuth
	[cazlat,cazlon] = track2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							 'deg',s.npts/3);
	[x,y,z] = mfwdtran(cazlat,cazlon,zeros(size(cazlat))); 
	set(s.hcaz,'xdata',x,'ydata',y,'zdata',z);
	% update sector
	% face 1
	[lat1,lon1] = track2(s.trk,s.clat,s.clon,s.slat,s.slon,[1 0],...
						 'deg',s.npts/3);
	% face 2
	[lat2,lon2] = scircle1(s.trk,s.clat,s.clon,s.rad,[s.saz s.eaz],...
						   [rad2deg(1) 0],'deg',s.npts/3);
	% face 3
	[lat3,lon3] = track2(s.trk,s.elat,s.elon,s.clat,s.clon,[1 0],...
						 'deg',s.npts/3);
	% plot sector
	mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
	[sectx,secty,sectz,t] = mfwdtran(mat(:,1),mat(:,2),zeros(size(mat(:,1))),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	set(s.hsector,'xdata',sectx,'ydata',secty,'zdata',sectz,'userdata',s)
	% update the userdata
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'	
				% update the units
				switch s.units
					case 'Kilometers'
						set(findobj(s.hcontrol,'tag','units'),'value',1);
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the remaining values					
				set(findobj(s.hcontrol,'tag','clat'),'string',num2str(s.clat));
				set(findobj(s.hcontrol,'tag','clon'),'string',num2str(s.clon));
				set(findobj(s.hcontrol,'tag','arcwidth'),'string',num2str(s.sectorwidth));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
				set(findobj(s.hcontrol,'tag','startang'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','centerang'),'string',num2str(s.caz));
				set(findobj(s.hcontrol,'tag','endang'),'string',num2str(s.eaz));
		end		
	end	
	
% mouse up from arc width selection tool	
case 'resizeup'
	s = get(gco,'userdata');
	% current point
	cpoint = get(gca,'currentpoint');	
	cx = cpoint(1,1);
	cy = cpoint(1,2);
	cz = 0;
	[slat,slon] = minvtran(cx,cy); 	
	% update center control point
	[x,y,z] = mfwdtran(s.clat,s.clon,zeros(size(s.clat))); 
	set(s.hcenter,'xdata',x,'ydata',y,'zdata',z)
	% update resize control point
	saz = azimuth(s.trk,s.clat,s.clon,slat,slon); s.saz = saz;
	[slat,slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz);
	s.slat = slat; s.slon = slon;
	[x,y,z] = mfwdtran(s.slat,s.slon,zeros(size(s.slat)));
	set(s.hresize,'xdata',x,'ydata',y,'zdata',z)
	% update rotate control point
	[elat,elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz);
	s.elat = elat; s.elon = elon;
	[x,y,z] = mfwdtran(elat,elon,zeros(size(elat))); 
	set(s.hrotate,'xdata',x,'ydata',y,'zdata',z)
	% sectorwidth
	if s.saz > s.eaz
		s.sectorwidth = (360-s.saz)+s.eaz;
	elseif s.saz <= s.eaz
		s.sectorwidth = s.eaz-s.saz;
	end	
	% center azimuth
	s.caz = s.eaz - s.sectorwidth/2;
	if s.caz < 0; s.caz = s.caz+360; end
	% update radius control point
	[rlat,rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz);
	s.rlat = rlat; s.rlon = rlon;
	[x,y,z] = mfwdtran(rlat,rlon,zeros(size(rlat))); 
	set(s.hradius,'xdata',x,'ydata',y,'zdata',z)
	% update center azimuth
	[cazlat,cazlon] = track2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							 'deg',s.npts/3);
	[x,y,z] = mfwdtran(cazlat,cazlon,zeros(size(cazlat))); 
	set(s.hcaz,'xdata',x,'ydata',y,'zdata',z);
	% update sector
	% face 1
	[lat1,lon1] = track2(s.trk,s.clat,s.clon,s.slat,s.slon,[1 0],...
						 'deg',s.npts/3);
	% face 2
	[lat2,lon2] = scircle1(s.trk,s.clat,s.clon,s.rad,[s.saz s.eaz],...
						   [rad2deg(1) 0],'deg',s.npts/3);
	% face 3
	[lat3,lon3] = track2(s.trk,s.elat,s.elon,s.clat,s.clon,[1 0],...
						 'deg',s.npts/3);
	% plot sector
	mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
	[sectx,secty,sectz,t] = mfwdtran(mat(:,1),mat(:,2),zeros(size(mat(:,1))),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	set(s.hsector,'xdata',sectx,'ydata',secty,'zdata',sectz,'userdata',s)
	% update the userdata
	set(s.hsector,'userdata',s,'erasemode','normal')
	set(s.hcenter,'userdata',s,'erasemode','normal')
	set(s.hcaz,'userdata',s,'erasemode','normal')
	set(s.hresize,'userdata',s,'erasemode','normal')
	set(s.hradius,'userdata',s,'erasemode','normal')
	set(s.hrotate,'userdata',s,'erasemode','normal')
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'
				set(s.hcontrol,'userdata',s)
				% update the units
				switch s.units
					case 'Kilometers'
						set(findobj(s.hcontrol,'tag','units'),'value',1);
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the remaining values					
				set(findobj(s.hcontrol,'tag','clat'),'string',num2str(s.clat));
				set(findobj(s.hcontrol,'tag','clon'),'string',num2str(s.clon));
				set(findobj(s.hcontrol,'tag','arcwidth'),'string',num2str(s.sectorwidth));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
				set(findobj(s.hcontrol,'tag','startang'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','centerang'),'string',num2str(s.caz));
				set(findobj(s.hcontrol,'tag','endang'),'string',num2str(s.eaz));
		end		
	end	
	% restore windowbuttonmotion functions
	set(gcf,'windowbuttonmotionfcn','')
	set(gcf,'windowbuttonupfcn','')

% mouse down on radius control tool	
case 'radiusdown'
% 	sectorg('erasexor')	
	s = get(gco,'userdata');
	%%%%% SEARCH FOR THE OBJECTS %%%%%%
	% sector
	hsector = findobj('tag','InteractiveSector');
	obj = hsector;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hsector = obj(i);
		end
	end
	% center
	hcenter = findobj('tag','InteractiveSectorCenter');
	obj = hcenter;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = obj(i);
		end
	end
	% resize
	hresize = findobj('tag','InteractiveSectorResize');
	obj = hresize;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hresize = obj(i);
		end
	end
	% radius
	hradius = findobj('tag','InteractiveSectorRadius');
	obj = hradius;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hradius = obj(i);
		end
	end
	% rotate
	hrotate = findobj('tag','InteractiveSectorRotate');
	obj = hrotate;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hrotate = obj(i);
		end
	end
	% center az
	hcaz = findobj('tag','InteractiveSectorCenterAz');
	obj = hcaz;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcaz = obj(i);
		end
	end
	s.parent = get(s.hsector,'parent');	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	% check to see that sector exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Sector No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			objtype = get(s.hcontrol,'tag');
			switch objtype
				case 'sectorcontrol'	
					delete(s.hcontrol)
					s.hcontrol = [];
			end		
		end	
		sectorg('reconstruct')
		return
	end		
	% check to see if other controls exist
	if ~ishandle(s.hcenter) | ~ishandle(s.hresize) | ~ishandle(s.hradius) | ~ishandle(s.hrotate) | ~ishandle(s.hcaz)
		% code from trackui
	    uiwait(errordlg({'One or More Controls No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			objtype = get(s.hcontrol,'tag');
			switch objtype
				case 'sectorcontrol'	
					delete(s.hcontrol)
					s.hcontrol = [];
			end		
		end	
		% delete remaining controls
		if ishandle(s.hcenter); delete(s.hcenter); end
		if ishandle(s.hresize); delete(s.hresize); end
		if ishandle(s.hradius); delete(s.hradius); end
		if ishandle(s.hrotate); delete(s.hrotate); end
		if ishandle(s.hcaz); delete(s.hcaz); end
% 		sectorg('reconstruct')
		return
	end	
	% change erasemodes
	set(s.hsector,'erasemode','xor','userdata',s)
	set(s.hcenter,'erasemode','xor','userdata',s)
	set(s.hcaz,'erasemode','xor','userdata',s)
	set(s.hresize,'erasemode','xor','userdata',s)
	set(s.hradius,'erasemode','xor','userdata',s)
	set(s.hrotate,'erasemode','xor','userdata',s)
	set(gcf,'windowbuttonmotionfcn','sectorg(''radiusmove'')')
	set(gcf,'windowbuttonupfcn','sectorg(''radiusup'')')
	
% resize the arc width of the sector	
case 'radiusmove'
	s = get(gco,'userdata');
	% current point
	cpoint = get(gca,'currentpoint');	
	cx = cpoint(1,1);
	cy = cpoint(1,2);
	cz = 0;
	[rlat,rlon] = minvtran(cx,cy); s.rlat = rlat; s.rlon = rlon;
	% new radius
	s.rad = distance(s.trk,s.clat,s.clon,s.rlat,s.rlon);
	% update center control point
	[x,y,z] = mfwdtran(s.clat,s.clon,zeros(size(s.clat))); 
	set(s.hcenter,'xdata',x,'ydata',y,'zdata',z)
	% update resize control point
	[slat,slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz);
	s.slat = slat; s.slon = slon;
	[x,y,z] = mfwdtran(s.slat,s.slon,zeros(size(s.slat)));
	set(s.hresize,'xdata',x,'ydata',y,'zdata',z)
	% update rotate control point
	[elat,elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz);
	s.elat = elat; s.elon = elon;
	[x,y,z] = mfwdtran(elat,elon,zeros(size(elat))); 
	set(s.hrotate,'xdata',x,'ydata',y,'zdata',z)
	% update radius control point
	[rlat,rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz);
	s.rlat = rlat; s.rlon = rlon;
	[x,y,z] = mfwdtran(s.rlat,s.rlon,zeros(size(s.rlat))); 
	set(s.hradius,'xdata',x,'ydata',y,'zdata',z)
	% update center azimuth
	[cazlat,cazlon] = track2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							 'deg',s.npts/3);
	[x,y,z] = mfwdtran(cazlat,cazlon,zeros(size(cazlat))); 
	set(s.hcaz,'xdata',x,'ydata',y,'zdata',z);
	% update sector
	% face 1
	[lat1,lon1] = track2(s.trk,s.clat,s.clon,s.slat,s.slon,[1 0],...
						 'deg',s.npts/3);
	% face 2
	[lat2,lon2] = scircle1(s.trk,s.clat,s.clon,s.rad,[s.saz s.eaz],...
						   [rad2deg(1) 0],'deg',s.npts/3);
	% face 3
	[lat3,lon3] = track2(s.trk,s.elat,s.elon,s.clat,s.clon,[1 0],...
						 'deg',s.npts/3);
	% plot sector
	mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
	[sectx,secty,sectz,t] = mfwdtran(mat(:,1),mat(:,2),zeros(size(mat(:,1))),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	set(s.hsector,'xdata',sectx,'ydata',secty,'zdata',sectz,'userdata',s)
	% update the userdata
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'	
				% update the units
				switch s.units
					case 'Kilometers'
						set(findobj(s.hcontrol,'tag','units'),'value',1);
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the remaining values					
				set(findobj(s.hcontrol,'tag','clat'),'string',num2str(s.clat));
				set(findobj(s.hcontrol,'tag','clon'),'string',num2str(s.clon));
				set(findobj(s.hcontrol,'tag','arcwidth'),'string',num2str(s.sectorwidth));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
				set(findobj(s.hcontrol,'tag','startang'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','centerang'),'string',num2str(s.caz));
				set(findobj(s.hcontrol,'tag','endang'),'string',num2str(s.eaz));
		end		
	end	

% mouse up from radius control tool		
case 'radiusup'
	s = get(gco,'userdata');
	% current point
	cpoint = get(gca,'currentpoint');	
	cx = cpoint(1,1);
	cy = cpoint(1,2);
	cz = 0;
	[rlat,rlon] = minvtran(cx,cy); s.rlat = rlat; s.rlon = rlon;
	% new radius
	s.rad = distance(s.trk,s.clat,s.clon,s.rlat,s.rlon);
	% update center control point
	[x,y,z] = mfwdtran(s.clat,s.clon,zeros(size(s.clat))); 
	set(s.hcenter,'xdata',x,'ydata',y,'zdata',z)
	% update resize control point
	[slat,slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz);
	s.slat = slat; s.slon = slon;
	[x,y,z] = mfwdtran(s.slat,s.slon,zeros(size(s.slat)));
	set(s.hresize,'xdata',x,'ydata',y,'zdata',z)
	% update rotate control point
	[elat,elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz);
	s.elat = elat; s.elon = elon;
	[x,y,z] = mfwdtran(elat,elon,zeros(size(elat))); 
	set(s.hrotate,'xdata',x,'ydata',y,'zdata',z)
	% update radius control point
	[rlat,rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz);
	s.rlat = rlat; s.rlon = rlon;
	[x,y,z] = mfwdtran(s.rlat,s.rlon,zeros(size(s.rlat))); 
	set(s.hradius,'xdata',x,'ydata',y,'zdata',z)
	% update center azimuth
	[cazlat,cazlon] = track2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							 'deg',s.npts/3);
	[x,y,z] = mfwdtran(cazlat,cazlon,zeros(size(cazlat))); 
	set(s.hcaz,'xdata',x,'ydata',y,'zdata',z);
	% update sector
	% face 1
	[lat1,lon1] = track2(s.trk,s.clat,s.clon,s.slat,s.slon,[1 0],...
						 'deg',s.npts/3);
	% face 2
	[lat2,lon2] = scircle1(s.trk,s.clat,s.clon,s.rad,[s.saz s.eaz],...
						   [rad2deg(1) 0],'deg',s.npts/3);
	% face 3
	[lat3,lon3] = track2(s.trk,s.elat,s.elon,s.clat,s.clon,[1 0],...
						 'deg',s.npts/3);
	% plot sector
	mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
	[sectx,secty,sectz,t] = mfwdtran(mat(:,1),mat(:,2),zeros(size(mat(:,1))),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	set(s.hsector,'xdata',sectx,'ydata',secty,'zdata',sectz,'userdata',s)
	% update the userdata
	set(s.hsector,'userdata',s,'erasemode','normal')
	set(s.hcenter,'userdata',s,'erasemode','normal')
	set(s.hcaz,'userdata',s,'erasemode','normal')
	set(s.hresize,'userdata',s,'erasemode','normal')
	set(s.hradius,'userdata',s,'erasemode','normal')
	set(s.hrotate,'userdata',s,'erasemode','normal')
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'	
				set(s.hcontrol,'userdata',s)
				% update the units
				switch s.units
					case 'Kilometers'
						set(findobj(s.hcontrol,'tag','units'),'value',1);
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the remaining values					
				set(findobj(s.hcontrol,'tag','clat'),'string',num2str(s.clat));
				set(findobj(s.hcontrol,'tag','clon'),'string',num2str(s.clon));
				set(findobj(s.hcontrol,'tag','arcwidth'),'string',num2str(s.sectorwidth));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
				set(findobj(s.hcontrol,'tag','startang'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','centerang'),'string',num2str(s.caz));
				set(findobj(s.hcontrol,'tag','endang'),'string',num2str(s.eaz));
		end		
	end	
	% restore windowbuttonmotion functions
	set(gcf,'windowbuttonmotionfcn','')
	set(gcf,'windowbuttonupfcn','')

% mouse down on rotation control tool	
case 'rotatedown'
% 	sectorg('erasexor')	
	s = get(gco,'userdata');
	%%%%% SEARCH FOR THE OBJECTS %%%%%%
	% sector
	hsector = findobj('tag','InteractiveSector');
	obj = hsector;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hsector = obj(i);
		end
	end
	% center
	hcenter = findobj('tag','InteractiveSectorCenter');
	obj = hcenter;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = obj(i);
		end
	end
	% resize
	hresize = findobj('tag','InteractiveSectorResize');
	obj = hresize;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hresize = obj(i);
		end
	end
	% radius
	hradius = findobj('tag','InteractiveSectorRadius');
	obj = hradius;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hradius = obj(i);
		end
	end
	% rotate
	hrotate = findobj('tag','InteractiveSectorRotate');
	obj = hrotate;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hrotate = obj(i);
		end
	end
	% center az
	hcaz = findobj('tag','InteractiveSectorCenterAz');
	obj = hcaz;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcaz = obj(i);
		end
	end
	s.parent = get(s.hsector,'parent');	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	% check to see that sector exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Sector No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			objtype = get(s.hcontrol,'tag');
			switch objtype
				case 'sectorcontrol'	
					delete(s.hcontrol)
					s.hcontrol = [];
			end		
		end	
		sectorg('reconstruct')
		return
	end		
	% check to see if other controls exist
	if ~ishandle(s.hcenter) | ~ishandle(s.hresize) | ~ishandle(s.hradius) | ~ishandle(s.hrotate) | ~ishandle(s.hcaz)
		% code from trackui
	    uiwait(errordlg({'One or More Controls No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			objtype = get(s.hcontrol,'tag');
			switch objtype
				case 'sectorcontrol'	
					delete(s.hcontrol)
					s.hcontrol = [];
			end		
		end	
		% delete remaining controls
		if ishandle(s.hcenter); delete(s.hcenter); end
		if ishandle(s.hresize); delete(s.hresize); end
		if ishandle(s.hradius); delete(s.hradius); end
		if ishandle(s.hrotate); delete(s.hrotate); end
		if ishandle(s.hcaz); delete(s.hcaz); end
% 		sectorg('reconstruct')
		return
	end	
	% change erasemodes
	set(s.hsector,'erasemode','xor','userdata',s)
	set(s.hcenter,'erasemode','xor','userdata',s)
	set(s.hcaz,'erasemode','xor','userdata',s)
	set(s.hresize,'erasemode','xor','userdata',s)
	set(s.hradius,'erasemode','xor','userdata',s)
	set(s.hrotate,'erasemode','xor','userdata',s)
	set(gcf,'windowbuttonmotionfcn','sectorg(''rotatemove'')')
	set(gcf,'windowbuttonupfcn','sectorg(''rotateup'')')
	
% rotate the sector	
case 'rotatemove'
	s = get(gco,'userdata');
	% current point
	cpoint = get(gca,'currentpoint');	
	cx = cpoint(1,1);
	cy = cpoint(1,2);
	cz = 0;
	[elat,elon] = minvtran(cx,cy); 
	% compute required azimuths
	s.eaz = azimuth(s.trk,s.clat,s.clon,elat,elon);
	s.caz = zero22pi(s.eaz-s.sectorwidth/2);
	s.saz = zero22pi(s.caz-s.sectorwidth/2);
	% update center control point
	[x,y,z] = mfwdtran(s.clat,s.clon,zeros(size(s.clat))); 
	set(s.hcenter,'xdata',x,'ydata',y,'zdata',z)
	% update resize control point
	[slat,slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz);
	s.slat = slat; s.slon = slon;
	[x,y,z] = mfwdtran(s.slat,s.slon,zeros(size(s.slat)));
	set(s.hresize,'xdata',x,'ydata',y,'zdata',z)
	% update rotate control point
	[elat,elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz);
	s.elat = elat; s.elon = elon;
	[x,y,z] = mfwdtran(elat,elon,zeros(size(elat))); 
	set(s.hrotate,'xdata',x,'ydata',y,'zdata',z)
	% update radius control point
	[rlat,rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz);
	s.rlat = rlat; s.rlon = rlon;
	[x,y,z] = mfwdtran(s.rlat,s.rlon,zeros(size(s.rlat))); 
	set(s.hradius,'xdata',x,'ydata',y,'zdata',z)
	% update center azimuth
	[cazlat,cazlon] = track2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							 'deg',s.npts/3);
	[x,y,z] = mfwdtran(cazlat,cazlon,zeros(size(cazlat))); 
	set(s.hcaz,'xdata',x,'ydata',y,'zdata',z);
	% update sector
	% face 1
	[lat1,lon1] = track2(s.trk,s.clat,s.clon,s.slat,s.slon,[1 0],...
						 'deg',s.npts/3);
	% face 2
	[lat2,lon2] = scircle1(s.trk,s.clat,s.clon,s.rad,[s.saz s.eaz],...
						   [rad2deg(1) 0],'deg',s.npts/3);
	% face 3
	[lat3,lon3] = track2(s.trk,s.elat,s.elon,s.clat,s.clon,[1 0],...
						 'deg',s.npts/3);
	% plot sector
	mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
	[sectx,secty,sectz,t] = mfwdtran(mat(:,1),mat(:,2),zeros(size(mat(:,1))),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	set(s.hsector,'xdata',sectx,'ydata',secty,'zdata',sectz,'userdata',s)
	% update the userdata
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'	
				% update the units
				switch s.units
					case 'Kilometers'
						set(findobj(s.hcontrol,'tag','units'),'value',1);
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the remaining values					
				set(findobj(s.hcontrol,'tag','clat'),'string',num2str(s.clat));
				set(findobj(s.hcontrol,'tag','clon'),'string',num2str(s.clon));
				set(findobj(s.hcontrol,'tag','arcwidth'),'string',num2str(s.sectorwidth));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
				set(findobj(s.hcontrol,'tag','startang'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','centerang'),'string',num2str(s.caz));
				set(findobj(s.hcontrol,'tag','endang'),'string',num2str(s.eaz));
		end		
	end	

% mouse up on rotation control tool	
case 'rotateup'
	s = get(gco,'userdata');
	% current point
	cpoint = get(gca,'currentpoint');	
	cx = cpoint(1,1);
	cy = cpoint(1,2);
	cz = 0;
	[elat,elon] = minvtran(cx,cy); 
	% compute required azimuths
	s.eaz = azimuth(s.trk,s.clat,s.clon,elat,elon);
	s.caz = zero22pi(s.eaz-s.sectorwidth/2);
	s.saz = zero22pi(s.caz-s.sectorwidth/2);
	% update center control point
	[x,y,z] = mfwdtran(s.clat,s.clon,zeros(size(s.clat))); 
	set(s.hcenter,'xdata',x,'ydata',y,'zdata',z)
	% update resize control point
	[slat,slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz);
	s.slat = slat; s.slon = slon;
	[x,y,z] = mfwdtran(s.slat,s.slon,zeros(size(s.slat)));
	set(s.hresize,'xdata',x,'ydata',y,'zdata',z)
	% update rotate control point
	[elat,elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz);
	s.elat = elat; s.elon = elon;
	[x,y,z] = mfwdtran(elat,elon,zeros(size(elat))); 
	set(s.hrotate,'xdata',x,'ydata',y,'zdata',z)
	% update radius control point
	[rlat,rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz);
	s.rlat = rlat; s.rlon = rlon;
	[x,y,z] = mfwdtran(s.rlat,s.rlon,zeros(size(s.rlat))); 
	set(s.hradius,'xdata',x,'ydata',y,'zdata',z)
	% update center azimuth
	[cazlat,cazlon] = track2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							 'deg',s.npts/3);
	[x,y,z] = mfwdtran(cazlat,cazlon,zeros(size(cazlat))); 
	set(s.hcaz,'xdata',x,'ydata',y,'zdata',z);
	% update sector
	% face 1
	[lat1,lon1] = track2(s.trk,s.clat,s.clon,s.slat,s.slon,[1 0],...
						 'deg',s.npts/3);
	% face 2
	[lat2,lon2] = scircle1(s.trk,s.clat,s.clon,s.rad,[s.saz s.eaz],...
						   [rad2deg(1) 0],'deg',s.npts/3);
	% face 3
	[lat3,lon3] = track2(s.trk,s.elat,s.elon,s.clat,s.clon,[1 0],...
						 'deg',s.npts/3);
	% plot sector
	mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
	[sectx,secty,sectz,t] = mfwdtran(mat(:,1),mat(:,2),zeros(size(mat(:,1))),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	set(s.hsector,'xdata',sectx,'ydata',secty,'zdata',sectz,'userdata',s)
	% update the userdata
	set(s.hsector,'userdata',s,'erasemode','normal')
	set(s.hcenter,'userdata',s,'erasemode','normal')
	set(s.hcaz,'userdata',s,'erasemode','normal')
	set(s.hresize,'userdata',s,'erasemode','normal')
	set(s.hradius,'userdata',s,'erasemode','normal')
	set(s.hrotate,'userdata',s,'erasemode','normal')
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'
				set(s.hcontrol,'userdata',s)
				% update the units
				switch s.units
					case 'Kilometers'
						set(findobj(s.hcontrol,'tag','units'),'value',1);
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the remaining values					
				set(findobj(s.hcontrol,'tag','clat'),'string',num2str(s.clat));
				set(findobj(s.hcontrol,'tag','clon'),'string',num2str(s.clon));
				set(findobj(s.hcontrol,'tag','arcwidth'),'string',num2str(s.sectorwidth));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
				set(findobj(s.hcontrol,'tag','startang'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','centerang'),'string',num2str(s.caz));
				set(findobj(s.hcontrol,'tag','endang'),'string',num2str(s.eaz));
		end		
	end	
	% restore windowbuttonmotion functions
	set(gcf,'windowbuttonmotionfcn','')
	set(gcf,'windowbuttonupfcn','')

% update the sector	
case 'updatesector'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	%%%%% SEARCH FOR THE OBJECTS %%%%%%
	% sector
	hsector = findobj('tag','InteractiveSector');
	obj = hsector;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hsector = obj(i);
		end
	end
	% center
	hcenter = findobj('tag','InteractiveSectorCenter');
	obj = hcenter;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = obj(i);
		end
	end
	% resize
	hresize = findobj('tag','InteractiveSectorResize');
	obj = hresize;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hresize = obj(i);
		end
	end
	% radius
	hradius = findobj('tag','InteractiveSectorRadius');
	obj = hradius;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hradius = obj(i);
		end
	end
	% rotate
	hrotate = findobj('tag','InteractiveSectorRotate');
	obj = hrotate;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hrotate = obj(i);
		end
	end
	% center az
	hcaz = findobj('tag','InteractiveSectorCenterAz');
	obj = hcaz;
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcaz = obj(i);
		end
	end
	s.parent = get(s.hsector,'parent');
	axes(s.parent)	
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%	
	% check to see that sector exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Sector No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			delete(s.hcontrol)
		end	
		sectorg('reconstruct')
		return
	end		
	% check to see if other controls exist
	if ~ishandle(s.hcenter) | ~ishandle(s.hresize) | ~ishandle(s.hradius) | ~ishandle(s.hrotate) | ~ishandle(s.hcaz)
		% code from trackui
	    uiwait(errordlg({'One or More Controls No Longer Exists',' ',...
						     'Extend Click on Sector Again to Drag'},...
							  'Control Point Error','modal'));
		% kill the control window if it exists
		if ishandle(s.hcontrol)
			delete(s.hcontrol)
		end	
		% delete remaining controls
		if ishandle(s.hcenter); delete(s.hcenter); end
		if ishandle(s.hresize); delete(s.hresize); end
		if ishandle(s.hradius); delete(s.hradius); end
		if ishandle(s.hrotate); delete(s.hrotate); end
		if ishandle(s.hcaz); delete(s.hcaz); end
		return
	end	
	% update center control point
	[x,y,z] = mfwdtran(s.clat,s.clon,zeros(size(s.clat))); 
	set(s.hcenter,'xdata',x,'ydata',y,'zdata',z)
	% update resize control point
	[x,y,z] = mfwdtran(s.slat,s.slon,zeros(size(s.slat)));
	set(s.hresize,'xdata',x,'ydata',y,'zdata',z)
	% update rotate control point
	[x,y,z] = mfwdtran(s.elat,s.elon,zeros(size(s.elat))); 
	set(s.hrotate,'xdata',x,'ydata',y,'zdata',z)
	% update radius control point
	[x,y,z] = mfwdtran(s.rlat,s.rlon,zeros(size(s.rlat))); 
	set(s.hradius,'xdata',x,'ydata',y,'zdata',z)
	% update center azimuth
	[cazlat,cazlon] = track2(s.trk,s.clat,s.clon,s.rlat,s.rlon,[1 0],...
							 'deg',s.npts/3);
	[x,y,z] = mfwdtran(cazlat,cazlon,zeros(size(cazlat))); 
	set(s.hcaz,'xdata',x,'ydata',y,'zdata',z);
	% update sector
	% face 1
	[lat1,lon1] = track2(s.trk,s.clat,s.clon,s.slat,s.slon,[1 0],...
						 'deg',s.npts/3);
	% face 2
	[lat2,lon2] = scircle1(s.trk,s.clat,s.clon,s.rad,[s.saz s.eaz],...
						   [rad2deg(1) 0],'deg',s.npts/3);
	% face 3
	[lat3,lon3] = track2(s.trk,s.elat,s.elon,s.clat,s.clon,[1 0],...
						 'deg',s.npts/3);
	% plot sector
	mat = [lat1(:) lon1(:); lat2(:) lon2(:); lat3(:) lon3(:)];
	[sectx,secty,sectz,t] = mfwdtran(mat(:,1),mat(:,2),zeros(size(mat(:,1))),'line');
	s.clipped = t.clipped;
	s.trimmed = t.trimmed;
	set(s.hsector,'xdata',sectx,'ydata',secty,'zdata',sectz,'userdata',s)
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'
				set(s.hcontrol,'userdata',s)
				% update the units
				switch s.units
					case 'Kilometers'
						set(findobj(s.hcontrol,'tag','units'),'value',1);
						dist = distdim(s.rad,'deg','km');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Miles'          
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','mi');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Nautical Miles' 
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','nm');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
					case 'Radians'        
						set(findobj(s.hcontrol,'tag','units'),'value',2);
						dist = distdim(s.rad,'deg','rad');
						set(findobj(s.hcontrol,'tag','rad'),'string',num2str(dist));
				end		
				% update the remaining values					
				set(findobj(s.hcontrol,'tag','clat'),'string',num2str(s.clat));
				set(findobj(s.hcontrol,'tag','clon'),'string',num2str(s.clon));
				set(findobj(s.hcontrol,'tag','arcwidth'),'string',num2str(s.sectorwidth));
				set(findobj(s.hcontrol,'tag','npts'),'string',num2str(s.npts));
				set(findobj(s.hcontrol,'tag','startang'),'string',num2str(s.saz));
				set(findobj(s.hcontrol,'tag','centerang'),'string',num2str(s.caz));
				set(findobj(s.hcontrol,'tag','endang'),'string',num2str(s.eaz));
		end		
	end	

% change center latitude	
case 'clat'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	clat = str2num(get(gcbo,'string'));
	% return original string if user enters incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.clat))
		return
	end	
	% return original string if incorrect value entered for latitude
	if str2num(get(gcbo,'string')) > 90 | str2num(get(gcbo,'string')) < -90
		set(gcbo,'string',num2str(s.clat))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Sector Tool No Longer Appropriate'},...
							  'Sector Tool Error','modal'));
	    sectorg('close');
		return
	end
	s.clat = clat;
	% update resize control point
	[slat,slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz);
	s.slat = slat; s.slon = slon;
	% update rotate control point
	[elat,elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz);
	s.elat = elat; s.elon = elon;
	% update radius control point
	[rlat,rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz);
	s.rlat = rlat; s.rlon = rlon;
	% save the data
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	set(s.hcontrol,'userdata',s)	
	% update the sector
	sectorg('updatesector')

% change center longitude	
case 'clon'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	clon = str2num(get(gcbo,'string'));
	% return original string if user enters incorrect data type
	if isempty(str2num(get(gcbo,'string')))
		set(gcbo,'string',num2str(s.clon))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Sector Tool No Longer Appropriate'},...
							  'Sector Tool Error','modal'));
	    sectorg('close');
		return
	end
	s.clon = clon;
	% update resize control point
	[slat,slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz);
	s.slat = slat; s.slon = slon;
	% update rotate control point
	[elat,elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz);
	s.elat = elat; s.elon = elon;
	% update radius control point
	[rlat,rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz);
	s.rlat = rlat; s.rlon = rlon;
	% save the data
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	set(s.hcontrol,'userdata',s)	
	% update the sector
	sectorg('updatesector')

% change the units	
case 'units'	
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	s.units = popupstr(gcbo);
	% check to see if track exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Sector Tool No Longer Appropriate'},...
							  'Sector Tool Error','modal'));
	    sectorg('close');
		return
	end
	% save the data
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	% update the data in the control window if it exists
	if ishandle(s.hcontrol)
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'
				set(s.hcontrol,'userdata',s)
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
	end			

% change the radius	
case 'rad'	
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	rad = str2num(get(gcbo,'string'));
	% return original string if user enters incorrect data type
	if isempty(str2num(get(gcbo,'string'))) | str2num(get(gcbo,'string')) <=0
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
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Sector Tool No Longer Appropriate'},...
							  'Sector Tool Error','modal'));
	    sectorg('close');
		return
	end
	% get the units in degrees
	switch s.units
		case 'Kilometers'
			dist = distdim(rad,'km','deg');
		case 'Miles'          
			dist = distdim(rad,'mi','deg');
		case 'Nautical Miles' 
			dist = distdim(rad,'nm','deg');
		case 'Radians'        
			dist = distdim(rad,'rad','deg');
	end	
	s.rad = dist;
	% update resize control point
	[slat,slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz);
	s.slat = slat; s.slon = slon;
	% update rotate control point
	[elat,elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz);
	s.elat = elat; s.elon = elon;
	% update radius control point
	[rlat,rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz);
	s.rlat = rlat; s.rlon = rlon;
	% save the data
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	set(s.hcontrol,'userdata',s)	
	% update the sector
	sectorg('updatesector')

% change the tracktype	
case 'tracktype'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% update changes
	tracktype = popupstr(gcbo);
	% update track type
	switch tracktype
		case 'Great Circle'
			s.trk = 'gc';
		case 'Rhumb Line'
			s.trk = 'rh';
	end
	% check to see if track exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Sector Tool No Longer Appropriate'},...
							  'Sector Tool Error','modal'));
	    sectorg('close');
		return
	end
	% update the locations of the control points
	[slat,slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz);
	s.slat = slat; s.slon = slon;
	[elat,elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz);
	s.elat = elat; s.elon = elon;
	% save the data
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	set(s.hcontrol,'userdata',s)	
	% update the sector
	sectorg('updatesector')
	
% change the arc width
case 'arcwidth'
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user enters incorrect data type
	if isempty(str2num(get(gcbo,'string'))) | str2num(get(gcbo,'string')) <=0 | str2num(get(gcbo,'string')) > 360
		set(gcbo,'string',num2str(s.sectorwidth))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Sector Tool No Longer Appropriate'},...
							  'Sector Tool Error','modal'));
	    sectorg('close');
		return
	end
	sectorwidth = str2num(get(gcbo,'string'));
	s.sectorwidth = sectorwidth;
	s.saz = zero22pi(s.caz-s.sectorwidth/2); % starting azimuth
	s.eaz = zero22pi(s.caz+s.sectorwidth/2); % ending azimuth
	[s.slat,s.slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz); % starting point
	[s.elat,s.elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz); % ending point
	s.azlimits = [s.saz s.eaz]; % azimuth limits
	% save the data
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	set(s.hcontrol,'userdata',s)	
	% update the sector
	sectorg('updatesector')

% number of control points	
case 'npts'	
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user enters incorrect data type
	if isempty(str2num(get(gcbo,'string'))) | str2num(get(gcbo,'string')) <9 
		set(gcbo,'string',num2str(s.npts))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Sector Tool No Longer Appropriate'},...
							  'Sector Tool Error','modal'));
	    sectorg('close');
		return
	end
	npts = str2num(get(gcbo,'string'));
	multfact = ceil(npts/3);
	s.npts = 3*multfact;
	% save the data
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	set(s.hcontrol,'userdata',s)	
	% update the sector
	sectorg('updatesector')

% change the starting angle	
case 'startang'	
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user enters incorrect data type
	if isempty(str2num(get(gcbo,'string'))) | str2num(get(gcbo,'string')) <0 | str2num(get(gcbo,'string')) >360
		set(gcbo,'string',num2str(s.saz))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Sector Tool No Longer Appropriate'},...
							  'Sector Tool Error','modal'));
	    sectorg('close');
		return
	end
	saz = str2num(get(gcbo,'string'));
	eaz = zero22pi(saz+s.sectorwidth);
	caz = zero22pi(saz+s.sectorwidth/2);
	s.saz = saz; s.eaz = eaz; s.caz = caz;
	[s.rlat,s.rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz); % center point
	[s.slat,s.slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz); % starting point
	[s.elat,s.elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz); % ending point
	s.azlimits = [s.saz s.eaz]; % azimuth limits
	% save the data
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	set(s.hcontrol,'userdata',s)	
	% update the sector
	sectorg('updatesector')

% change the center angle	
case 'centerang'	
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user enters incorrect data type
	if isempty(str2num(get(gcbo,'string'))) | str2num(get(gcbo,'string')) <0 | str2num(get(gcbo,'string')) >360
		set(gcbo,'string',num2str(s.caz))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Sector Tool No Longer Appropriate'},...
							  'Sector Tool Error','modal'));
	    sectorg('close');
		return
	end
	caz = str2num(get(gcbo,'string'));
	saz = zero22pi(caz-s.sectorwidth/2);
	eaz = zero22pi(caz+s.sectorwidth/2);
	s.saz = saz; s.eaz = eaz; s.caz = caz;
	[s.rlat,s.rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz); % center point
	[s.slat,s.slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz); % starting point
	[s.elat,s.elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz); % ending point
	s.azlimits = [s.saz s.eaz]; % azimuth limits
	% save the data
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	set(s.hcontrol,'userdata',s)	
	% update the sector
	sectorg('updatesector')

% change the ending angle	
case 'endang'	
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% return original string if user enters incorrect data type
	if isempty(str2num(get(gcbo,'string'))) | str2num(get(gcbo,'string')) <0 | str2num(get(gcbo,'string')) >360
		set(gcbo,'string',num2str(s.eaz))
		return
	end	
	% check to see if track exists
	if ~ishandle(s.hsector)
		% code from trackui
	    uiwait(errordlg({'Associated Map Axes has been deleted',' ',...
						     'Sector Tool No Longer Appropriate'},...
							  'Sector Tool Error','modal'));
	    sectorg('close');
		return
	end
	eaz = str2num(get(gcbo,'string'));
	saz = zero22pi(eaz-s.sectorwidth);
	caz = zero22pi(eaz-s.sectorwidth/2);
	s.saz = saz; s.eaz = eaz; s.caz = caz;
	[s.rlat,s.rlon] = reckon(s.trk,s.clat,s.clon,s.rad,s.caz); % center point
	[s.slat,s.slon] = reckon(s.trk,s.clat,s.clon,s.rad,s.saz); % starting point
	[s.elat,s.elon] = reckon(s.trk,s.clat,s.clon,s.rad,s.eaz); % ending point
	s.azlimits = [s.saz s.eaz]; % azimuth limits
	% save the data
	set(s.hsector,'userdata',s)
	set(s.hcenter,'userdata',s)
	set(s.hcaz,'userdata',s)
	set(s.hresize,'userdata',s)
	set(s.hradius,'userdata',s)
	set(s.hrotate,'userdata',s)
	set(s.hcontrol,'userdata',s)	
	% update the sector
	sectorg('updatesector')

% close the control window and kill the controls	
case 'close'	
	par = get(gcbo,'parent');
	s = get(par,'userdata');
	% sector
	obj = findobj('tag','InteractiveSector');
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hsector = obj(i);
		end
	end
	% center
	obj = findobj('tag','InteractiveSectorCenter');
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcenter = obj(i);
		end
	end
	% center azimuth
	obj = findobj('tag','InteractiveSectorCenterAz');
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hcaz = obj(i);
		end
	end
	% resize
	obj = findobj('tag','InteractiveSectorResize');
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hresize = obj(i);
		end
	end
	% radius
	obj = findobj('tag','InteractiveSectorRadius');
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hradius = obj(i);
		end
	end
	% rotate
	obj = findobj('tag','InteractiveSectorRotate');
	for i = 1:length(obj)
		r = get(obj(i),'userdata');
		if r.clat == s.clat & r.num == s.num
			s.hrotate = obj(i);
		end
	end
	try
        s.parent = get(s.hsector,'userdata');	
    catch
    end
	% delete the objects
	if ishandle(s.hcenter); delete(s.hcenter); end
	if ishandle(s.hresize); delete(s.hresize); end
	if ishandle(s.hradius); delete(s.hradius); end
	if ishandle(s.hrotate); delete(s.hrotate); end
	if ishandle(s.hcaz); delete(s.hcaz); end
	if ishandle(s.hcontrol); 
		objtype = get(s.hcontrol,'tag');
		switch objtype
			case 'sectorcontrol'	
				delete(s.hcontrol); 
		end
	end
	s.controls = 'off';
	s.hcenter = [];
	s.hresize = [];
	s.hradius = [];
	s.hrotate = [];
	s.hcaz = [];
	if ishandle(s.hsector);
		set(s.hsector,'userdata',s)	
	end	
end		
	

