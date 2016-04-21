function varargout = demdataui(varargin)
%DEMDATAUI GUI to extract matrix data from external sources.
%   DEMDATAUI is a Graphical User Interface to extract Digital
%   Elevation Map data from a number of external data files. 
%   DEMDATAUI reads ETOPO5, TerrainBase, GTOPO30, GLOBE, satellite
%   bathymetry and DTED data. See the links under 'See also' for more
%   information on these datasets. DEMDATAUI looks for these external
%   data files on the MATLAB path and, for some operating systems, on 
%   CD-ROM disks. Click the HELP button for more information on use of 
%   the GUI and how DEMDATAUI recognizes data sources.
%
%   See also VMAP0UI, ETOPO5, TBASE, GTOPO30, GLOBEDEM, SATBATH, DTED.

%   Copyright 1996-2003 The MathWorks, Inc.
%   $Revision: 1.8.4.1 $  $Date: 2003/08/01 18:18:17 $
%   Written by:  W. Stumpf

if nargin == 0;
   varargin{1} = 'initialize';
end

switch varargin{1}
case 'clear'
   demdatauiclear
case 'slider'
   demdatauislider
case 'get'
      demdatauiget
case 'list'
   uilist
case 'save'
   uisave
case 'help'
   uihelp
case 'close'
   uiclose
case 'initialize'	% initial call to construct gui   
   uistart
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function demdatauiget
%DEMDATAUIGET extracts data from the external matrix data interfaces

% put up the watch as a placebo
pointer = get(gcbf,'pointer');
set(gcbf,'pointer','watch')

try
   
   lasterr('Cancelled DEMDATAUI Get.')
   
   % Retrieve handles and such from the GUI user data slot
   
   h = get(get(gcbo,'Parent'),'userdata');

   % Which database
   liststrs = get(h.list,'String');
   if isempty(liststrs); error('No external DEM data found. Click the HELP button for more on external data sources'); end
   indx = get(h.list,'value');
   database = liststrs{indx};

   % determine size of region to be extracted
   [nrows,ncols] = demdatauislider;
   
   % verify for large matrices
   
   if nrows*ncols > 500*500
      answer = questdlg(['Are you sure you want to extract a ' num2str(nrows) ' by ' num2str(ncols) ' matrix?' ...
            ' You can use the mouse to zoom into a smaller region'], ...
         ' DEMDATAUI Warning','Cancel','Continue','Cancel');
      
      if strcmp(answer,'Cancel')
         set(gcbf,'pointer',pointer)
         return
      end
      
      drawnow
      
   end
   
   
   % Determine latitude and longitude limits from current axis limits
   
   x = get(h.axes,'XLim');
   y = get(h.axes,'Ylim');
   [latlim,lonlim] = minvtran([min(x) max(x)],[min(y) max(y)]);
   if lonlim(2) < lonlim(1); lonlim(1) = lonlim(1)-360; end
         
   %Scalefactor
   h = get(get(gcbo,'Parent'),'userdata');
   scalefactor = round(get(h.slider,'Value'));
   
   switch database
   case 'TerrainBase'
      
      [map,maplegend] = tbase(scalefactor,latlim,lonlim);
      h.extracteddata(end+1).type = 'regular';
      h.extracteddata(end).tag = 'TerrainBase data';
      h.extracteddata(end).map = map;
      h.extracteddata(end).maplegend = maplegend;
      h.extracteddata(end).meshgrat = [];
      h.extracteddata(end).altitude = [];
      h.extracteddata(end).otherproperty = {};
      
      meshm(map,maplegend,[2 2])
      demcmap('inc',[-10000 8000],100)
      
   case 'ETOPO5'
      
      [map,maplegend] = etopo5(scalefactor,latlim,lonlim);
      h.extracteddata(end+1).type = 'regular';
      h.extracteddata(end).tag = 'ETOPO5 data';
      h.extracteddata(end).map = map;
      h.extracteddata(end).maplegend = maplegend;
      h.extracteddata(end).meshgrat = [];
      h.extracteddata(end).altitude = [];
      h.extracteddata(end).otherproperty = {};
      
      if ~isempty(map)
         meshm(map,maplegend,[2 2])
         demcmap('inc',[-10000 8000],100)
      end
      
   case 'GTOPO30'
      
      pth = h.path{indx};
      if ~strcmp(pth(end),filesep)
         pth = [pth filesep];
      end
      
      [map,maplegend] = gtopo30(pth,scalefactor,latlim,lonlim);
      map(isnan(map)) = -1;
      
      
      h.extracteddata(end+1).type = 'regular';
      h.extracteddata(end).tag = 'GTOPO30 data';
      h.extracteddata(end).map = map;
      h.extracteddata(end).maplegend = maplegend;
      h.extracteddata(end).meshgrat = [];
      h.extracteddata(end).altitude = [];
      h.extracteddata(end).otherproperty = {};
      
      if ~isempty(map)
         meshm(map,maplegend,[2 2])
         demcmap('inc',[-10000 8000],100)
      end
      
   case 'GLOBE'
      
      pth = h.path{indx};
      if ~strcmp(pth(end),filesep)
         pth = [pth filesep];
      end
      
      [map,maplegend] = globedem(pth,scalefactor,latlim,lonlim);
      map(isnan(map)) = -1;
      
      
      h.extracteddata(end+1).type = 'regular';
      h.extracteddata(end).tag = 'GLOBEDEM data';
      h.extracteddata(end).map = map;
      h.extracteddata(end).maplegend = maplegend;
      h.extracteddata(end).meshgrat = [];
      h.extracteddata(end).altitude = [];
      h.extracteddata(end).otherproperty = {};
      
      if ~isempty(map)
         meshm(map,maplegend,[2 2])
         demcmap('inc',[-10000 8000],100)
      end
      
   case 'DTED'
      
      pth = h.path{indx};
      
      if ~strcmp(pth(end),filesep)
         pth = [pth filesep];
      end
      
      switch h.resolution(indx)
      case deg2dms(1/120)
         level = 0;
      case deg2dms(1/1200)
         level = 1;
      case deg2dms(1/3600)
         level = 2;
      end
      
      [map,maplegend] = dted(pth,scalefactor,latlim,lonlim);
      
      map(map==0) = -1;
      
      
      h.extracteddata(end+1).type = 'regular';
      h.extracteddata(end).tag = 'DTED data';
      h.extracteddata(end).map = map;
      h.extracteddata(end).maplegend = maplegend;
      h.extracteddata(end).meshgrat = [];
      h.extracteddata(end).altitude = [];
      h.extracteddata(end).otherproperty = {};
      
      if ~isempty(map)
         meshm(map,maplegend,[2 2])
         demcmap('inc',[-10000 8000],100)
      end
      
   case 'SatBath'
      
      [latgrat,longrat,map] = satbath(scalefactor,latlim,lonlim);
      h.extracteddata(end+1).type = 'surface';
      h.extracteddata(end).tag = 'SatBath data';
      h.extracteddata(end).map = map;
      h.extracteddata(end).lat = latgrat;
      h.extracteddata(end).long = longrat;
      h.extracteddata(end).altitude = [];
      h.extracteddata(end).otherproperty = {};
      
      if ~isempty(map)
         surfm(latgrat,longrat,map)
         demcmap('inc',[-10000 8000],100)
      end
      
   end
   
   set(h.fig,'userdata',h)
   
   lasterr('')
   
catch
   errordlg(lasterr,'Error reading data')
end


set(gcbf,'pointer',pointer)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uilist

%UILIST actions as a result of clicking on the list

% Retrieve handles and such from the GUI user data slot

h = get(get(0,'CurrentFigure'),'userdata');

% Which database
liststrs = get(h.list,'String');
if isempty(liststrs); return; end
indx = get(h.list,'value');
database = liststrs{indx};

% hide all tiles
if ~isempty(h.tiles)
	hidem(cat(2,h.tiles{:}))
end
set(handlem('Frame'),'Facecolor','w')

switch database
case {'TerrainBase','ETOPO5'}
   set(handlem('Frame'),'Facecolor',[0.99          1.00          0.85])
otherwise
   showm(h.tiles{indx})
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nrowsout,ncolsout] = demdatauislider

%DEMDATAUIslider updates calculation of resulting matrix size based on slider action


if ~strcmp(get(gcf,'tag'),'DEMDATAUI')
   return
end

%check if a get is in progress
if ~isempty( findall(0,'type','figure','tag','TMWWaitbar','UserData',get(gcbo,'Parent')) );
   return
end

h = get(get(0,'CurrentFigure'),'userdata');

% Scalefactor
scalefactor = round(get(h.slider,'Value'));
set(h.slider,'Value',scalefactor)

%Show number superimposed on slider button
pos = get(h.slidervalue,'Position');
%pos(2) = 0.23 + scalefactor/99*(0.81-0.23);
pos(2) = 0.19 + 1.05*scalefactor/99*(0.81-0.19);
set(h.slidervalue,'Position',pos,'String',num2str(scalefactor))


% Determine latitude and longitude limits from current axis limits
x = get(h.axes,'XLim');
y = get(h.axes,'Ylim');
[latlim,lonlim] = minvtran([min(x) max(x)],[min(y) max(y)]);
if lonlim(2) < lonlim(1); lonlim(1) = lonlim(1)-360; end

% Determine current database
liststrs = get(h.list,'String');
if isempty(liststrs); return; end
indx = get(h.list,'value');
database = liststrs{indx};

% Determine size for latlim and lonlim
switch database
case 'SatBath'
   [nrows,ncols] = satbath('size',scalefactor,latlim,lonlim);
otherwise
   resolution = dms2deg(h.resolution(indx));
   extractedsize = sizem(latlim,lonlim,1/(scalefactor*resolution));
   [nrows,ncols] = deal(extractedsize(1),extractedsize(2));
end

set(get(h.axes,'title'),'String',[num2str(nrows) ' by ' num2str(ncols) ' matrix'])

set(h.fig,'userdata',h)

if nargout > 0;
   [nrowsout,ncolsout] = deal(nrows,ncols);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function demdatauiclear

%DEMDATAUICLEAR removes extracted data from the plot and storage

%check if a get is in progress
if ~isempty( findall(0,'type','figure','tag','TMWWaitbar','UserData',get(gcbo,'Parent')) );
   return
end

h = get(get(gcbo,'Parent'),'userdata');
hobj = get(h.axes,'Children');
hnew = setdiff(hobj,h.baseobjects);
delete(hnew)
h.extracteddata = [];

set(h.fig,'userdata',h)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uistart

sources = {};
h.resolution = [];
h.path = {};
h.tiledata = {};
h.tiles = [];

% check for tbase
if exist('tbase.bin','file')==2
   sources{end+1} = 'TerrainBase';
   h.resolution(end+1) = 5; % DMS format: 5 minute grid spacing
   h.tiledata{end+1} = 0;
end

% Check for etopo5
if exist('new_etopo5.bil','file') | (exist('etopo5.northern.bat','file')==2 & exist('etopo5.southern.bat','file')==2)
   sources{end+1} = 'ETOPO5';
   h.resolution(end+1) = 5; % DMS format: 5 minute grid spacing
   h.tiledata{end+1} = 0;
end


% check for GTOPO30
[g30pth,sgtopo30] = gtopo30path;
if ~isempty(g30pth) & ~isequal(g30pth,{''})
   for i=1:length(g30pth)
      sources{end+1} = 'GTOPO30';
      h.resolution(end+1) = .30; % DMS format: 30 arc-second spacing
      h.path{length(sources)} = g30pth{i};
      h.tiledata{end+1} = sgtopo30;
   end   
end

% check for GLOBEDEM
[gdpth,sgd] = globedempath;
if ~isempty(gdpth) & ~isequal(gdpth,{''})
   for i=1:length(gdpth)
      sources{end+1} = 'GLOBE';
      h.resolution(end+1) = .30; % DMS format: 30 arc-second spacing
      h.path{length(sources)} = gdpth{i};
      h.tiledata{end+1} = sgd{i};
   end   
end

% Check for satbath
if exist('topo_6.2.img','file')==2
   sources{end+1} = 'SatBath';
   h.resolution(end+1) = NaN; % Variable spacing (mercator projection)
   h.tiledata{end+1} = 0;
end


% check for DTED
[dtedpth] = unique(dtedpath);
if ~isempty(dtedpth) & ~isequal(dtedpth,{''})
   
   for i=1:length(dtedpth)
      
      sdted = dtedtiles(dtedpth{i});

      if ~isempty(sdted) % might have an empty directory named dted
          switch(sdted(1).level)
          case 0
              h.resolution(end+1) = deg2dms(1/120); % DMS format: 30 arc-second spacing
          case 1
              h.resolution(end+1) = deg2dms(1/1200); % DMS format: 3 arc-second spacing
          case 2
              h.resolution(end+1) = deg2dms(1/3600); % DMS format: 1 arc-second spacing
          otherwise
              h.resolution(end+1) = NaN; % DMS format: 30 arc-second spacing
          end
	  
	  sources{end+1} = 'DTED';
          h.path{length(sources)} = dtedpth{i};
          h.tiledata{end+1} = sdted;

      end
      
   end
   
end

% construct panel 

h = uiPanel(sources,h);

% Add tiles for tiled datasets
for i=1:length(sources)
   switch(sources{i})
   case 'GTOPO30'
      
      pth = h.path{i};
      s = h.tiledata{i};
      
      % check which ones are on the CD or in the directory
      d = dir(pth);
      d(~[d.isdir]) = [];
      
      tilepresent = ismember(lower({s.name}),lower({d.name}));
      
      s(~tilepresent) = [];
      
      latlim = cat(1,s.latlim);
      lonlim = cat(1,s.lonlim);
      htemp = ...
         patchesm([latlim(:,1)'; latlim(:,2)'; latlim(:,2)'; latlim(:,1)'; latlim(:,1)'], ...
         [lonlim(:,1)'; lonlim(:,1)'; lonlim(:,2)'; lonlim(:,2)'; lonlim(:,1)'],'y', ...
         'Tag','gtopo30tiles');
      zdatam(htemp,-1);restack(htemp,'bottom')
      set(htemp,'facecolor',[0.99          1.00          0.85],'edgecolor',.75*[1 1 1])
      
      h.tiles{i} = htemp;
      
   case 'GLOBE'
      
      pth = h.path{i};
      s = h.tiledata{i};
            
      latlim = cat(1,s.latlim);
      lonlim = cat(1,s.lonlim);
      htemp = ...
         patchesm([latlim(:,1)'; latlim(:,2)'; latlim(:,2)'; latlim(:,1)'; latlim(:,1)'],...
         [lonlim(:,1)'; lonlim(:,1)'; lonlim(:,2)'; lonlim(:,2)'; lonlim(:,1)'],'y',...
         'Tag','globedemtiles');%,'edgecolor',.85*[ 1 1 1]);
      zdatam(htemp,-1);restack(htemp,'bottom')
      set(htemp,'facecolor',[0.99          1.00          0.85],'edgecolor',.75*[1 1 1])
      
      h.tiles{i} = htemp;
      
   case 'DTED'
      
      pth = h.path{i};
      s = h.tiledata{i};
         
      latlim = cat(1,s.latlim);
      lonlim = cat(1,s.lonlim);
      
      htemp = ...
         patchesm([latlim(:,1)'; latlim(:,2)'; latlim(:,2)'; latlim(:,1)'; latlim(:,1)'],...
         [lonlim(:,1)'; lonlim(:,1)'; lonlim(:,2)'; lonlim(:,2)'; lonlim(:,1)'],'y',...
         'Tag','dtedtiles');%,'edgecolor',.85*[ 1 1 1]);
      zdatam(htemp,-1);restack(htemp,'bottom')
      set(htemp,'facecolor',[0.99          1.00          0.85],'edgecolor',.75*[1 1 1])
      
      h.tiles{i} = htemp;
      
   case 'SatBath'
      
      latlim = [-72 72];
      lonlim = [-180 180];
      
      lat = [latlim(:,1)'; latlim(:,2)'; latlim(:,2)'; latlim(:,1)'; latlim(:,1)'];
      lon = [lonlim(:,1)'; lonlim(:,1)'; lonlim(:,2)'; lonlim(:,2)'; lonlim(:,1)'];
      
      [lat,lon] = interpm(lat,lon,5);

      htemp = ...
         patchesm(lat,lon,'y',...
         'Tag','satbathtile');%,'edgecolor',.85*[ 1 1 1]);
      zdatam(htemp,-1);restack(htemp,'bottom')
      set(htemp,'facecolor',[0.99          1.00          0.85],'edgecolor',.75*[1 1 1])
      
      h.tiles{i} = htemp;
      
   end
   
end


h.baseobjects = get(h.axes,'Children');
set(gcf,'Userdata',h)

demdataui slider
demdataui list

liststrs = get(h.list,'String');
if isempty(liststrs); 
   msg = sprintf([
         '\n\n\nDEMDATAUI searches for high resolution digital elevation data files on the MATLAB path. ' ...
         'On some computers, DEMDATAUI will also check for data files on the root level of letter drives. ' ...
         'DEMDATAUI looks for the following data: ' ...
         '\n\nETOPO5: new_etopo5.bil or etopo5.northern.bat and etopo5.southern.bat files. ' ...
         '\n\nTBASE: tbase.bin file. ' ...
         '\n\nSATBATH: topo_6.2.img file. ' ...
         '\n\nGTOPO30: a directory that contains subdirectories with the datafiles. ' ...
         'For example, DEMDATAUI would detect GTOPO30 data if a directory on the path contained the directories E060S10 and E100S10, each of which holds the uncompressed data files. ' ...
         '\n\nGLOBEDEM: a directory that contains data files and in the subdirectory "/esri/hdr" the "*.hdr" header files. ' ...
         '\n\nDTED: a directory that has a subdirectory named DTED. ' ...
         'The contents of the DTED directory are more subdirectories organized by longitude and, below that, the DTED data files for each latitude tile. ' ...
         '\n\n\nSee the help for functions with these names for more on the data attributes and internet locations. ' ...
         'To see this information again, click the HELP button and see the entry for the list. ',...
      ]);
   
   herr = errordlg('No external DEM data found.','DEMDATAUI Error'); 
   uiwait(herr);
   warndlg(msg,'DEMDATAUI Data Sources'); 
end


set(h.fig,'HandleVis','callback')
zoom(h.fig,'on')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [foundpth,s] = gtopo30path
%GTOPO30PATH returns the path to a directory of gtopo 30 data

% read gtopo30s.dat file for filenames
filestruct(1).length = 21;     
filestruct(1).name = 'name';					
filestruct(1).type = 'char';

filestruct(2).length = 2;     
filestruct(2).name = 'latlim';					
filestruct(2).type = '%6d';

filestruct(3).length = 2;     
filestruct(3).name = 'lonlim';					
filestruct(3).type = '%6d';

filestruct(4).length = 2;     
filestruct(4).name = '';					
filestruct(4).type = 'char';

s = readfields('gtopo30s.dat',filestruct);

foundpth = unique(searchpath(s));



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [foundpth,sout] = globedempath
%GLOBEDEMPATH returns the path to a directory of GLOBEDEM data

filestruct(1).length = 4;     
filestruct(1).name = 'name';					
filestruct(1).type = 'char';

filestruct(2).length = 2;     
filestruct(2).name = 'latlim';					
filestruct(2).type = '%5d';

filestruct(3).length = 2;     
filestruct(3).name = 'lonlim';					
filestruct(3).type = '%5d';

filestruct(4).length = 2;     
filestruct(4).name = 'tilerowcol';					
filestruct(4).type = '%5d';

filestruct(5).length = 2;     
filestruct(5).name = '';					
filestruct(5).type = 'char';

% read GLOBEDEMS.dat file for filenames
s = readfields('globedems.dat',filestruct);

% Can't search for files without extensions on PCs

if strcmp(computer,'PCWIN')
   sold = s;
   for i=1:length(s)
      s(i).name = [s(i).name '.'];
   end
end

% Search the path (and for PCs, the letter drives root) for the data files
foundpth = unique(searchfile(s));

% But PC's report out file names without the extension dot, go figure
if strcmp(computer,'PCWIN')
   s = sold;
end

% for each directory found, determine which files are in there
sout = {};
if ~isempty(foundpth)
   for i = 1:length(foundpth)
      d = dir(foundpth{i});
      indx = find(ismember({s.name},{d.name}));
      sout{i} = s(indx);
   end   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function foundpth = searchfile(s)
%SEARCHFILES searche for specified directory names
%
% foundpath = SEARCHFILES(s) searches PWD, the MATLAB path and PC device 
% names for specified file names. File names are specified in 
% an arrayed structure s with the required field 'name' containing the
% names of the directories as a string. The names of the directories 
% in which the files were found are returned in foundpath.

foundpth = {};


% What's on the MATLAB path (which includes pwd)
for i=1:length(s)
   foundfiles = which('-all',s(i).name);
   for j=1:length(foundfiles)
      foundpth{end+1} = fileparts(foundfiles{j});
   end
end


% Now try all letter drives on PCs (A-Z)
if strcmp(computer,'PCWIN')
   
   for j=1:26
      
      pth = [char('A'+j-1) ':\'];
      try 
         
         d = dir(pth);
         d([d.isdir]) = [];
                  
         for i=1:length(s)
            
            if ~isempty(d) & ismember(s(i).name,lower({d.name}))
               foundpth{end+1} = pth;
            end
         end
         
      catch
         %oops, that drive didn't exist
      end
      
   end
   
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function foundpth = searchpath(s)
%SEARCHPATH searches for specified directory names
%
% foundpath = SEARCHPATH(s) searches PWD, the MATLAB path and PC device 
% names for specified directory names. Directory names are specified in 
% an arrayed structure s with the required field 'name' containing the
% names of the directories as a string.
%
% At the moment, the search is broken off upon finding a match.


% check for existence of directories of expected names

foundpth = {};

% I thought I could do 
%  if exist(s(i).name,'dir') == 7 | exist(upper(s(i).name),'dir') == 7 
% but that didn't work reliably (OK for gtopo30 when PWD, but not if on 
% path when called from here, and EXIST works OK from command line - go figure)
% Then would have had to test each directory on the path only when a match was found.
% So have to use brute force approach:
% Search through the MATLAB path to find the location of the gtopo30 directory.

% try the current working directory
pth = pwd;
d = dir(pth);
d(~[d.isdir]) = [];

for i=1:length(s)
   if ismember(s(i).name,lower({d.name}))
      foundpth{end+1} = pth;
   end
end

% try on the MATLAB path
if isempty(foundpth)
   fullpath = path;
   fullpath = [pathsep fullpath pathsep];
   indx = findstr(pathsep,fullpath);
   for j=1:length(indx)-1
      pth = fullpath(indx(j)+1:indx(j+1)-1);
      
      d = dir(pth);
      d(~[d.isdir]) = [];
      
      for i=1:length(s)
         if ~isempty(d) & ismember(s(i).name,lower({d.name}))
            foundpth{end+1} = pth;
         end
      end
   end
end      


% Now try all letter drives on PCs (A-Z)
if strcmp(computer,'PCWIN')
   
   for j=1:26
      
      pth = [char('A'+j-1) ':\'];
      try 
         
         d = dir(pth);
         d(~[d.isdir]) = [];
         for i=1:length(s)
            if ~isempty(d) & ismember(s(i).name,lower({d.name}))
               foundpth{end+1} = pth;
            end
         end
         
      catch
         %oops, that drive didn't exist
      end
      
   end
   
end

foundpth = unique(foundpth);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [foundpth] = dtedpath
%DTEDPATH returns the path to a directory of DTED data

s.name = 'dted';

foundpth = searchpath(s);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function s = dtedtiles(dtedpth)
%DTEDPATH returns the information on dted files within a given directory


if ~strcmp(dtedpth(end),filesep)
   dtedpth = [dtedpth filesep 'DTED'];
else
   dtedpth = [dtedpth 'DTED'];
end

d = dir(dtedpth);
d(~[d.isdir]) = [];

s = [];
for i=1:length(d)
   
   % look for directory names with leading w or e
   switch lower(d(i).name(1))
   case 'w'
      sgn = -1;
   case 'e'
      sgn = 1;
   otherwise
      sgn = NaN;
   end
   
   % look for directory names with trailing numbers
   lllon = str2num(d(i).name(2:end));
   if ~isnan(sgn) & ~isempty(lllon)
      
      dtedpth2 = [dtedpth filesep d(i).name];
      
      dd = dir(dtedpth2);
      dd([dd.isdir]) = [];
      
      %Look inside that directory
      for j=1:length(dd)
         
         switch lower(dd(j).name(1))
         case 's'
            sgn2 = -1;
         case 'n'
            sgn2 = 1;
         otherwise
            sgn2 = NaN;
         end
         
         % look for file names with trailing numbers
         [path,name,ext,ver] = fileparts(dd(j).name(2:end));
         
         lllat = str2num(name);
         if ~isempty(lllat) & length(ext)==4 & strcmp(lower(ext(2:3)),'dt')
            
            s(end+1).latlim = [sgn2*lllat sgn2*lllat+1];
            s(end).lonlim   = [sgn*lllon sgn*lllon+1];
            s(end).level    = str2num(ext(end));   
            
         end
         
      end
      
   end
      
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function h = uiPanel(sources,h)
%UIPANEL constructs the UI panel



% Build the GUI panel


%  Create the dialog window

h.fig = figure('Color',[0.8 0.8 0.8], ...
    'units','character',...
	'Position', [7.1805    1.7261  114.8882   33.1408],...
   'Tag','DEMDATAUI','DoubleBuffer','on','Visible','off',...
   'Menubar','none','Name','DEMDATAUI','NumberTitle','off');

colordef(h.fig,'white');
figclr = get(h.fig,'Color');
frameclr = brighten(figclr,0.5);

h.list = uicontrol('Style','list','units','Normalized',...
   'Position',[.02 .15 .15 .77],'Max',1,...
   'Interruptible','off','BackgroundColor','w',...
   'String',sources,'Callback','demdataui list');

h.selected = 1;

h.listlabel = uicontrol('Style','text','Units','normalized',...
   'Position',[0.05 0.93 0.1 .03],'String','Source  ', ...
   'FontWeight','bold','backgroundColor',get(h.fig,'Color'));

h.axeslabel = uicontrol('Style','text','Units','normalized',...
   'Position',[0.5 0.93 0.2 .03],'String','Geographic Limits  ', ...
   'FontWeight','bold','backgroundColor',get(h.fig,'Color'));

h.sliderlabel = uicontrol('Style','text','Units','normalized',...
   'Position',[0.14 0.93 0.2 .03],'String','Samplefactor  ', ...
   'FontWeight','bold','backgroundColor',get(h.fig,'Color'));


h.slider = uicontrol('Style','Slider','Units','Normalized',...
   'Position',[0.213 0.15 0.04 0.77],'Min',1,'Max',100,'Value',1,...
   'SliderStep',[.01/0.99 0.20/0.99],...
   'backgroundColor',get(h.fig,'Color'),'Callback','demdataui slider');

h.slidervalue = uicontrol('Style','text','Units','normalized',...
   'Position',[0.218 0.23 0.03 .03],'String','1','HorizontalAlignment','Center');

%.23 min, 0.81 max

% buttons

	h.helpbtn = uicontrol('Parent',h.fig, ...
	'Units','normalized', ...
	'Position',0.8415*[0.05 0.03 .14 0.1], ...
	'Style','push', ...
	'String','Help', ...
   'Tag','helpbtn',...
   'Callback','demdataui help',...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

	h.clearbtn = uicontrol('Parent',h.fig, ...
	'Units','normalized', ...
	'Position',0.8415*[0.05+3*0.15 0.03 .14 0.1], ...
	'Style','push', ...
	'String','Clear', ...
	'Tag','clearbtn',...
    'Callback','demdataui clear',...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

	h.getbtn = uicontrol('Parent',h.fig, ...
	'Units','normalized', ...
	'Position',0.8415*[0.05+1*0.15 0.03 .14 0.1], ...
	'Style','push', ...
	'String','Get', ...
	'Tag','getbtn',...
   'Callback','demdataui get',...
   'Interruptible','on',...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

	h.savebtn = uicontrol('Parent',h.fig, ...
	'Units','normalized', ...
	'Position',0.8415*[0.05+5*0.15 0.03 .14 0.1], ...
	'Style','push', ...
	'String','Save', ...
	'Tag','getbtn',...
     'Callback','demdataui save',...
	'BackgroundColor',frameclr, 'ForegroundColor','black');

	h.closebtn = uicontrol('Parent',h.fig, ...
	'Units','normalized', ...
	'Position',0.8415*[0.05+6*0.15 0.03 .14 0.1], ...
	'Style','push', ...
	'String','Close', ...
    'Callback','demdataui close',...
	'Tag','getbtn',...
	'BackgroundColor',frameclr, 'ForegroundColor','black');


% Overview map

h.axes = axes('units','normalized',...
	'Position',[.3 .15 .65 .7],...
	'Tag','samplemapaxes');
    
    

% base map data
axesm('pcarree')
tightmap

framem;
zdatam('frame',-2);
set(handlem('alltext'),'clipping','on')
displaym(worldlo('POline'));
set(handlem('International Boundary'),'Color',[1.0000    0.5741    0.5845])
set(handlem('Coastline'),'Color',.65*[1 1 1])

displaym(worldlo('DNline'))
clmo 'Streams,rivers,channelized rivers'
set(handlem('Inland shorelines'),'Color',.65*[1 1 1])


displaym(usalo('stateborder'))
set(handlem('StateBorder'),'Color',.65*[1 1 1],'Linestyle','-')

zdatam('allline',-.75)
zdatam('International Boundary',0.75)
zdatam('StateBorder',0.75)

zoom




% make figure resizeable

set([...
    h.helpbtn,...
    h.clearbtn,...
    h.getbtn,...
    h.savebtn,...
    h.closebtn,...
    h.axes],'units','normalized')
    
set([...
    h.helpbtn,...
    h.clearbtn,...
    h.getbtn,...
    h.savebtn,...
    h.closebtn,...
    ],'fontunits','normalized')
    

% initialize saved VMAP data
h.extracteddata = [];

set(h.fig,'userdata',h,'Visible','on')

set(gcf,'windowbuttonmotionfcn','demdataui axeswatchcursor;demdataui slider')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function axeswatchcursor

% AXESWATCHCURSOR changes the cursor to a magnifying glass over the demdata

if  strcmp(get(gcf,'tag'),'demdata') &  ~isempty(get(overobj('axes')))
    magcursor = [
                   NaN   NaN   NaN   NaN     1     1     1     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
                   NaN   NaN     1     1     1   NaN   NaN     1     1     1   NaN   NaN   NaN   NaN   NaN   NaN
                   NaN     1     1   NaN   NaN   NaN   NaN   NaN   NaN     1     1   NaN   NaN   NaN   NaN   NaN
                   NaN     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     1   NaN   NaN   NaN   NaN   NaN
                     1     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     1     1   NaN   NaN   NaN   NaN
                     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     1   NaN   NaN   NaN   NaN
                     1     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     1     1   NaN   NaN   NaN   NaN
                   NaN     1   NaN   NaN   NaN   NaN   NaN   NaN   NaN     1     1   NaN   NaN   NaN   NaN   NaN
                   NaN     1     1   NaN   NaN   NaN   NaN   NaN   NaN     1   NaN   NaN   NaN   NaN   NaN   NaN
                   NaN   NaN     1     1     1   NaN   NaN     1     1     1     1   NaN   NaN   NaN   NaN   NaN
                   NaN   NaN   NaN   NaN     1     1     1     1   NaN     1     1     1   NaN   NaN   NaN   NaN
                   NaN   NaN   NaN   NaN   NaN     1   NaN   NaN   NaN   NaN     1     1     1   NaN   NaN   NaN
                   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     1     1     1   NaN   NaN
                   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     1     1     1   NaN
                   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     1     1     1
                   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN     1     1
                ];

    set(gcf,'pointer','custom','PointerShapeCdata',magcursor,'PointerShapeHotSpot',[7 7])
    
else

    set(gcf,'pointer','arrow')
 end
 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uisave
%UISAVE saves data to a MAT-File or workspace

h = get(get(gcbo,'Parent'),'userdata');

if isempty(h.extracteddata)
   warndlg('No data to save','DEMDATAUI warning')
   return
end

answer = questdlg('Save data to a Mat-file or the base workspace?', ...
   'DEMDATAUI Save',...
   'Mat-File','Workspace','Cancel','Mat-file');

switch answer
case 'Mat-File'
   uifilesave(h.extracteddata)
case 'Workspace'
   uiworkspacesave(h.extracteddata)
case 'Cancel' 
   return
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function uiworkspacesave(extracteddata)

done = 0;
while ~done
   answer=inputdlg({'Name of saved data in base workspace'},'DEMDATAUI SAVE',1,{'demdata'});
   if ~isempty(answer)
      try
         assignin('base',answer{1},extracteddata)
         done = 1;
      catch
         h = errordlg(lasterr,'DEMDATAUI SAVE ERROR','modal');
         uiwait(h)
      end
   else
      return
   end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function uifilesave(data)

curpwd = pwd;
[filename,pathname] = uiputfile('*.mat', 'Save the data in MAT-file:');

if filename == 0
   return
end

answer=inputdlg({'Name of saved data in MAT-file'},'DEMDATAUI SAVE',1,{'demdata'});
answer = answer{1};

done = 0;
while ~done
   if ~isempty(answer)
      try
         eval([answer ' = data;'])
         save([pathname filename],answer)
         done = 1;
      catch
         errordlg(lasterr,'DEMDATAUI SAVE ERROR','modal')
      end
   else
      return
   end
end


cd(curpwd)
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function uiclose
%UICLOSE closes the UI panel

h = get(get(gcbo,'Parent'),'userdata');
close(gcbf)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function uihelp

% UIHELP displays help text for DEMDATAUI


helpstr = { ...
      [],...
      [],['OVERVIEW'],[], ...
      [ ...
         'The DEMDATAUI screen lets you read data from a variety of high-resolution Digital Elevation Maps (DEMs). ' ...
         'These DEMs range in resolution from about 10 kilometers to 100 meters or less. ' ...
         'The data files are available over the internet at no cost, or (in some cases) on CD-ROMs for varying fees. ' ...
      ],[],[ ...
         'You use the list to select the source of data and the map to select the region of interest. ' ...
         'When you click the GET button, data is extracted and displayed on the map. ' ...
         'Use the SAVE button to save the data in a MAT-file or to the base workspace for later display. ' ...
         'The CLOSE button closes the window.' ...
         '' ...
         '' ...
         '' ...
      ],[],[],['THE MAP'],[],[ ...
         'The map controls the geographic extent of the data to be extracted. ' ...
         'DEMDATAUI extracts data for areas currently visible on the map. ' ...
         'Use the mouse to zoom in or out to the area of interest. ' ...
         'Type HELP ZOOM for more on zooming. ' ...
      ],[],[ ...
         'Some data sources divide the world up into tiles. ' ...
         'When extracting, data is concatenated across all visible tiles. ' ...
         'The map shows the tiles in light yellow with light gray edges. ' ...
         'When data resolution is high, extracting data for large area may take much time and memory.' ...
         'An approximate count of the number of points is shown above the map. ' ...
         'Use the SAMPLEFACTOR slider to reduce the amount of data. ' ...
      ],[],[],['THE LIST'],[],[ ...
         'The list controls the source of data to be extracted. ' ...
         'Click on a name to see the geographic coverage in light yellow. ' ...
         'The sources list shows which data sources were found when DEMDATAUI started. ' ...
      ],[],[ ...
         'DEMDATAUI searches for data files on the MATLAB path. ' ...
         'On some computers, DEMDATAUI will also check for data files on the root level of letter drives. ' ...
         'DEMDATAUI looks for the following data: ' ...
         'ETOPO5: new_etopo5.bil or etopo5.northern.bat and etopo5.southern.bat files. ' ...
         'TBASE: tbase.bin file. ' ...
         'SATBATH: topo_6.2.img file. ' ...
         'GTOPO30: a directory that contains subdirectories with the datafiles. ' ...
         'For example, DEMDATAUI would detect GTOPO30 data if a directory on the path contained the directories E060S10 and E100S10, each of which holds the uncompressed data files. ' ...
         'GLOBEDEM: a directory that contains data files and in the subdirectory "/esri/hdr" the "*.hdr" header files. ' ...
         'DTED: a directory that has a subdirectory named DTED. ' ...
         'The contents of the DTED directory are more subdirectories organized by longitude and, below that, the DTED data files for each latitude tile. ' ...
         'See the help for functions with these names for more on the data attributes and internet locations. ' ...
      ],[],[],['SAMPLEFACTOR SLIDER'],[],[ ...
         'The SAMPLEFACTOR slider allows you to reduce the density of the data. ' ...
         'A sample factor of 2 returns every second point. ' ...
         'The current sample factor is shown on the slider. ' ...
      ],[],[],['GET BUTTON'],[],[ ...
         'The GET button reads the currently selected data and displays it on the map. ' ...
         'Press the standard interrupt key combination for your platform to interrupt the process. ' ...
      ],[],[],['CLEAR BUTTON'],[],[ ...
         'The CLEAR button removes any previously read data from the map. ' ...
      ],[],[],['SAVE BUTTON'],[],[ ...
         'The SAVE button saves the currently displayed data to a Mat-file or the base workspace. ' ...
         'If you choose to save to a file, you will be prompted for a file name and location. ' ...
         'If you choose to save to the base workspace, you you can choose the variable name that will be overwritten. ' ...
         'The results are stored as a geographic data structure. ' ...
         'Use LOAD and DISPLAYM to redisplay the data from a file on a map axes. ' ...
         'To display the data in the base workspace, use DISPLAYM. ' ...
         'To gain access to the data matrices, subscript into the structure (e.g. map = demdata(1).map; maplegend = demdata(1).maplegend_ ' ...
         'Use WORLDMAP to create easy displays of the elevation data (e.g. WORLDMAP(map,maplegend,''ldem3d'')). ' ...
         'Use MESHM to add regular matrix maps to existing displays, or SURFM or a similar function for general matrix maps (e.g. MESHM(map,maplegend) or SURFM(latgrat,longrat,map)). ' ...
      ],[],[],['CLOSE BUTTON'],[],[ ...
         'The CLOSE button closes the DEMDATAUI panel ' ...
      ]} ...
   ;


h.fig = figure('Visible','on','Units','character','Position',[5 5 80 40],'Resize','off','Menubar','none','Name','DEMDATAUI Help','NumberTitle','off');
h.list = uicontrol('Style','list','units','normalized','position',[.1 .15 .7 .8],'BackgroundColor','w','SelectionHighlight','off');
helpstr = textwrap(h.list,helpstr);

% make room for scrollbar
set(h.list,'String',helpstr,'Position',[.1 .15 .8 .8],'ListboxTop',2)
h.button = uicontrol('Style','push','Units','Character','Position',[35 2 10 2],'String','Close','Callback','close(gcbf)');



