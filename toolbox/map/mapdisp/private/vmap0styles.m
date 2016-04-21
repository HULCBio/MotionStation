function [s,sline,spoint,stext] = vmap0styles(s)
% VMAP0STYLES Set graphic properties of VMAP0 geographic data structures. 

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2003/12/13 02:55:26 $ 

%initialize new data structures to empty

[sline,spoint,stext] = deal([],[],[]);


if isempty(s); return; end


if ~isstruct(s);
   error('Input must be a geographic data structure from VMAP0DATA')
end

darkblue  = [0          0.50          1.00];
lightblue = [0.49       0.65          0.93];
lighterblue = [0.84          0.88          0.98];
brown     = [0.50       0.25             0];
gray      = 0.75*[ 1 1 1];
graygreen = [0.55          0.52          0.44];
grayred = [0.69          0.62          0.56];
grayblue = [0.61          0.61          0.69];
faintbrown = [0.93          0.85          0.60];
orange = [1.00          0.50             0];
browngreen = [0.8863    0.9098    0.6235];
darkergreen = [0    0.5020         0];
bluegreen = [0    0.5020    0.5020];
darkgreen = [0    0.6157    0.3098];
olive = [0.5020    0.5020         0];
whitegreen = [0.8353    1.0000    0.8353];
lightbluegreen = [0.3333    0.8078    0.7608];
lightbrowngreen = [0.8118    0.7765    0.0196];
greenbrown = [0.7961    0.8824    0.5020];
lightgreenblue = [0.3961    0.8392    0.6627];
lightgreenbrown = [0.8571    1.0000    0.7417];

blackdot = {'Color','k','MarkerFaceColor','k','marker','square','MarkerSize',3};


% BND theme

s = countrystyles(s);
s = addotherprop(s,'Coastline/Shoreline',{'Color','k'});
s = addotherprop(s,'Depth Contour',{'Color',darkblue});
s = addotherprop(s,'Water (except Inland)',{'FaceColor',lightblue,'Edgecolor','none'});
s = addotherprop(s,'International; Defacto Boundary',{'Color',orange,'LineStyle',':','LineWidth',2});
s = addotherprop(s,'International; Administrative Boundary',{'Color',orange,'LineStyle','--','LineWidth',2});
s = addotherprop(s,'Armistice Line',{'Color',orange,'LineStyle','-.','LineWidth',2});
s = addotherprop(s,'Claim Line',{'Color',orange,'LineStyle','-.','LineWidth',2});
s = addotherprop(s,'Cease-Fire Line',{'Color',orange,'LineStyle','-.','LineWidth',2});
s = addotherprop(s,'Primary/1st Order; Administrative Boundary',{'Color',orange,'LineStyle','--','LineWidth',1});

% ELEV
s = addotherprop(s,'Contour Line (Land)',{'Color',gray,'LineWidth',.5});
s = addotherprop2(s,'Spot Elevation','Accurate',{'Color','k','Marker','.','MarkerSize',5});
s = addotherprop2(s,'Spot Elevation','Approximate',{'Color','k','Marker','x','MarkerSize',5});
s = addotherprop2(s,'Inland Water Elevation','Approximate',{'Color','b','Marker','x','MarkerSize',5});
s = addotherprop2(s,'Inland Water Elevation','Accurate',{'Color','b','Marker','.','MarkerSize',5});
stext = addelevationtext(s,stext,'Spot Elevation','k');
stext = addelevationtext(s,stext,'Inland Water Elevation','b');

%HYDRO

% Aqueduct ...
s = addotherprop2(s,'Inland Water','On Ground Surface',{'Linewidth',.1,'Color',darkblue});
s = addotherprop2(s,'Inland Water','Suspended/Elevated',{'Linewidth',.1,'Color',darkblue});
s = addotherprop2(s,'Inland Water','Below Surface/Submerged/Underground',{'Linewidth',.1,'Color',darkblue,'LineStyle','--'});
s = addotherprop2(s,'Inland Water','Location Category: Unknown',{'Linewidth',.1,'Color',darkblue,'LineStyle','--'});
% Danger Point
s = addotherprop(s,'Rock  ',{'Color','k','Marker','*','MarkerSize',5},'strmatch');
s = addotherprop(s,'Wreck  ',{'Color','k','Marker','v','MarkerSize',5},'strmatch');
% Area
s = addotherpropbytype(s,'patch','Perennial/Permanent; Inland Water',{'Linewidth',.1,'FaceColor',lightblue,'EdgeColor',darkblue});                             
s = addotherpropbytype(s,'patch','Land Subject to Inundation',{'FaceColor',lighterblue,'EdgeColor','none'});                             
s = addotherpropbytype(s,'patch','Non-Perennial/Intermittent/Fluctuating; Inland Water',{'Linewidth',.1,'FaceColor',lighterblue,'EdgeColor',darkblue});                             
% Misc Line
s = addotherpropbytype(s,'line','Dam/Weir',{'Color','k','Linewidth',.51},'strmatch');
s = addotherpropbytype(s,'line','Seawall',{'Color','k','Linewidth',.51},'strmatch');
s = addotherpropbytype(s,'line','Breakwater/Groyne',{'Color','k','Linewidth',.51},'strmatch');
% Misc Point
s = addotherpropbytype(s,'point','Island',{'MarkerEdgeColor',darkblue,'MarkerFaceColor','w','marker','o','MarkerSize',2},'strmatch');
s = addotherpropbytype(s,'point','Spring/Water-Hole',{'Color',lightblue,'marker','.','MarkerSize',15},'strmatch');
s = addotherpropbytype(s,'point','Rapids',{'Color','b','marker','.','MarkerSize',15},'strmatch');
s = addotherpropbytype(s,'point','Waterfall',{'Color','b','marker','v','MarkerSize',5},'strmatch');
s = addotherpropbytype(s,'point','Dam/Weir',blackdot,'strmatch');
s = addotherpropbytype(s,'point','Lock',blackdot,'strmatch');
% Water Course Line
s = addotherprop(s,'River/Stream',{'Color',darkblue,'LineWidth',.1});
s = addotherprop(s,'Non-Perennial/Intermittent/Fluctuating',{'LineStyle','-.','LineWidth',.1});

%INDUSTRY

%Extraction areas
s = addotherpropbytype(s,'patch','; Oil/Gas Field',{'EdgeColor','b','FaceColor','None','LineStyle','--'},'findstr');
s = addotherpropbytype(s,'patch','; Mine/Quarry',{'EdgeColor','k','FaceColor','None','LineStyle','--'},'findstr');
s = addotherpropbytype(s,'patch','; Salt Evaporator',{'EdgeColor',darkblue,'FaceColor',lighterblue,'LineStyle',':'},'findstr');
%Extraction points
s = addotherpropbytype(s,'point','; Well',{'MarkerEdgeColor','k','MarkerFaceColor','w','Marker','o','MarkerSize',4},'findstr');
s = addotherpropbytype(s,'point','; Mine/Quarry',{'MarkerEdgeColor','k','Marker','x','MarkerSize',5},'findstr');
s = addotherpropbytype(s,'point','; Oil/Gas Field',{'MarkerEdgeColor','k','MarkerFaceColor','w','Marker','o','MarkerSize',5},'findstr');
s = addotherpropbytype(s,'point','; Salt Evaporator',{'MarkerEdgeColor',darkblue,'MarkerFaceColor','w','Marker','square','MarkerSize',4,'LineWidth',1.6},'findstr');
stext = addnametext(s,stext,'Well');
stext = addnametext(s,stext,'Mine/Quarry');
stext = addnametext(s,stext,'Oil/Gas Field');
stext = addnametext(s,stext,'Salt Evaporator');
% Fishery Indusrty Area
s = addotherpropbytype(s,'patch','Fish Hatchery/Fish Farm/Marine Farm',{'EdgeColor',darkblue,'FaceColor',lightblue},'findstr');
% Misc Industry Point
s = addotherprop(s,'; Processing Plant/Treatment Plant',blackdot);
s = addotherprop(s,'; Oil/Gas Facilities',blackdot);
s = addotherprop(s,'; Tower (Non-communication)',blackdot);
stext = addnametext(s,stext,'Processing Plant/Treatment Plant');
stext = addnametext(s,stext,'Oil/Gas Facilities');
stext = addnametext(s,stext,'Tower (Non-communication)');
% Storage Point
s = addotherpropbytype(s,'line','; Tank',{'Color','k','MarkerFaceColor','k','marker','o','MarkerSize',3});
s = addotherprop(s,'; Depot (Storage)',blackdot);
s = addotherprop(s,'; Water Tower',blackdot);
stext = addnametext(s,stext,'Tank');
stext = addnametext(s,stext,'Depot (Storage)');
stext = addnametext(s,stext,'Water Tower');

%PHYSIOGRAPHY
% Ground area
s = addotherpropbytype(s,'patch','Distorted Surface',{'FaceColor',grayred,'EdgeColor','none'},'strmatch');                             
s = addotherpropbytype(s,'patch','Sand',{'FaceColor',faintbrown,'EdgeColor','none'},'strmatch');                             
s = addotherpropbytype(s,'patch','Lava',{'FaceColor',grayblue,'EdgeColor','none'},'strmatch');                             
s = addotherpropbytype(s,'patch','Surface Material Category: Unknown',{'FaceColor',graygreen,'EdgeColor','none'},'strmatch');                             
%Land Ice Area
s = addotherpropbytype(s,'patch','Snow Field/Ice Field',{'FaceColor','w','EdgeColor','k'});                             
%Landform line
s = addotherpropbytype(s,'line','Bluff/Cliff/Escarpment',{'Color',grayred,'Linewidth',3},'strmatch');                             
s = addotherpropbytype(s,'line','Ice Cliff',{'Color',grayred,'Linewidth',3},'strmatch');                             
%Sea Ice Area
s = addotherpropbytype(s,'patch','Pack Ice',{'FaceColor','w','EdgeColor',darkblue});                             


%POPULATION
s = addotherpropbytype(s,'patch','; Built-Up Area',{'FaceColor','y','EdgeColor','none'});                             
s = poppointsymbols(s,'; Built-Up Area');
stext = addpoptext(s,stext,'Built-Up Area');

s = poppointsymbols(s,'; Settlement');
stext = addpoptext(s,stext,'; Settlement');

s = poppointsymbols(s,'; Native Settlement');
stext = addpoptext(s,stext,'; Native Settlement');

s = addotherpropbytype(s,'line','; Camp',blackdot);
stext = addnametext(s,stext,'; Camp');

s = addotherpropbytype(s,'line','; Building',blackdot);
stext = addnametext(s,stext,'; Building');

s = addotherpropbytype(s,'line','; Cairn',blackdot);
stext = addnametext(s,stext,'; Cairn');

s = addotherpropbytype(s,'line','; Monument',blackdot);
stext = addnametext(s,stext,'; Monument');

s = addotherpropbytype(s,'line','; Ruins',blackdot);
stext = addnametext(s,stext,'; Ruins');

s = addotherpropbytype(s,'line','; Wall',blackdot);
%stext = addnametext(s,stext,'; Wall');

s = addotherpropbytype(s,'line','; Lighthouse',blackdot);
stext = addnametext(s,stext,'; Lighthouse');

s = addotherpropbytype(s,'line','; Military Base',blackdot);
stext = addnametext(s,stext,'; Military Base');

%TRANSPORTATION
%Airports
s = addotherprop(s,'Airport/Airfield',{'Marker','+','MarkerSize',5});
s = addotherprop2(s,'Airport/Airfield','Military; ',{'Color','r'});
s = addotherprop2(s,'Airport/Airfield','Joint Military/Civilian',{'Color',orange});
s = addotherprop2(s,'Airport/Airfield','Usage: Unknown',{'Color','m'});
s = addotherprop2(s,'Airport/Airfield','Civilian/Public',{'Color','g'});
s = addotherprop2(s,'Airport/Airfield','Other',{'Color','m'});
stext = addnametext(s,stext,'Airport/Airfield','m',4);
% Data quality line
s = addotherprop(s,'Road; roadl',{'Color',brown});
s = addotherprop(s,'Railroad; railrdl',{'Color','k'});
sline = addrailroadties(s,sline,'Railroad','railrdl','k','single');
s = addotherprop(s,'Trail; traill',{'Color',brown,'LineStyle','--'});
%Misc transportation
s = addotherprop(s,'Aerial Cableway Line/Ski Lift Line',{'Color','k','LineStyle','--'});
s = addotherprop(s,'Pier/Wharf/Quay',{'Color','k'});
%Railroads
s = addotherprop(s,'; Railroad',{'Color','k'});
sline = addrailroadties(s,sline,'Railroad','Multiple','k','multiple');
sline = addrailroadties(s,sline,'Railroad','Single','k','single');
sline = addrailroadties(s,sline,'Railroad','Feature Configuration: Unknown','k','single');
%Roads
s = addotherprop(s,'; Road',{'Color',brown});
s = addotherprop2(s,'; Road','Primary Route',{'LineWidth',1.51});
s = addotherprop2(s,'; Road','With Median',{'LineWidth',3.0});
sline = addroadcenterline(s,sline,'Road','With Median','w');

%Railroad Yard Point
s = addotherprop(s,'Railroad Yard/Marshalling Yard',blackdot);

%Trail
s = addotherprop(s,'; Trail',{'Color',brown,'LineStyle','--'});

%Transportation structures node (none in SASAUS)
s = addotherprop(s,'Road;',{'Color',brown},'strmatch');
s = addotherprop(s,'Railroad;',{'Color','k'},'strmatch');

s = addotherprop(s,'; Bridge/Overpass',{'LineStyle','-','Linewidth',2});
s = addotherprop(s,'; Causeway',{'LineStyle','-'});
s = addotherprop(s,'; Ferry Crossing',{'LineStyle','-.'});
s = addotherprop(s,'; Tunnel',{'LineStyle',':'});
s = addotherprop(s,'; Ford',{'LineStyle','--'});

%UTILITIES
% Utility data quality and utility line
s = addotherprop(s,'Power Transmission Line',{'Color','k','LineStyle',':'},'strmatch');
s = addotherprop(s,'Pipeline/Pipe',{'Color','k','LineStyle','--'},'strmatch');
s = addotherprop(s,'Telephone Line/Telegraph Line',{'Color','k','LineStyle',':'},'strmatch');
spoint = addpowerlinedots(s,spoint,'Power Transmission Line','Power Transmission Line');
spoint = addpowerlinedots(s,spoint,'Telephone Line/Telegraph Line','Telephone Line/Telegraph Line');

%Pipeline
s = addotherprop(s,'On Ground Surface; Pipeline/Pipe',{'Color','k','LineStyle',':'},'strmatch');
s = addotherprop(s,'Below Surface/Submerged/Underground; Pipeline/Pipe',{'Color','k','LineStyle','--'},'strmatch');
spoint = addpowerlinedots(s,spoint,'Pipeline/Pipe','On Ground Surface');

%Utility point

s = addotherprop(s,'; Power Plant',blackdot);
stext = addnametext(s,stext,'; Power Plant');

s = addotherprop(s,'; Substation/Transformer Yard',blackdot);
stext = addnametext(s,stext,'; Substation/Transformer Yard');

s = addotherprop(s,'; Pumping Station',blackdot);
stext = addnametext(s,stext,'; Pumping Station');

s = addotherprop(s,'; Communication Building',blackdot);
stext = addnametext(s,stext,'; Communication Building');

s = addotherprop(s,'; Communication Tower',blackdot);
stext = addnametext(s,stext,'; Communication Tower');

%VEGETATION
s = addotherprop2(s,'Brush/Undergrowth','Scrub/Brush',{'FaceColor',browngreen,'EdgeColor','none'});                             
s = addotherprop2(s,'; Trees','Scrub/Brush',{'FaceColor',browngreen,'EdgeColor','none'});                             
s = addotherprop2(s,'; Trees','Deciduous',{'FaceColor',darkergreen,'EdgeColor','none'});                             
s = addotherprop2(s,'; Trees','Mixed Trees',{'FaceColor',darkergreen,'EdgeColor','none'});                             
s = addotherprop2(s,'; Trees','Evergreen',{'FaceColor',bluegreen,'EdgeColor','none'});  
s = addotherprop2(s,'; Trees','Other',{'FaceColor',olive,'EdgeColor','none'});  
s = addotherpropbytype(s,'patch','Tundra',{'FaceColor',whitegreen,'EdgeColor','none'});                             
s = addotherpropbytype(s,'patch','Marsh/Swamp',{'FaceColor',lightbluegreen,'EdgeColor','none'});                             
s = addotherpropbytype(s,'patch','Grassland',{'FaceColor',lightbrowngreen,'EdgeColor','none'});                             
s = addotherpropbytype(s,'patch','Cropland',{'FaceColor',greenbrown,'EdgeColor','none'});                             
s = addotherpropbytype(s,'patch','; Rice Field',{'FaceColor',lightgreenblue,'EdgeColor','none'});                             



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stext = addelevationtext(s,stext,matchstr,color);

%ADDELEVATIONTEXT constructs text entries from point elevations

tagmat = str2mat(s.tag);
spindx = findstrmat(tagmat,matchstr,'findstr');
len = length(stext);
if ~isempty(spindx)
   k=0;
   for i=1:length(spindx)
      
      % extract elevation from tag
      
      tag = s(spindx(i)).tag;
      indx = findstr(';',tag);
      
      if length(indx >=3)
         
         k=k+1;
         tag(indx(3):end) = [];
         tag(1:indx(2)+1) = [];
         
         if isempty(stext)
            stext = s(spindx(i));
         else
            if ~ismember('string',fieldnames(s));
               s(1).string = [];
            end
            stext(len+k) = s(spindx(i));
         end
         
         stext(len+k).type = 'text';
         stext(len+k).lat( isnan(stext(len+k).lat) ) = [];
         stext(len+k).long( isnan(stext(len+k).long) ) = [];
         stext(len+k).string = repmat(tag,length(stext(len+k).lat),1);
         stext(len+k).tag = [matchstr ' Text'];
         stext(len+k).otherproperty = {'FontSize',7,'HorizontalAlignment','left','VerticalAlignment','baseline','Color',color};
         
      end
      
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function stext = addnametext(s,stext,matchstr,color,slot);

%ADDNAMETEXT constructs text entries from first block in tag

if nargin < 4; color = 'k'; end
if nargin < 5; slot = 1; end

tagmat = str2mat(s.tag);
spindx = findstrmat(tagmat,matchstr,'findstr');
len = length(stext);
if ~isempty(spindx)
   k=0;
   for i=1:length(spindx)
      
      % extract elevation from tag
      
      tag = s(spindx(i)).tag;
      indx = findstr(';',tag);
      
      if length(indx >=slot) 
         
         
         tag(indx(slot):end) = [];
         if slot > 1; 
            tag(1:indx(slot-1)+1) = [];
         end
         
         
         % only add the tag string if it's not empty, and the object is
         % a VMAP0 point, and the string was found in the body of the tag
         
         if indx(1) > 1 & ...
               ~isempty(tag) & ~strcmp('no string provided',tag) & ...
               ~strcmp('other/unknown',lower(tag)) & ...
               ~strcmp('no entry present',lower(tag)) & ...
               strcmp('line',s(spindx(i)).type) & ...
               length(find(isnan(s(spindx(i)).lat))) == length(find(~isnan(s(spindx(i)).lat)))

            
            k=k+1;
            
            if isempty(stext)
               stext = s(spindx(i));
            else
               if ~ismember('string',fieldnames(s));
                  s(1).string = [];
               end
               stext(len+k) = s(spindx(i));
            end
            
            stext(len+k).type = 'text';
            stext(len+k).lat( isnan(stext(len+k).lat) ) = [];
            stext(len+k).long( isnan(stext(len+k).long) ) = [];
            stext(len+k).string = repmat(tag,length(stext(len+k).lat),1);
            stext(len+k).tag = [matchstr ' Text'];
            stext(len+k).otherproperty = {'FontSize',7,'HorizontalAlignment','left','VerticalAlignment','baseline','Color',color};
            
         end
         
      end
      
   end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = countrystyles(s)

% save the state of the random number generator

state = rand('state');

% Set the state of the random number generator to get repeatable results

rand('state',0)

% construct a colormap appropriate for political areas. 

cmap = polcmap(500,[0 .5],[.25 .55],[1 1]);

% reset the random number generator to the previous state

rand('state',state);

% Remove all but the country names from the tags and
% construct a pretty close to unique number based on the name.
% Apply the colors to the patches based on the index

tags = {s.tag};
for i=1:length(tags)
   
   tag = tags{i};
   type = s(i).type;
   
   if    ~isempty(findstr('Administrative Area',tag)) | ...
         ~isempty(findstr('Zone of Occupation',tag)) | ...
         ~isempty(findstr('Demilitarized Zone',tag))       
      indx = findstr(';',tag);
      tag(indx(2):end) = [];
      tag(1:indx(1)+1) = [];
      cdata(i) = floor( 500*sum(cumsum((tag))) / ...
         sum(cumsum(127+0*tag)) ); 
      
      switch type
      case 'patch'   
         s(i).otherproperty = {s(i).otherproperty{:}, ...
               'Facecolor',cmap(cdata(i),:),'Edgecolor','none'};
      case 'line'
         s(i).otherproperty = {s(i).otherproperty{:}, ...
               'Color',cmap(cdata(i),:),'marker','.','markersize',5};
      end
      
   end
   
end









%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = addotherprop(s,matchstr,props,method)

if nargin < 4; method = 'findstr'; end

strmat = str2mat(s.tag);


if isempty(matchstr)
	indx = 1:length(s);
else
	indx = findstrmat(strmat,matchstr,method);
end

for i=1:length(indx);
	s(indx(i)).otherproperty = {s(indx(i)).otherproperty{:} props{:}};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = addotherpropbytype(s,type,matchstr,props,method)

if nargin < 5; method = 'findstr'; end

strmat = str2mat(s.tag);


if isempty(matchstr)
	indx = 1:length(s);
else
	indx = findstrmat(strmat,matchstr,method);
end

for i=1:length(indx);
   
   apply = 0;
   
   switch type
   case 'point'
      
      % Handle graphics type 'line' with the same number of nans as points
      if strcmp('line',s(indx(i)).type) & ...
            length(find(isnan(s(indx(i)).lat))) == length(find(~isnan(s(indx(i)).lat)))
         apply=1;
      end
      
   case 'line'
      
      % Handle graphics type 'line' with a different number of nans and points
      if strcmp('line',s(indx(i)).type) & ...
            length(find(isnan(s(indx(i)).lat))) ~= length(find(~isnan(s(indx(i)).lat)))
         apply=1;
      end
      
   case 'patch'
      
      %Handle graphics type == VMAP0type      
      if strcmp('patch',s(indx(i)).type) 
         apply=1;
      end
      
   case 'text'
      
      %Handle graphics type == VMAP0type      
      if strcmp('text',s(indx(i)).type) 
         apply=1;
      end
      
   end
   
   if apply
      s(indx(i)).otherproperty = {s(indx(i)).otherproperty{:} props{:}};
   end
   
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = poppointsymbols(s,matchstr)

type = 'point';
method = 'findstr';

strmat = str2mat(s.tag);


if isempty(matchstr)
	indx = 1:length(s);
else
	indx = findstrmat(strmat,matchstr,method);
end

for i=1:length(indx);
   
      
      % Handle graphics type 'line' with the same number of nans as points
      if strcmp('line',s(indx(i)).type) & ...
            length(find(isnan(s(indx(i)).lat))) == length(find(~isnan(s(indx(i)).lat)))
         
         tag = s(indx(i)).tag;
         scindx = findstr(';',tag);
         
         if ~isempty(scindx)
            
            tag(scindx(1):end) = [];
            
            if ~isempty(tag)
               
               if any( tag >= 97 & tag <= 122 ) % has lowercase letters 
         
                  s(indx(i)).otherproperty = {s(indx(i)).otherproperty{:} ...
                        'Marker','square','Linestyle','none', ...
                        'MarkerEdgeColor','k','MarkerFaceColor','none','MarkerSize',3};
                  
               else  % All uppercase
                  
                  
                  s(indx(i)).otherproperty = {s(indx(i)).otherproperty{:} ...
                        'Marker','square','Linestyle','none', ...
                        'MarkerEdgeColor','k','MarkerFaceColor','y','MarkerSize',4.5};
                  
               end
               
            end
            
         end
         
      end
   
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = addotherprop2(s,matchstr1,matchstr2,props)


strmat = str2mat(s.tag);


indx1 = findstrmat(strmat,matchstr1,'findstr');
indx2 = findstrmat(strmat,matchstr2,'findstr');
indx = intersect(indx1,indx2);

for i=1:length(indx);
	s(indx(i)).otherproperty = {s(indx(i)).otherproperty{:} props{:}};
end

%*********************************************************************
%*********************************************************************
%*********************************************************************

function indx = findstrmat(strmat,searchstr,method)

strmat(:,end+1) = 13; % add a lineending character to prevent matches across rows


% find matches in vector

switch method
case 'findstr'
	% make string matrix a vector
	sz = size(strmat);
	strmat = strmat';
	strvec = strmat(:)';
	vecindx = findstr(searchstr,strvec);
	% vector indices to row indices
	indx = unique(ceil(vecindx/sz(2)));
case 'strmatch'
	indx = strmatch(searchstr,strmat);
case 'exact'
	searchstr(end+1) = 13; % added a lineending character above to prevent matches across rows
	indx = strmatch(searchstr,strmat,'exact');
end
%*********************************************************************
%*********************************************************************
%*********************************************************************

function stext = addpoptext(s,stext,matchstr,color);

%ADDNAMETEXT constructs populated place text entries from first block in tag

if nargin < 4; color = 'k'; end

tagmat = str2mat(s.tag);
spindx = findstrmat(tagmat,matchstr,'findstr');
len = length(stext);
if ~isempty(spindx)
   k=0;
   for i=1:length(spindx)
      
      % extract elevation from tag
      
      tag = s(spindx(i)).tag;
      indx = findstr(';',tag);
      
      if length(indx >=1) 
         
         tag(indx(1):end) = [];
         
         % only add the tag string if it's not empty, and the object is
         % a VMAP0 point, and the string was found in the body of the tag
         
         if indx(1) > 1 & ...
               ~isempty(tag) & ~strcmp('No entry present',tag) 
            
            k=k+1;
            
            if isempty(stext)
               stext = s(spindx(i));
            else
               if ~ismember('string',fieldnames(s));
                  s(1).string = [];
               end
               stext(len+k) = s(spindx(i));
            end
            
            stext(len+k).type = 'text';
            
            lat = stext(len+k).lat;
            lon = stext(len+k).long;
            [lat,lon] = meanm(lat(~isnan(lat)), lon(~isnan(lon)) );

            stext(len+k).lat = lat;
            stext(len+k).long = lon;
            stext(len+k).string = tag;
            stext(len+k).tag = [matchstr ' Text'];
            stext(len+k).otherproperty = {'FontSize',7,'HorizontalAlignment','left','VerticalAlignment','baseline','Color',color};
            
         end
         
      end
      
   end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sline = addroadcenterline(s,sline,matchstr1,matchstr2,color);

%ADDROADCENTERLINE adds entries with centerline for divided highways

if nargin < 5; color = 'w'; end

tagmat = str2mat(s.tag);
spindx1 = findstrmat(tagmat,matchstr1,'findstr');
spindx2 = findstrmat(tagmat,matchstr2,'findstr');
spindx = intersect(spindx1,spindx2);
len = length(sline);
if ~isempty(spindx)
   k=0;
   for i=1:length(spindx)
      
      
      k=k+1;
      
      if isempty(sline)
         sline = s(spindx(i));
      else
         sline(len+k) = s(spindx(i));
      end

      sline(len+k).tag = [matchstr1 ' Centerlines'];
      sline(len+k).altitude = 1;
      sline(len+k).otherproperty = {'Color','w','LineWidth',1};
      
      
   end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function spoint = addpowerlinedots(s,spoint,matchstr1,matchstr2,color);

%ADDPOWERLINEDOTS adds entries with dots for powerlines

if nargin < 5; color = 'k'; end

tagmat = str2mat(s.tag);
spindx1 = findstrmat(tagmat,matchstr1,'findstr');
spindx2 = findstrmat(tagmat,matchstr2,'findstr');
spindx = intersect(spindx1,spindx2);
len = length(spoint);
if ~isempty(spindx)
   k=0;
   for i=1:length(spindx)
      
      
      lat = s(spindx(i)).lat;
      lon = s(spindx(i)).long;
      
      % merging polygons segments makes for more pleasing 
      % power lines, but can be time consuming with a large
      % number of segments. Only try to chain up segments if
      % there aren't to many of them.
      
      if size(find(isnan(lat))) < 1000
         [lat,lon] = polymerge(lat,lon);
      end
      
      dindx = find(diff(lat)==0 & diff(lon)==0);
      lat(dindx) = [];lon(dindx)=[];
      [lat,lon] = powerlinedots(lat,lon);
      
      if ~isempty(lat)
         k=k+1;
         
         if isempty(spoint)
            spoint = s(spindx(i));
         else
            spoint(len+k) = s(spindx(i));
         end
         
         spoint(len+k).lat = lat;
         spoint(len+k).long = lon;
         spoint(len+k).tag = [matchstr1 ' Dots'];
         spoint(len+k).otherproperty = {'Color',color,'Marker','.','MarkerSize',5};
      end
      
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [latt,lont] = powerlinedots(lat,lon)
% POWERLINEDOTS constructs dot vertices at 5 nm intervals

% 'project' angle data to projected coordinates in units of nautical miles
% Effectively a platte carree projection without clipping. Do this so we 
% can get railroad 'ties' at 5 nm intervals.
x = deg2nm(lon);
y = deg2nm(lat);

% extract nan-clipped line segments
[xc,yc] = polysplit(x,y);

   
   % Construct 'ties' at 5 nm intervals
   for i=1:length(xc);
      [xtc{i},ytc{i}]=railroadtiescart(xc{i},yc{i},5,0,'k','c',0,0.5);
   end


% combine tic marks for various segments
[xy,yt]= polyjoin(xtc,ytc);

% undo 'projection'
latt = nm2deg(yt);
lont = nm2deg(xy);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sline = addrailroadties(s,sline,matchstr1,matchstr2,color,config);

%ADDRAILROADTIES adds entries with tic marks for railroads

if nargin < 5; color = 'k'; end
if nargin < 6; config = 'single'; end

tagmat = str2mat(s.tag);
spindx1 = findstrmat(tagmat,matchstr1,'findstr');
spindx2 = findstrmat(tagmat,matchstr2,'findstr');
spindx = intersect(spindx1,spindx2);
len = length(sline);
if ~isempty(spindx)
   k=0;
   for i=1:length(spindx)
      
      lat = s(spindx(i)).lat;
      lon = s(spindx(i)).long;
      
      % merging polygons segments makes for more pleasing 
      % railroad tie, but can be time consuming with a large
      % number of segments. Only try to chain up segments if
      % there aren't to many of them.
      
      if size(find(isnan(lat))) < 1000
         [lat,lon] = polymerge(lat,lon);
      end
      
      dindx = find(diff(lat)==0 & diff(lon)==0);
      lat(dindx) = [];lon(dindx)=[];
      
      [lat,lon] = railroadties(lat,lon,config);
      
      
      if length(lat) > 0
         
         k=k+1;
         
         if isempty(sline)
            sline = s(spindx(i));
         else
            sline(len+k) = s(spindx(i));
         end
         
         sline(len+k).lat = lat;
         sline(len+k).long = lon;
         sline(len+k).tag = [matchstr1 ' Ties'];
         sline(len+k).otherproperty = {'Color',color};
         
       end
      
      
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [latt,lont] = railroadties(lat,lon,config)
% RAILROADTIES constructs railrad tie line segments at 5 nm intervals

% 'project' angle data to projected coordinates in units of nautical miles
% Effectively a platte carree projection without clipping. Do this so we 
% can get railroad 'ties' at 5 nm intervals.
x = deg2nm(lon);
y = deg2nm(lat);

% extract nan-clipped line segments
[xc,yc] = polysplit(x,y);

switch config
case 'single'
   
   % Construct 'ties' at 5 nm intervals
   for i=1:length(xc);
      [xtc{i},ytc{i}]=railroadtiescart(xc{i},yc{i},5,1,'k','c',0,0.5);
   end
   
case {'double','multiple'}
   
   
   % Construct 'ties' at 5 nm intervals
   for i=1:length(xc);
      x=xc{i}; y=yc{i};
      [xt1,yt1]=railroadtiescart(x,y,5,1,'k','c',0,0.5);
      [xt2,yt2]=railroadtiescart(x,y,5,1,'k','c',0,1.0);
      [xtc{i},ytc{i}]=deal([xt1;xt2],[yt1;yt2]);
   end
   
otherwise
   error('unrecognized configuration')
end


% combine tic marks for various segments
[xy,yt]= polyjoin(xtc,ytc);

% undo 'projection'
latt = nm2deg(yt);
lont = nm2deg(xy);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [xt,yt] = railroadtiescart(varargin)

% usage:
%
%	railroadtiescart(x,y,interval,width,s,location,slant,offset)
%
%		x,y:		the cartesian coordinates of data
%		interval:	interval between tick tracks
%		width:		width of tick tracks
%		s:			character string for line color
%		location:	location of tick tracks wrt line ('c' or 'center' 
%					centers tracks on line, 0 places one end of track 
%					on line, any other positive or negative number
%					places the tracks at that distance from the line)
%		slant:		slant angle of tick tracks wrt line
%		offset:		offset distance between first tick track and first
%					data point




% set inputs
if nargin>=4 & nargin<=8
	x = varargin{1};
	y = varargin{2};
	interval = varargin{3};
	width = varargin{4};
	if nargin>=5,	s = varargin{5};
	else,			s = [];					 end
	if nargin>=6,	location = varargin{6};
	else,			location = [];			 end
	if nargin>=7,	slant = varargin{7};
	else,			slant = [];				 end
	if nargin==8,	offset = varargin{8};
	else,			offset = [];			 end
else
	error('Incorrect number of input arguments');
end

% set defaults
if isempty(s),			s = 'b';				end
if isempty(location),	location = 'center';	end
if isempty(slant),		slant = 0;				end
if isempty(offset),		offset = 0;				end

% column vectorize inputs and convert slant to radians
x = x(:);  y = y(:);
slant = slant*pi/180;

% calculate normal vectors for vertices
% normal vector points to the right of the directional tangent vector
sidenormal = atan2(-diff(x),diff(y));
n = length(sidenormal);
shiftvec = [sidenormal(n); sidenormal(1:n-1)];
vertnormal = (sidenormal + shiftvec)/2;

% reverse direction of those vertices that shift across 180 degree line
% so that all normals face the same direction (inward or outward)
i1 = find( (sidenormal>=pi/2 & sidenormal<=pi) & ...
		   (shiftvec<=-pi/2 & shiftvec>=-pi) );
i2 = find( (sidenormal<=-pi/2 & sidenormal>=-pi) & ...
		   (shiftvec>=pi/2 & shiftvec<=pi) );
indx = sort([i1 ;i2]);
newvert = vertnormal(indx) + pi;
i = find(newvert>pi);
newvert(i) = newvert(i) - 2*pi;
vertnormal(indx) = newvert;
vertnormal = [vertnormal; vertnormal(1)];

% convert vertex normal angles for interpolation
n = length(vertnormal);
shiftvec = [vertnormal(2:n); vertnormal(1)];
i1 = find( (vertnormal>=pi/2 & vertnormal<=pi) & ...
		   (shiftvec<=-pi/2 & shiftvec>=-pi) );
i2 = find( (vertnormal<=-pi/2 & vertnormal>=-pi) & ...
		   (shiftvec>=pi/2 & shiftvec<=pi) );
for i=1:length(i1)
	vertnormal(i1(i)+1:n) = 2*pi + vertnormal(i1(i)+1:n);
end
for i=1:length(i2)
	vertnormal(i2(i)+1:n) = -2*pi + vertnormal(i2(i)+1:n);
end

% calculate vertex distances for interpolation
n = length(x);
xshift = [x(n); x(1:n-1)];
yshift = [y(n); y(1:n-1)];
dist = cumsum(sqrt((x-xshift).^2 + (y-yshift).^2));

% determine angles for tick points
dvec = (offset:interval:(round(dist(n)/interval)-1)*interval)';
angle = interp1(dist,vertnormal,dvec);

% determine locations for tick points
x0 = interp1(dist,x,dvec);
y0 = interp1(dist,y,dvec);
if strmatch(lower(location),'center')
	x1 = x0 - 0.5*width*cos(angle+slant);
	y1 = y0 - 0.5*width*sin(angle+slant);
else
	if isnumeric(location)
		x1 = x0 + location*cos(angle+slant);
		y1 = y0 + location*sin(angle+slant);
	else
		error('Incorrect location input')
	end
end
if location<0,  a = -1;  else,  a = 1;  end
x2 = x1 + a*width*cos(angle+slant);
y2 = y1 + a*width*sin(angle+slant);

% plot line and tick marks
%state = get(gca,'NextPlot');
% hndl(1) = plot(x,y,s); hold on
m = length(x1);
xa = [x1 x2 nan*ones(m,1)];
ya = [y1 y2 nan*ones(m,1)];
xt = reshape(xa',[1 m*3]);
yt = reshape(ya',[1 m*3]);
% hndl(2) = plot(xt,yt,s);
% set(gca,'NextPlot',state)

% return tics

xt = [xt(:)];
yt = [yt(:)];


