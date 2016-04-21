function hout  = usamap(varargin)
%USAMAP Create a map of the United States of America.
%  
%   USAMAP creates a map of all or some of the United States of America.
%   The state or states are selected interactively from a list.  A map
%   axes and  map is created in the current axes.  The AXIS limits are set
%   tight around the map frame.
%  
%   h = USAMAP('ALL') or USAMAP ALL creates a standard map of the U.S.A.
%   The  conterminous states, Alaska and Hawaii are each displayed as
%   insets in  different axes using projection parameters suggested by the
%   U.S.  Geological Survey.  The handles for the three map axes are
%   returned in h.   h(1) contains the conterminous states, h(2) Alaska,
%   and h(3) Hawaii.
%  
%   USAMAP ALLEQUAL creates the map with Alaska and Hawaii at the same
%   scale  as the conterminous states.  
%  
%   USAMAP CONUS maps only the conterminous states.
%  
%   USAMAP STATE or USAMAP('STATE') maps the requested state.  Example: 
%   USAMAP vermont.  STATE may also be a padded string matrix or a cell
%   array  of strings containing multiple state names.  
%   
%   USAMAP STATEONLY maps only that state.  Example: USAMAP vermontonly. If
%   any of the state names in a STATE string matrix or cell array of 
%   strings end with 'only', only the requested states are displayed.
%  
%   USAMAP('STATE','TYPE') controls the atlas data displayed.  Type 'line'
%   or  'patch' creates a map with atlas data of those types and text
%   annotation  of the state names.  Type 'lineonly' or 'patchonly'
%   suppresses text  annotation.  Type 'none' suppresses all atlas data.
%   If omitted, type  'patch' is assumed.
%   
%   USAMAP(latlim,lonlim) creates a map of the states covering the provided
%   latitude and longitude limits.  The limits are two-element vectors in
%   units  of degrees.
%  
%   USAMAP(map,maplegend) and USAMAP(map,maplegend,'TYPE') use the supplied
%   regular matrix map to define the geographic limits. The matrix map is
%   displayed using MESHM unless type is 'none', 'lineonly', 'patch' or
%   'patchonly'. Use type 'meshonly' to display only the matrix map.
%
%   USAMAP(latlim,lonlim,'TYPE') is also a valid calling form.
% 
%   h = USAMAP(...)  returns the handle or handles of the axes containing
%   the  map
%   
%   USAMAP uses TIGHTMAP set the axis limits tight around the map. If you
%   change  the projection, or just want more white space around the map
%   frame, use TIGHTMAP again or AXIS AUTO.
%
%   See also WORLDMAP, USALO, USAHI, SELECTMOVERESIZE, AXESSCALE,
%   PAPERSCALE.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.8.4.2 $  $Date: 2003/12/13 02:55:48 $

% If no geographic limits or region supplied, interactive 
% selection of region
	
% force normalized units

% Parse and check input arguments

if nargin == 0; % EASYMAP
	region = [];
	type = 'patch';
	latlim = [];
	lonlim = [];
elseif nargin == 1 % EASYMAP REGION
	region = lower(varargin{1});
	type = 'patch';
	latlim = [];
	lonlim = [];
elseif nargin == 2 && ( (ischar(varargin{1}) || iscell(varargin{1}) ) && ischar(varargin{2})) % EASYMAP(region,type)
	region = lower(varargin{1});
	type = varargin{2};
	latlim = [];
	lonlim = [];
elseif nargin == 2 && ( ~ischar(varargin{1}) && ~ischar(varargin{2})) % EASYMAP(latlim,lonlim)
	region = [];
	latlim = varargin{1};
	lonlim = varargin{2};
	type = 'patch';
	if all( size(lonlim) == [1 3]) && size(latlim,1) > 1
		map = varargin{1};
		maplegend = varargin{2};
		[latlim,lonlim] = limitm(map,maplegend);
		lonlim = lonlim + [-1 0]*(10*epsm('deg')); % avoids trimming
		type = 'mesh';
	end	
elseif nargin == 3 && ( ~ischar(varargin{1}) && ~ischar(varargin{2})) % EASYMAP(latlim,lonlim,type)
	region = [];
	latlim = varargin{1};
	lonlim = varargin{2};
	type = varargin{3};		
	if all( size(lonlim) == [1 3])
		map = varargin{1};
		maplegend = varargin{2};
		[latlim,lonlim] = limitm(map,maplegend);
		lonlim = lonlim + [-1 0]*(10*epsm('deg')); % avoids trimming
	end	
else
	error('Incorrect number or type of arguments')
end


onlyflag = 0;

latlim = latlim(:)';
lonlim = lonlim(:)';

if ~isempty(latlim);
	if ~isequal(size(latlim),[1,2]) || ~isequal(size(lonlim),[1,2])
		error('Latlim and lonlim must be two element vectors')
	end
end

if ~isempty(type)
	typeindx = strmatch(type,{'patch','line','patchonly','lineonly','none','mesh','meshonly'},'exact');
	if isempty(typeindx)
        error(sprintf('Map type is not ''patch'', ''line'', ''patchonly'', ''lineonly'', \n''mesh'', ''meshonly''  or ''none''. '));
    end
end

load usalo
if nargin == 0;
	statelist = {...
		'All',...
		'AllEqual',...
		'Conus',...
		state.tag};
	
	indx = listdlg('ListString',statelist,...
                   'SelectionMode','single',...
					    'Name','Select a region');
%					    'ListSize',[160 170],...
						
	if isempty(indx);
        return
    end
	
	region = statelist{indx};
end

if ~iscell(region) && ~isempty(region)
	switch lower(region)
	case {'all','allequal','conus'}
		
		hconus = axes('Position',[ -0.0078125      0.13542       1.0156      0.73177]);
		axesm('MapProjection','eqaconic',...
				'MapParallels', [29.5 49.5],...
				'Origin',[0 -100 0],...
				'MapLatLimit',[23 50],...
				'MapLonLimit',[-127 -65],...
				'MLineLocation',10,'PLineLocation',10,...
				'MLabelLocation',10,'PLabelLocation',10,...
				'LabelRotation','on',...
				'MLabelPar',0)
		
		xlim([-0.56 0.6])  % nice amount of white space around CONUS, and
		ylim([ 0.30 0.92])	% lock down limits to disable autoscaling. Use AXIS AUTO to undo 
		
				
		switch type
		case {'patch','patchonly'}
			hc = displaym(conus);zdatam(hc,-1)
			displaym(greatlakes)
			hborder = displaym(stateborder); set(hborder,'linestyle','-')
		case {'line','lineonly'}
			
			plotm(uslat,uslon,'k','Tag','conus');
			plotm(gtlakelat,gtlakelon,'k','Tag','gtlake')
			plotm(statelat,statelon,'k','Tag','statelines')
		end
		h = hconus;
	end
	
	switch lower(region)
	case {'all','allequal'}
		% Axes for Alaska. Scale is considerably different from CONUS
		
		[lat,lon] = extractm(state,'alaska');
		latlim = [ 5*floor(min(lat)/5) 5*ceil(max(lat)/5) ]; % Snap to 5 degree increments
		lonlim = [ 5*floor(min(lon)/5) 5*ceil(max(lon)/5) ];
		
		
		halaska = axes('Position',[0.029297      0.10938      0.39453      0.36458]);
		axesm('MapProjection','eqaconic',...
				'MapParallels', [55    65],...
				'Origin',[0 -150 0],...
				'MapLatLimit',latlim,...
				'MapLonLimit',lonlim,...
				'MLineLocation',10,'PLineLocation',10,...
				'MLabelLocation',10,'PLabelLocation',10,...
				'LabelRotation','on',...
				'MLabelPar',0)
		
		xlim([-0.3 0.3 ])
		ylim([ 0.7  1.3])
		
		switch type
		case {'patch','patchonly'}
			displaym(state,'Alaska')
		case {'line','lineonly'}
			plotm(extractm(state,'Alaska'),'k','Tag','Alaska')
		end
		
		% Hawaii
		[lat,lon] = extractm(state,'hawaii');
		latlim = [ 5*floor(min(lat)/5) 5*ceil(max(lat)/5) ]; % Snap to 5 degree increments
		lonlim = [ 5*floor(min(lon)/5) 5*ceil(max(lon)/5) ];
		
		hhawaii = axes('Position',[0.31055      0.17188      0.19141      0.20052]);
		axesm('MapProjection','eqaconic',...
				'MapParallels', [8 18],...
				'Origin',[0 -157 0],...
				'MapLatLimit',[18 24],...
				'MapLonLimit',[-160 -154],...
				'LabelRotation','on',...
				'MLineLocation',1,'PLineLocation',1,...
				'MLabelLocation',5,'PLabelLocation',5)
		
		xlim([-0.064103  0.058974])
		ylim([ 0.30519 0.44026])
		
		switch type
		case {'patch','patchonly'}
			displaym(state,'Hawaii')
		case {'line','lineonly'}
			plotm(extractm(state,'Hawaii'),'k','Tag','Hawaii')
		end
		
		h = [hconus;halaska;hhawaii];
	end

% resize axes for equal area scales
	
	switch lower(region)
	case 'allequal'
	
		% Move axes a bit to accomodate alaska at same scale
		set(halaska,'Position',[0.019531    -0.020833      0.2 0.2])
		set(hhawaii,'Position',[0.6 0.2 .2 .2])
		set(hconus,'Position',[0.1 0.25 0.85 0.6])
		axesscale(hconus) % resize alaska and hawaii axes
	
	end

% Hide the axes
	
	switch lower(region)
	case {'all','allequal','conus'}
		switch type
		case 'none' 
			framem;gridm;mlabel;plabel
		otherwise
			set(h,'visible','off','color','w')
            set(get(h(1),'Title'),'Visible','on')
		end
		axes(hconus)
		if nargout ==1
            hout = h;
        end
		return
	end
end	

% Maps of individual states

% state name 

load usahi

if ~isempty(region)
	
% detect the only case

		% single string 
		if ischar(region) && size(region,1) ==1 
		
			if length(region) >= 5 && strcmp(region(end-4:end),' only') 
				region = region(1:end-5);
				onlyflag=1;
			elseif length(region) >= 4 && strcmp(region(end-3:end),'only')
				region = region(1:end-4);
				onlyflag=1;
			end
		
		% string matrix - convert to cell array of strings, which need not be padded
		elseif ischar(region) && size(region,1) > 1
			for i=1:size(region,1)
				cellregion{i} = region(i,:);
			end
			region = deblank(cellregion);
		end
	
		%only case with cell array of strings
		if iscell(region)
			for i=1:length(region)
				thisregion = region{i};
				if length(thisregion) >= 5 && strcmp(thisregion(end-4:end),' only') 
					thisregion = thisregion(1:end-5);
					onlyflag=1;
				elseif length(thisregion) >= 4 && strcmp(thisregion(end-3:end),'only')
					thisregion = thisregion(1:end-4);
					onlyflag=1;
				end
				region{i} = thisregion;
			end
		end
	
	
% extract lat and long data for the requested region

	try
		[lat,lon,indx] = extractm(statepatch,region);
	catch
		linebreak = sprintf('\n');
		error(['Valid region strings are state names or' 	linebreak ...
				' ''All'','						linebreak ...
				' ''AllEqual'','				linebreak ...
				' ''Conus''.'					 ])		
	end

% make nice limits based on region
	
    % Snap to 1 degree increments, with a 1 degree buffer
	inc = 1;
	buffer = 1;
	latlim = [ inc*floor(min(lat-buffer)/inc) inc*ceil(max(lat+buffer)/inc) ];
	lonlim = [ inc*floor(min(lon-buffer)/inc) inc*ceil(max(lon+buffer)/inc) ];

	if ~isempty(strmatch('alaska',lower(region))) % special case crossing the dateline
		lonlim = [ inc*floor(min(zero22pi(lon))/inc) inc*ceil(max(zero22pi(lon))/inc) ]-360;
	end
end

if lonlim(1) > lonlim(2)
	lonlim(2) = lonlim(2) + 360; % ensure ascending lonlim for alaska
end

% Now have latlim, lonlim, in the range -180 + 200 (in cases computed from region)

% Compute a nice increment for labels and grid.
% Pick a ticksize that gives at least 3 grid lines

maxdiff = max(abs([diff(latlim) diff(lonlim)]));
mindiff = min(abs([diff(latlim) diff(lonlim)]));
ticcandidates = [.1 .5 1 2 2.5 5 10 15 20 30 45 ] ;
[ignored,indx] = min( abs( 4 - (mindiff ./ ticcandidates) ));

ticksize = ticcandidates(indx);
roundat = 0;
if mod(ticksize,1) ~= 0; roundat = -1; end

% States are small enough to display conformally with little error
projection = 'lambert';

% set up the map axes
axesm(...
		'MapProjection',projection,...
		'MapLatLimit',latlim,...
		'MapLonLimit',lonlim,...
		'MapParallels',[],...
		'MLabelLoc',ticksize,...
		'MLineLoc',ticksize,...
		'PLabelLoc',ticksize,...
		'PLineLoc',ticksize,...
		'MLabelRound',roundat,...
		'PLabelRound',roundat,...
		'MLabelPar',0,...
		'GColor',[.75 .75 .75],... %[0.36471      0.72941      0.79216],... % fog
		'GLineStyle',':',...
		'Frame','on',...
		'Grid','on',...
		'LabelRotation','on',...
		'MeridianLabel','on',...
		'ParallelLabel','on'...
		)

% Display basemap information

if onlyflag % just the region requested
	switch lower(type)
	case {'line','lineonly'}
		hl = displaym(stateline,region); set(hl,'color','k')
	case {'patch','patchonly'}
		hp = displaym(statepatch,region); zdatam(hp,-1)
	end
else % neighboring areas also
	switch lower(type)
	case {'line','lineonly','mesh'}
		if exist('map','var'); meshm(map,maplegend); end
		hl = displaym(stateline); set(hl,'color','k')
	case {'patch','patchonly'}
		hp = displaym(statepatch); zdatam(hp,-1)
		
		polcmap(51);
	case 'meshonly'

		if exist('map','var')
			meshm(map,maplegend)
		end
	end
	
	
	switch lower(type)
	case {'line','patch','mesh'}	
		indx = find(([statetext.lat]  > latlim(1)) & ([statetext.lat]  < latlim(2)) & ...
					([statetext.long] > lonlim(1)) & ([statetext.long] < lonlim(2)) );
		
		if length(indx) < 15
			h = displaym(statetext(indx));
			set(h,'fontsize',9)
			rotatetext(h)
		end
	end
end

tightmap

if nargout == 1
    hout = gca;
end
