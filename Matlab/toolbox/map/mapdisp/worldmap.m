function hout = worldmap(varargin)
%WORLDMAP Map a country or region using WORLDLO or WORLDHI atlas data.
%   WORLDMAP maps a region or country using the WORLDLO atlas data. The region 
%   is selected interactively from a list. The map is created in the current
%   axes. 
%  
%   WORLDMAP REGION or WORLDMAP('REGION') makes a map of the specified 
%   region.  Recognized region strings are 'Africa', 'Antarctica', 'Asia', 
%   'Europe',.  'North America', 'North Pole', 'Pacific', 'South America', 
%   'South Pole', 'World' and the names of the countries in the WORLDLO atlas 
%   data.  REGION may also be a padded string matrix or a cell array of strings 
%   containing multiple country names.
%   
%   WORLDMAP REGIONONLY adds only the specified country to the map.  For 
%   example, WORLDMAP italyonly.  If any of the country names in REGION string 
%   matrix or cell array of strings end with 'only', only the requested 
%   countries are displayed.
%  
%   WORLDMAP('REGION','TYPE') controls the atlas data displayed. Type 'line' or
%   'patch' creates a map with atlas data of those types. If the size of the map
%   permits, point and text annotation of countries and cities is included'. 
%   Type 'lineonly' or 'patchonly' suppresses the point and text annotation.
%   Type 'none' suppresses all atlas data. If omitted, type 'line' is assumed.
%  
%   WORLDMAP(latlim,lonlim) and WORLDMAP(latlim,lonlim,'TYPE') use the supplied
%   geographic limits to define the map. The geographic limits are two-element 
%   vectors of the form [start end], in angular units of degrees. 
%  
%   WORLDMAP(map,maplegend) and WORLDMAP(map,maplegend,'TYPE') use the supplied
%   regular matrix map to define the geographic limits. The matrix map is displayed
%   using MESHM unless type is 'none', 'lineonly', 'patch' or 'patchonly'. Use type
%   'meshonly' to display only the matrix map. Type 'mesh' and 'meshonly' display
%   the matrix map as a colored surface in the z=0 plane with the default colormap.
%   Type 'dem' and 'demonly' apply the digital elevation colormap. Type 'dem3d' and
%   'dem3donly' display a 3-dimensional surface. Type 'lmesh3d', 'lmesh3donly',
%   'ldem3d' and 'ldem3donly' apply lighting effects to the surfaces.
%
%   WORLDMAP('hi',...) or WORLDMAP('lo',...) enforces the use of high or low 
%   resolution data in the map. If omitted, WORLDMAP will select the appropriate
%   data set. For a paper scale of 1:30,000,000 or greater, the WORLDLO database is 
%   used. For smaller scales, the WORLDHI database is used. When using the high 
%   resolution data, WORLDMAP will not include islands smaller than an appropriate 
%   threshhold size. To include all islands regardless of size, use 
%   WORLDMAP('allhi',...).
%  
%   h = WORLDMAP(...) returns the handle of the map axes.
%  
%   WORLDMAP uses TIGHTMAP set the axis limits tight around the map. If you change 
%   the projection, or just want more white space around the map frame, use TIGHTMAP
%   again or AXIS AUTO.
%  
%   See also USAMAP, GRIDM, MLABEL, PLABEL, FRAMEM, WORLDLO.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $ $Date: 2003/08/01 18:23:22 $ 
%   Written by:  W. Stumpf


% Parse and check input arguments

mynargin=nargin;
dataset='whatever';
if mynargin >=1 & isstr(varargin{1}) & ...
      ( strcmp('hi',lower(varargin{1})) | ...
        strcmp('lo',lower(varargin{1})) | ...
        strcmp('allhi',lower(varargin{1})) )
   dataset=varargin{1};
   varargin(1)=[];
   mynargin=mynargin-1;
end

selectfromlist=0;
if mynargin == 0; % EASYMAP
   region = [];
   type = 'line';
   latlim = [];
   lonlim = [];
   selectfromlist=1;
elseif mynargin ==1 % EASYMAP REGION
   region = varargin{1};
   type = 'line';
   latlim = [];
   lonlim = [];
elseif mynargin ==2 & isempty(varargin{1}) & isstr(varargin{2})  % EASYMAP('',type)
   region = [];
   type = varargin{2};
   latlim = [];
   lonlim = [];
   selectfromlist=1;
elseif mynargin ==2 & ( (isstr(varargin{1}) | iscell(varargin{1})) & isstr(varargin{2})) % EASYMAP(region,type)
   region = varargin{1};
   type = varargin{2};
   latlim = [];
   lonlim = [];
elseif mynargin ==2 & ( ~isstr(varargin{1}) & ~isstr(varargin{2})) % EASYMAP(latlim,lonlim),  EASYMAP(map,maplegend)
   region = [];
   latlim = varargin{1};
   lonlim = varargin{2};
   type = 'line';
   if all( size(lonlim) == [1 3]) & size(latlim,1) > 1
      map = varargin{1};
      maplegend = varargin{2};
      [latlim,lonlim] = limitm(map,maplegend);
      % avoid trims if displaying subset of world
      if abs(diff(lonlim)) ~= 360
          lonlim = lonlim + [-1 0]*(10*epsm('deg')); % avoids trimming
      end
      type = 'mesh';
   end	
elseif mynargin ==3 & ( ~isstr(varargin{1}) & ~isstr(varargin{2})) % EASYMAP(latlim,lonlim,type),  EASYMAP(map,maplegend,type)
   region = [];
   latlim = varargin{1};
   lonlim = varargin{2};
   type = varargin{3};		
   if all( size(lonlim) == [1 3])
      map = varargin{1};
      maplegend = varargin{2};
      [latlim,lonlim] = limitm(map,maplegend);
      % avoid trims if displaying subset of world
      if abs(diff(lonlim)) ~= 360
          lonlim = lonlim + [-1 0]*(10*epsm('deg')); % avoids trimming
      end
   end
else
   error('Incorrect number or type of arguments')
end

% ensure row vectors

latlim = latlim(:)';
lonlim = lonlim(:)';

if ~isempty(latlim);
   if ~isequal(size(latlim),[1,2]) & ~isequal(size(lonlim),[1,2])
      error('Latlim and lonlim must be two element vectors')
   end
end

if ~isempty(type)
   validtypes = {'patch','line','patchonly','lineonly','none',...
         'mesh','meshonly','mesh3d','dem','demonly','dem3d','dem3donly',...
      'ldem3d','ldem3donly','lmesh3d','lmesh3donly'};
   typeindx = strmatch(type,validtypes,'exact');
   if isempty(typeindx); error(sprintf('%s\n','Valid map types are:',validtypes{:}));end
end

%ensure region is a cell array of strings

if isstr(region)
   newregion = {};
   for i=1:size(region,1)
      newregion{i} = region(i,:);
   end
   region = deblank(newregion);
end

% If no geographic limits or region supplied, interactive 
% selection of region

onlyflag = 0;
if selectfromlist;
   region = getregion;   
   if isempty(region); return; end
end

% If no geographic limits supplied, use region to look it up
if isempty(latlim)
   [latlim,lonlim,region,onlyflag]=getlimits(region,onlyflag);
end

%Put latlim, lonlim, in the range -180 + 200 (in cases computed from region)
if lonlim(1) > lonlim(2)
   lonlim(2) = lonlim(2)+360; % ensure ascending lonlim
end

% Set up projection. Compute nice grid settings, and pick an appropriate projection

setupprojection(latlim,lonlim)

% Remove map and maplegend if no longer required. This way 
% if they still exist, we can be sure that we wanted to 
% display them
if exist('map','var')
   switch lower(type)
   case {'lineonly','patchonly'}
      clear map maplegend
   end
end


% Display basemap information

% matrix map data
if exist('map','var') 
   showrmm(map,maplegend,type)
end


% Vector map data
if ( ...
   paperscale > 30e6 & ...
   ~((strcmp(lower(dataset),'hi') | (strcmp(lower(dataset),'allhi') ) )) ...
   ) ...
   | ...
   strcmp(lower(dataset),'lo')

   addworldlodata(region,latlim,lonlim,type,onlyflag)   
   
else % display worldhi data
   
   addworldhidata(region,latlim,lonlim,type,onlyflag,dataset)   
   
end





if nargout ==1;
   hout = gca;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function region = getregion;

% Load the worldhi database.
s=load('worldhi','POpatch');
POpatch=s.POpatch;


region = [];

countrylist = {...
      'Africa',...
      'Antarctica',...
      'Asia',...
      'Europe',...
      'North America',...
      'North Pole',...
      'Pacific',...
      'South America',...
      'South Pole',...
      'World',...
      POpatch.tag};

indx = listdlg('ListString',countrylist,...
   'SelectionMode','single',...
   'Name','Select a region');

if isempty(indx); return; end

region = countrylist(indx);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [latlim,lonlim,region,onlyflag]=getlimits(region,onlyflag)


latlim = [];
lonlim = [];

if length(region) == 1
   switch lower(region{1})
   case {'af','africa'}
      latlim = [-40 40];
      lonlim = [-20 54];
   case {'an','antarctica'}
      latlim = [-90 -65];
      lonlim = [-180 180];
   case {'pa','pacific'}
      latlim = [-50 30];
      lonlim = [110 210];
   case {'sa','south america'}
      latlim = [-60 15];
      lonlim = [-90 -30];
   case {'e','eu','europe'}
      latlim = [30 60];
      lonlim = [-15 45];
   case {'a','as','asia'}
      latlim = [-10 85];
      lonlim = [25 195];
   case {'na','north america'}
      latlim = [14 85];
      lonlim = [-170 -49];
   case {'np','north pole'}
      latlim = [84 90];
      lonlim = [-180 180];
   case {'sp','south pole'}
      latlim = [-60 -90];
      lonlim = [-180 180];
   case {'wo','world'}
      latlim = [-90 90];
      lonlim = [-180 180];
   end
end

if isempty(latlim) % country name from worldhi's POpatch
   
   
   % detect the 'only case', 
   onlyflag = 0;
   %only case with cell array of strings
   if iscell(region)
      for i=1:length(region)
         thisregion = region{i};
         if length(thisregion) >= 5 & strcmp(thisregion(end-4:end),' only') 
            thisregion = thisregion(1:end-5);
            onlyflag=1;
         elseif length(thisregion) >= 4 & strcmp(thisregion(end-3:end),'only')
            thisregion = thisregion(1:end-4);
            onlyflag=1;
         end
         region{i} = thisregion;
      end
   end
   % special abbreviations
   
   if iscell(region) & isequal(lower(region),{'us'}) | isequal(lower(region),{'usa'})
      region = {'united states'};
   end
   
   % load data if needed
   
   if ~exist('POpatch','var'); 
      s=load('worldhi','POpatch');
      POpatch=s.POpatch;
   end
   
   % extract lat-long for countries. Error out if region unrecognized
   try
      indx=find(ismember(lower({POpatch.tag}),region));   % look for exact matches
      if length(indx) ~= length(region)                   % couldn't get exact match on all regions
         indx = [];                                       % so settle for strmatch-like matches below
      end                                                 % using extractm
      
      if isempty(indx)
         [lat,lon,indx]=extractm(POpatch,region);
      end
      
      [lat,lon]=deal([],[]);
      for i=1:length(indx)
         [lat1,lon1]=deal(POpatch(indx(i)).latlim,POpatch(indx(i)).longlim);
         lat=[min([lat(:);lat1(:)]) max([lat(:);lat1(:)])];
         lon=[min([lon(:);lon1(:)]) max([lon(:);lon1(:)])];
      end
   catch
      linebreak = sprintf('\n');
      error(['Valid region strings are country names or' 	linebreak ...
            '   ''an'' or ''antarctica'','				linebreak ...
            '   ''a''  or ''asia'','					linebreak ...
            '   ''af'' or ''africa'','					linebreak ...
            '   ''pa'' or ''pacific'','					linebreak ...
            '   ''e''  or ''europe'','					linebreak ...
            '   ''na'' or ''north america'','			linebreak ...
            '   ''sa'' or ''south america'','			linebreak ...
            '   ''np'' or ''north pole'','			linebreak ...
            '   ''sp'' or ''south pole'','			linebreak ...
            '   ''af'' or ''africa'','			linebreak ...
            '   ''wo'' or ''world''.' ])
   end
   
   % make nice latitude and longitude limits from data
   
   inc = 5;
   buffer = 1;
   latlim = [ inc*floor(min(lat-buffer)/inc) inc*ceil(max(lat+buffer)/inc) ]; % Snap to 5 degree increments, with a 1 degree buffer
   lonlim = [ inc*floor(min(lon-buffer)/inc) inc*ceil(max(lon+buffer)/inc) ];
   
   if ~iscell(region) & ~isempty(strmatch('russia',lower(region))) % special case crossing the dateline
      lonlim = [ 5*floor(min(zero22pi(lon))/5) 5*ceil(max(zero22pi(lon))/5) ];
   end
   if ~iscell(region) & ~isempty(strmatch('united states',lower(region))) % special case crossing the dateline
      lonlim = [ 5*floor(min(zero22pi(lon))/5) 5*ceil(max(zero22pi(lon))/5) ]-360;
   end
   if ~isempty(strmatch('fiji',lower(region))) % special case crossing the dateline
      lonlim = [5*floor(lon(2)/5) 5*ceil(lon(1)/5)];
   end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setupprojection(latlim,lonlim)

% Compute a nice increment for labels and grid.
% Pick a ticksize that gives at least 3 grid lines

maxdiff = max(abs([diff(latlim) diff(lonlim)]));
mindiff = min(abs([diff(latlim) diff(lonlim)]));
ticcandidates = [.1 .5 1 2 2.5 5 10 15 20 30 45 ] ;
[ignored,indx] = min( abs( 3 - (mindiff ./ ticcandidates) ));

ticksize = ticcandidates(indx);
roundat = 0;
if mod(ticksize,1) ~= 0; roundat = -1; end

% Select a projection based on latlim,lonlim.

if isequal(latlim,[-90 90]) & diff(lonlim) >= 360 % entire globe
   projection = 'robinson';
elseif max(abs(latlim)) < 20% straddles equator, but doesn't extend into extreme latitudes
   projection = 'mercator';
elseif abs(diff(latlim)) <= 90 & abs(sum(latlim)) > 20  & max(abs(latlim)) < 90 % doesn't extend to the pole, not stradling equator
   projection = 'eqdconic';
elseif abs(diff(latlim)) < 85  & max(abs(latlim)) < 90 % doesn't extend to the pole, not stradling equator
   projection = 'sinusoid';
elseif max(latlim) == 90 & min(latlim) >= 84
   projection = 'upsnorth';
elseif min(latlim) == -90 & max(latlim) <= -80
   projection = 'upssouth';
elseif max(abs(latlim)) == 90 & abs(diff(lonlim)) < 180
   projection = 'polycon';
elseif max(abs(latlim)) == 90 
   projection = 'eqdazim';
else
   projection = 'miller';
end

% Delete existing map axes if necessary
if ismap(gca) == 1
   delete(get(gca,'Children'));
end

% Set up the axes with the selected projection and parameters.
% More than one path because of error messages setting parallels
% when projections don't have any.

if strcmp(projection,'upsnorth') | strcmp(projection,'upssouth')
   
   axesm('MapProjection','ups','Zone',projection(4:end),...
      'Frame','on',...
      'Grid','on',...
      'LabelRotation','on',...
      'MeridianLabel','on',...
      'ParallelLabel','on',...
      'MLabelParallel',0 ...
      )
   
else
   
   mstruct = defaultm(projection);
   
   if strcmp(projection,'eqdazim')
      axesm(...
         'MapProjection',projection,...
         'FLatLimit',[-Inf abs(diff(latlim))],...
         'Origin',[90*sign(latlim(2)) mean(lonlim) 0],...
         'MLabelLoc',ticksize,...
         'MLineLoc',ticksize,...
         'PLabelLoc',ticksize,...
         'PLineLoc',ticksize,...
         'MLabelRound',roundat,...
         'PLabelRound',roundat,...
         'GColor',[.75 .75 .75],... %[0.36471      0.72941      0.79216],... % fog
         'GLineStyle',':',...
         'Frame','on',...
         'Grid','on',...
         'LabelRotation','on',...
         'MeridianLabel','on',...
         'ParallelLabel','on',...
         'MLabelParallel',0 ...
         )
      
   elseif mstruct.nparallels > 0
         
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
   else
      axesm(...
         'MapProjection',projection,...
         'MapLatLimit',latlim,...
         'MapLonLimit',lonlim,...
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
   end
end

% Leave a little space around non-cylindrical projections to avoid clipping the frame
names = maps('idlist');
pclass = maps('classcodes');
indx = strmatch(projection,names);
thispclass = deblank(pclass(indx,:));

switch thispclass
case 'Cyln'
   tightmap tight
otherwise
   tightmap loose
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function showrmm(map,maplegend,type)

switch lower(type)
case {'mesh','dem','meshonly','demonly'}
   
   meshm(map,maplegend)
   
case {'dem3d','mesh3d','ldem3d','lmesh3d',...
         'dem3donly','mesh3donly','ldem3donly','lmesh3donly'}
   
   meshm(map,maplegend,size(map),map)
   
end


% Control aspect ratio for 3d plots
switch lower(type)
case {'dem3d','ldem3d'}
   da = daspect;
   pba = pbaspect;
   da(3) = 7.5*pba(3)/da(3);
   daspect(da);
case {'mesh3d','lmesh3d'}
   da = daspect;
   pba = pbaspect;
   da(3) = 2*pba(3)/da(3);
   daspect(da);
end

% Add Digital elevation colormap
switch lower(type)
case {'dem','dem3d','ldem3d','demonly','dem3donly','ldem3donly'}
   demcmap(map)
end

% Add lighting effects
switch lower(type)
case {'lmesh3d','ldem3d'}
   camlight(90,5);
   camlight(0,5);
   lighting phong
   material([0.25 0.8 0])
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addworldlodata(region,latlim,lonlim,type,onlyflag)


%Display worldlo data

if onlyflag % just the region requested ( | iscell(region))
   switch lower(type)
   case {'line','lineonly'}
      
      load worldlo
      
      [lat,lon,indx] = extractm(POpatch,region);
      for i=1:length(indx)
         plotm(POpatch(indx(i)).lat,POpatch(indx(i)).long,'k','Tag',POpatch(indx(i)).tag)
      end
      
   case {'patch','patchonly'}
      
      if ~exist('POpatch','var'); load worldlo; end
      
      h = displaym(POpatch,region);
      if ~isempty(h)
          zdatam(h,-1);
      end
      
   end
else
   
   switch lower(type)
   case {'line','lineonly','mesh','dem','dem3d'}
      
      load worldlo
      
      displaym(POline); set(handlem('International Boundary'),'Color','k')
      displaym(DNline); hidem('Streams,rivers,channelized rivers')
      
      for i=1:length(DNpatch) % convert large lake patches to lines
         DNpatch(i).type = 'line';
         DNpatch(i).otherproperty = {'color','k'};
      end
      displaym(DNpatch);
      
   case {'patch','patchonly'}
      
      if ~exist('POpatch','var'); load worldlo; end
      
      h = displaym(POpatch);
      if ~isempty(h)
          zdatam(h,-1);
      end
      h = displaym(DNpatch);
      set(h,'Facecolor','w')
      if ~isempty(h);
          zdatam(h,-0.5);
      end
      
      polcmap
      
   end
   
   % Add populated places, if space permits
   
   switch lower(type)
   case {'line','patch','mesh'}
      
      if ~exist('POpatch','var'); load worldlo; end
      
      indx = find(([PPtext.lat]  > latlim(1)) & ([PPtext.lat]  < latlim(2)) & ...
         ([PPtext.long] > lonlim(1)) & ([PPtext.long] < lonlim(2)) );
      
      if length(indx) < 15
         
         displaym(PPpoint(1)) % City point markers
         
         for i=indx
            PPtext(i).string = [ ' ' PPtext(i).string ' '];
         end
         
         h = displaym(PPtext(indx)); % City text
         set(h,'fontsize',9)
         rotatetext(h)
      end	
      
      indx = find(([POtext.lat]  > latlim(1)) & ([POtext.lat]  < latlim(2)) & ...
         ([POtext.long] > lonlim(1)) & ([POtext.long] < lonlim(2)) );
      
      if length(indx) < 15
         h = displaym(POtext(indx));
         set(h,'fontsize',9)
         rotatetext(h)
      end
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function addworldhidata(region,latlim,lonlim,type,onlyflag,dataset)


%%%%%%%%%%%%%%% display worldhi data



%enforce inclusion of all islands, if requested
switch lower(dataset)
case 'allhi'
   minsize = 0;
otherwise
   minsize = paperscale/1000000;
end

if onlyflag % just the region requested ( | iscell(region))
   switch lower(type)
   case {'line','lineonly'}
      
      POpatch=worldhi(region,minsize);
      for i=1:length(POpatch)
         plotm(POpatch(i).lat,POpatch(i).long,'k','Tag',POpatch(i).tag)
      end
      
   case {'patch','patchonly'}
      
      h = displaym(worldhi(region,minsize));
      if ~isempty(h);
          zdatam(h,-1);
      end
      
   end
   
else
   
   POpatch=worldhi(latlim,lonlim,minsize);
   
   switch lower(type)
   case {'lineonly','line','mesh'}
      
      for i=1:length(POpatch)
         plotm(POpatch(i).lat,POpatch(i).long,'k','Tag',POpatch(i).tag)
      end
      
   case {'patch','patchonly'}
      
      h = displaym(POpatch);
      if ~isempty(h);
          zdatam(h,-1);
      end
      
      polcmap
      
   end
   
   % Add populated places, if space permits
   
   switch lower(type)
   case {'line','patch','mesh'}
      
      
      addedpp = 0;
      for jj = 1:2 % loop over two sources of populated places
         
         switch jj
         case 1
            load worldlo
            PPpoint(1) = []; % contains all points concatenated
         case 2
            PPtext=worldhi('PPtext');
            PPpoint=worldhi('PPpoint');
         end
         
         
         indx = find(([PPtext.lat]  > latlim(1)) & ([PPtext.lat]  < latlim(2)) & ...
            ([PPtext.long] > lonlim(1)) & ([PPtext.long] < lonlim(2)) );
                  
         % add worldlo populated places if there arent to many, and 
         % add worldhi populated places if there arent to many, and we added worldlo data.
         if length(indx) < 15 & (jj==1 | (jj==2 & addedpp > 0))
            
            addedpp = addedpp+1;
            
            indx2 = find(([PPpoint.lat]  > latlim(1)) & ([PPpoint.lat]  < latlim(2)) & ...
               ([PPpoint.long] > lonlim(1)) & ([PPpoint.long] < lonlim(2)) );
            
            displaym(PPpoint(indx2)) % City point markers
            
            for i=1:length(indx)
               PPtext(indx(i)).string = [ ' ' PPtext(indx(i)).string ' '];
            end
            
            h = displaym(PPtext(indx)); % City text
            set(h,'fontsize',9)
            rotatetext(h)
         end	
         
      end % jj
      
      POtext = worldlo('POtext');
      
      indx = find(([POtext.lat]  > latlim(1)) & ([POtext.lat]  < latlim(2)) & ...
         ([POtext.long] > lonlim(1)) & ([POtext.long] < lonlim(2)) );
      
      if length(indx) < 15
         h = displaym(POtext(indx));
         set(h,'fontsize',9)
         rotatetext(h)
      end
      
      
   end
end
