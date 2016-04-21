function hout = northarrow(varargin)

%NORTHARROW add graphic element pointing to the geographic North Pole
% 
%   NORTHARROW creates a north arrow symbol at the map origin on the
%   displayed map.  The north arrow symbol can be repositioned by clicking
%   and dragging its icon.  Alternate clicking on the icon creates an 
%   input dialog box that can be also to change the location of the north
%   arrow.
%
%   NORTHARROW('property',value,...) creates a north arrow using the 
%   specified property-value pairs.  Valid entries for properties are
%   'latitude', 'longitude', 'facecolor', 'edgecolor', 'linewidth', and 
%   'scaleratio'.  The 'latitude' and 'longitude' properties specify the 
%   location of the north arrow.  The 'facecolor', 'edgecolor', and 'linewidth'
%   properties control the appearance of the north arrow.  The 'scaleratio'
%   property represents the size of the north arrow as a fraction of the 
%   size of the axes.  A 'scaleratio' value of 0.10 will create a north arrow
%   one-tenth (1/10) the size of the axes.  The appearance ('facecolor',
%   'edgecolor', and 'linewidth') of the north arrow can be changed using the
%   SET command.  
%
%   Modifying some of the properties of the north arrow will result in 
%   replacement of the original object.  Use HANDLEM('NorthArrow') to get the 
%   handles associated with the north arrow.
%
%   LIMITATIONS:  Multiple north arrows may be drawn on the map.  However,
%   the callbacks will only work with the most recently created north arrow.
%   In addition, since it can be displayed outside the map frame limits, 
%   the north arrow is not converted into a 'mapped' object.  Hence, the
%   location and orientation of the north arrow has to be updated manually
%   if the map origin or projection is changed.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.2.4.1 $  $Date: 2003/08/01 18:19:05 $

%  Written by: L. Job


% check if a valid map axes is open
hndl = get(get(0,'CurrentFigure'),'CurrentAxes');
if isempty(hndl);  error('No axes in current figure');  end

if ~ismap(gca)
    error('Not a map axes. Select a map axes or use AXESM to define one.')
end

% check to make sure that the map projection and axes view are 2-D 
mapproj = getm(gca,'mapprojection');
switch mapproj
case 'globe'
    error('NORTH ARROW only works on 2-D map projections.')
otherwise
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
end

switch nargin
case 0
    
    % 1st time through with no inputs
	origin = getm(gca,'origin');
	x = mean(xlim);
	y = mean(ylim);
	[s.lat,s.lon ] = minvtran(x,y);
	s.action = 'initialize';
	s.facecolor = [0 0 0];
	s.edgecolor = [0 0 0];
	s.linewidth = 1;
	s.scaleratio = 0.1;
	s = scalefactor(s);
	setApplicationData(s)
	constructSymbol(s)
    
case 1
    
    % execute callbacks
	action = varargin{1};
	appdata = getappdata(gcf,'appdata');
	s = appdata.s;
	s.action = action;
	setappdata(gcf,'appdata',appdata);
    
otherwise
    
    % 1st time through with inputs
	% default values
	origin = getm(gca,'origin');
	x = mean(xlim);
	y = mean(ylim);
	[s.lat,s.lon ] = minvtran(x,y);
	s.action = 'initialize';
	s.facecolor = [0 0 0];
	s.edgecolor = [0 0 0];
	s.linewidth = 1;
	s.scaleratio = 0.1;
	
	% fill in values
	if mod(nargin,2) ~= 0
		error('Property-Value Pairs Required')
	end
	parameters = {'latitude','longitude','facecolor','edgecolor','linewidth','scaleratio'};
	for i = 1:2:nargin
		prop = varargin{i};
		val = varargin{i+1};
		indx = stringMatch(prop,parameters); prop = parameters{indx};
		switch prop
		case 'latitude',    s.lat = val;
        case 'longitude',   s.lon = val;
        case 'facecolor',   s.facecolor = val;
        case 'edgecolor',   s.edgecolor = val;
        case 'linewidth',   s.linewidth = val;
        case 'scaleratio',  s.scaleratio = val;
		end
	end
    
	s = scalefactor(s);
	setApplicationData(s)
	constructSymbol(s)
    
end

switch s.action
case 'initialize'
    
    appdata = getappdata(gcf,'appdata');
    a = appdata.a;
    p = appdata.p;
    ns = appdata.ns;
    s = appdata.s;
    
	% convert the data to cartesian coordinates so that we can plot them outside the
	% frame also and add a color patch to the arrow
	
	x = [a.x nan ns.x nan];
	y = [a.y nan ns.y nan];
	
	% color properties
	ecolor = [0 0 0];
	lwidth = 1;
	fcolor = 'm';
	h1 = patch(x,y,'c','linewidth',s.linewidth,'edgecolor',s.edgecolor,'facecolor',s.facecolor,...
        'tag','NorthArrow');
	
	% fill in arrow body with specified fill color
	nanindx = find(isnan(x));
	ax = x(1:nanindx(1)-1);
	ay = y(1:nanindx(1)-1);
	h2 = patch(ax,ay,'c','linewidth',s.linewidth,'edgecolor',s.edgecolor,'facecolor',s.facecolor,...
        'tag','NorthArrow');

    moveArrowToTop([h1 h2])
    s.action = 'mousedown';
    
    % save application data in object
    appdata.a = a;
    appdata.p = p;
    appdata.ns = ns;
    appdata.s = s;
    appdata.h = [h1 h2];
    h = findobj(gcf,'Tag','NorthArrow');
    set(h,'buttondownfcn','northarrow(''mousedown'')')
    for i = 1:length(h);
        setappdata(h(i),'appdata',appdata);
    end
    hout = h;
    
case 'mousedown'

    appdata = getappdata(gco,'appdata');
 
    stype  = get(gcf,'SelectionType');
    switch stype
    case 'alt'
        
        s = appdata.s;
        dlgTitle = 'Inputs for North Arrow';
        prompt = {'Latitude and Longitude','FaceColor','EdgeColor','LineWidth','ScaleRatio'};
        def = {sprintf('%10.4f     ',[s.lat s.lon]),...
               sprintf('%10.4f     ',s.facecolor),...
               sprintf('%10.4f     ',s.edgecolor),...
               sprintf('%10.4f     ',s.linewidth),...
               sprintf('%10.4f     ',s.scaleratio)};
        lineNo = 1;
        answer = inputdlg(prompt,dlgTitle,lineNo,def);
        if ~isempty(answer)
            latlon = str2num(answer{1});
            % input errors for latitude and longitude
            if isempty(latlon)
                warndlg('Latitude and Longitude Unspecified','Input Error','modal') 
                return
            end
            if length(latlon) ~= 2
                warndlg('Latitude or Longitude Unspecified','Input Error','modal')    
                return
            end
            if latlon(1)<-90 or latlon(1)> 90
                warndlg('Latitude value must fall between 90 and -90 degrees','Input Error','modal')    
                return
            end
            if latlon(2)<-180 or latlon(1)> 180
                warndlg('Longitude value must fall between 180 and -180 degrees','Input Error','modal')    
                return
            end
            fcolor = str2num(answer{2});
            % facecolor elements
            if length(fcolor) ~= 3
                warndlg('FaceColor must be a three element vector','Input Error','modal')    
                return
            end
            aboveIndx = find(fcolor>1);
            belowIndx = find(fcolor<0);
            if ~isempty(aboveIndx) | ~isempty(belowIndx)
                warndlg('Each element of vector must fall between 0 and 1','Input Error','modal')
                return
            end
            ecolor = str2num(answer{3});
            % edgecolor elements
            if length(ecolor) ~= 3
                warndlg('EaceColor must be a three element vector','Input Error','modal')    
                return
            end
            aboveIndx = find(ecolor>1);
            belowIndx = find(ecolor<0);
            if ~isempty(aboveIndx) | ~isempty(belowIndx)
                warndlg('Each element of vector must fall between 0 and 1','Input Error','modal')
                return
            end
            lwidth = str2num(answer{4});
            % linewidth element
            if length(lwidth) ~= 1 | lwidth < 0
                warndlg('LineWidth must be a non-negative value','Input Error','modal')    
                return
            end
            sratio = str2num(answer{5});
            % scaleratio element
            if length(sratio) ~= 1 | lwidth < 0
                warndlg('ScaleRatio must be a non-negative value','Input Error','modal')    
                return
            end
        end
        
        if ~isempty(answer)
        
            s.lat = latlon(1);
            s.lon = latlon(2);
            s.facecolor = fcolor;
            s.edgecolor = ecolor;
            s.linewidth = lwidth;
            s.scaleratio = sratio;
            
            if ishandle(appdata.h)
                delete(appdata.h);
            end
            appdata.h = [];
            appdata.s = s;
            setappdata(gcf,'appdata',appdata);
	
			s = scalefactor(s);
            constructSymbol(s);
            northarrow('initialize');
        
        end
        
	case 'normal'
    
        if ishandle(appdata.h)
            delete(appdata.h);
        end
        cpoint = get(gca,'CurrentPoint');
        x = cpoint(1,1);
        y = cpoint(1,2);
        h = plot(x,y,'r.','MarkerSize',20,'EraseMode','xor','Tag','northArrowControl');
        appdata.h = h;
        setappdata(gcf,'appdata',appdata);
        set(gcf,'WindowButtonMotionFcn','northarrow(''move'');')
        set(gcf,'WindowButtonUpFcn','northarrow(''mouseup'');')
        
    end
    
case 'move'
    
    h = findobj(gcf,'Tag','northArrowControl');
    cpoint = get(gca,'CurrentPoint');
    x = cpoint(1,1);
    y = cpoint(1,2);
    set(h,'XData',x,'YData',y);
    
case 'mouseup'

    delete(findobj(gcf,'Tag','northArrowControl'))
    cpoint = get(gca,'CurrentPoint');
    x = cpoint(1,1);
    y = cpoint(1,2);

    set(gcf,'WindowButtonMotionFcn','')
    set(gcf,'WindowButtonUpFcn','')
    
    % redraw north arrow from new location
    [lat,lon] = minvtran(x,y);
    appdata = getappdata(gcf,'appdata');
    s = appdata.s;
    s.lat = lat; 
    s.lon = lon;
    appdata.s = s;
    setappdata(gcf,'appdata',appdata);
	s = scalefactor(s);
    constructSymbol(s);
    northarrow('initialize');
    
end
   
%-----------------------------------------------------------
function moveArrowToTop(h)

% move arrow up to the top of the stack
ch = get(gca,'Children');
maxZ = repmat(nan,1,length(ch(:)));
for i = 1:length(ch(:))
    objtype = get(ch(i),'Type');
    switch objtype
    case {'light','text'}
        pos = get(ch(i),'Position');
        maxZ(i) = pos(3);
    case {'line','patch','rectangle','surface'}
        zd = get(ch(i),'ZData');
        zd = zd(:);
        if ~isempty(zd)
            maxZ(i) = max(zd);
        end
    end
end        
maxz = max(maxZ);
zdatam(h,maxz+1);

%-----------------------------------------------------------
function constructSymbol(s)

appdata = getappdata(gcf,'appdata');
a = appdata.a;
p = appdata.p;
ns = appdata.ns;

% origin
[ox,oy] = mfwdtran(s.lat,s.lon);
vertVect = s.u*s.scalefactor;
horzVect = s.uPrime*s.scalefactor;

% arrow points
x{1} = ox + [0 a.Dist(1)*vertVect(1)];
y{1} = oy + [0 a.Dist(1)*vertVect(2)];

x{2} = ox + [a.Dist(2)*horzVect(1)];
y{2} = oy + [a.Dist(2)*horzVect(2)];

x{3} = ox + [a.Dist(3)*vertVect(1)];
y{3} = oy + [a.Dist(3)*vertVect(2)];

x{4} = ox - [a.Dist(4)*horzVect(1)];
y{4} = oy - [a.Dist(4)*horzVect(2)];

a.x = [x{:} fliplr(x{1})];
a.y = [y{:} fliplr(y{1})];

% pivot points
clear x y
x{1} = ox + [p.Dist(1)*vertVect(1)];
y{1} = oy + [p.Dist(1)*vertVect(2)];

x{2} = ox + [p.Dist(2)*vertVect(1)];
y{2} = oy + [p.Dist(2)*vertVect(2)];

x{3} = x{1};
y{3} = y{1};

x{4} = x{2};
y{4} = y{2};

p.x = [x{:}];
p.y = [y{:}];

% north symbol points
clear x y
x{1} = p.x(1) - [ns.Dist(1)*horzVect(1)];
y{1} = p.y(1) - [ns.Dist(1)*horzVect(2)];

x{2} = p.x(2) - [ns.Dist(2)*horzVect(1)];
y{2} = p.y(2) - [ns.Dist(2)*horzVect(2)];

x{3} = p.x(3) + [ns.Dist(3)*horzVect(1)];
y{3} = p.y(3) + [ns.Dist(3)*horzVect(2)];

x{4} = p.x(4) + [ns.Dist(4)*horzVect(1)];
y{4} = p.y(4) + [ns.Dist(4)*horzVect(2)];

% ensure that the 'N' letter is drawn correctly
if sign(s.u(1)) == -1 & sign(s.u(2)) == 1
    ns.x = [x{3} x{4} x{1} x{2}];
    ns.y = [y{3} y{4} y{1} y{2}];
else
    ns.x = [x{:}];
    ns.y = [y{:}];
end

% set application data
appdata.a = a;
appdata.p = p;
appdata.ns = ns;
setappdata(gcf,'appdata',appdata);

%-----------------------------------------------------------
function setApplicationData(s)

% set application data

% arrow
a.Dist = [0.25 0.25 0.75 0.25 0.25];
a.Az =  [0 90 0 270 0];
a.lat = []; a.lon = [];
a.x = []; a.y = [];

% pivot
p.Dist = [0.75 1.00 0.75 1.00];
p.Az = [0 0 0 0];
p.x = []; p.y = [];

% north symbol
ns.Dist = [0.125 0.125 0.125 0.125];
ns.Az = [270 270 90 90];
ns.lat = []; ns.lon = [];
ns.x = []; ns.y = [];

appdata.a = a;
appdata.p = p;
appdata.ns = ns;
appdata.s = s;
setappdata(gcf,'appdata',appdata)

%-----------------------------------------------------------
function s = scalefactor(s)

% compute the mean distance covered by the map axes
dist = mean([abs(diff(xlim)) abs(diff(ylim))]); 
s.scalefactor = dist*s.scaleratio;

% compute scalefactor in degrees
[x,y] = mfwdtran(s.lat,s.lon);
x2 = x; y2 = y+s.scalefactor;
[lat2,lon2] = minvtran(x2,y2);
s.scalefactordeg = distance(s.lat,s.lon,lat2,lon2);
% s.scalefactor = scalefactor;

% unit vector pointing north
[lat2,lon2] = reckon(s.lat,s.lon,s.scalefactordeg,0);
[x2,y2] = mfwdtran(lat2,lon2);
nV = [x2-x y2-y];

% unit vector pointing north
u = nV./norm(nV);
uSign = sign(u);
if diff(uSign) == 0
    uPrimeSign = [1 -1];
else
    uPrimeSign = -1*uSign;
end

% special case if unit vector aligned along principal direction
if all(u) ~= 1
    uPrime = u;
    nonZero = find(u ~=0);
    uPrime(nonZero) = 0;
    Zero = find(u == 0);
    uPrime(Zero) = u(nonZero);
else
	% unit vector perpendicular to one pointing north
	uPrime = 1./u; 
	uPrime = uPrime./norm(uPrime).*uPrimeSign;
end

s.u = u;
s.uPrime = uPrime;

% ------------------------------------------------------------------
function indx = stringMatch(string,stringset)

indx = strmatch(lower(string),lower(stringset));
if isempty(indx)
	error(['Undefined method: ',string]);
elseif length(indx) > 1
	indx = strmatch(string,stringset,'exact');
	if isempty(indx)
		error(['Non-unique method name: ',string])
	end
end

