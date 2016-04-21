function varargout = vmap0data(varargin)
%VMAP0DATA Read selected data from the Vector Map Level 0 CD-ROMs.
%
% struc = VMAP0DATA(library,latlim,lonlim,theme,topolevel) reads the data
% for the specified theme and topology level directly from the named VMAP0
% CD-ROM. There are four CD's, one each for the library: 'NOAMER' (North
% America), 'SASAUS' (Southern Asia and Australia), 'EURNASIA' (Europe and
% Northern Asia) and 'SOAMAFR' (South America and Africa). The desired
% theme is specified by a two letter code string.  A list of valid codes
% will be displayed when an invalid code, such as '?', is entered.  The
% region of interest can be given as a point latitude and longitude or as a
% region with two-element vectors of latitude and longitude limits.  The
% units of latitude and longitude are degrees. The data covering the
% requested region is returned, but will include data extending to the
% edges of the tiles.  The result is returned as a Mapping Toolbox
% Geographic Data Structure.
%
% VMAP0DATA(devicename,library,latlim,...) specifies the logical device
% name of the CD-ROM for computers which do not automatically name the
% mounted disk.
%
% [struc1, struc2, ...]  = ...
% VMAP0DATA(library,latlim,lonlim,theme,{topolevel1,topolevel2,...}) reads
% several topology levels.  The levels must be specified as a cell array
% with the entries 'patch', 'line', 'point' or 'text'.  Entering {'all'}
% for the topology level argument is equivalent to {'patch', 'line',
% 'point','text'}. Upon output, the data are returned in the output
% arguments by topology level in the same order as they were requested.
%
% struc = VMAP0DATA(...,layer) returns selected layers within a theme.  A
% list of valid layers will be displayed when an invalid code, such  as
% '?', is entered. Layers are specified as strings or a cell array  of
% strings.
%
% struc = VMAP0DATA(...,layer,{'prop1',val1,'prop2',val2,...}) returns 
% only those elements that match the specified properties and values 
% within a layer. The list of requested properties and values is provided
% as a cell array. A list of valid properties will be displayed when an 
% invalid code, such as '?', is entered. Likewise, valid values are 
% displayed when invalid properties are entered. All properties are
% specified  as strings. Values may be integers, strings, or to match
% multiple values,  cell arrays of integers or strings.  VMAP0 CD-ROMs are
% available from 
% 
%  USGS Information Services (Map and Book Sales)
% 	Box 25286
% 	Denver Federal Center
% 	Denver, CO 80225
% 	Telephone: (303) 202-4700
% 	Fax: (303) 202-4693
%   http://mapping.usgs.gov/esic/cdrom/cdlist.html
%
% See also VMAP0UI, VMAP0READ, VMAP0RHEAD, MLAYERS, DISPLAYM, EXTRACTM.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:24:06 $

%  Written by:  W. Stumpf

% warnings with [PPpatch,PPline,PPpoint,PPtext] = vmap0data('SOAMAFR',[0 8],[0 6],'pop','all')


% check for valid inputs

featuretable = [];
property = [];
if nargin == 5
   library = varargin{1};
   latlim = varargin{2};
   lonlim = varargin{3};
   theme = varargin{4};
   topolevel = varargin{5};
   devicename = 'VMAP';
elseif nargin == 6
   devicename = varargin{1};
   library = varargin{2};
   latlim = varargin{3};
   lonlim = varargin{4};
   theme = varargin{5};
   topolevel = varargin{6};
elseif nargin == 7
   devicename = varargin{1};
   library = varargin{2};
   latlim = varargin{3};
   lonlim = varargin{4};
   theme = varargin{5};
   topolevel = varargin{6};
   featuretable = varargin{7};
elseif nargin == 8
   devicename = varargin{1};
   library = varargin{2};
   latlim = varargin{3};
   lonlim = varargin{4};
   theme = varargin{5};
   topolevel = varargin{6};
   featuretable = varargin{7};
   property = varargin{8};
else
   error('Incorrect number of input arguments')
end

%  Test the inputs

if  isequal(size(latlim),[1 1])
   latlim = latlim*[1 1];
elseif ~isequal(sort(size(latlim)),[1 2])
   error('Latitude limit input must be a scalar or 2 element vector')
end

if isequal(size(lonlim),[1 1])
   lonlim = lonlim*[1 1];
elseif ~isequal(sort(size(lonlim)),[1 2])
   error('Longitude limit input must be a scalar or 2 element vector')
end

%  Test for real inputs

if any([~isreal(latlim) ~isreal(lonlim)])
   warning('Imaginary parts of complex arguments ignored')
   latlim = real(latlim);   lonlim = real(lonlim);
end

%  Check for valid topology level inputs

if isstr(topolevel) & strcmp(topolevel,'all'); topolevel = {'all'}; end

if isstr(topolevel)
   
   topoindx = strmatch(topolevel,{'patch','line','point','text'},'exact');
   if isempty(topoindx); error('Valid topology levels are ''patch'', ''line'', ''point'' or ''text'' ');end
   if nargout ~= 1
      error('Number of output arguments doesn''t match requested topology levels')
   end
   
elseif iscell(topolevel)
   
   if length(topolevel)==1 & strcmp(topolevel,'all');
      topolevel = {'patch','line','point','text'};
   end
   
   topoindx = [];
   
   for i=1:length(topolevel)
      if ~isstr(topolevel{i}); error('Topology level must be a cell array of strings'); end
      thistopoindx = strmatch(topolevel{i},{'patch','line','point','text'},'exact');
      if isempty(thistopoindx); error('Topology level must be ''patch'', ''line'', ''point'' or ''text'' ');end
      topoindx = [topoindx thistopoindx];
   end % for
   
   topoindx = unique(topoindx);
   if length(topoindx) ~=length(topolevel)
      error('Redundant requests in topology levels')
   elseif nargout ~= length(topoindx)
      error('Number of outputs doesn''t match requested topology levels')
   end
else
   error('Topology level must be a string or cell array of strings')
end % if

for i=1:nargout
   varargout(i) = {[]};
end %for

% Check that the top of the database file heirarchy is visible,
% and note the case of the directory and filenames.

filepath = fullfile(devicename,filesep);
dirstruc = dir(filepath);
if isempty(strmatch('VMAPLV0',upper(strvcat(dirstruc.name)),'exact'))
   error(['VMAP Level 0 disk not mounted or incorrect devicename ']); 
end

if ~isempty(strmatch('VMAPLV0',{dirstruc.name},'exact'))
   filesystemcase = 'upper';
elseif ~isempty(strmatch('vmaplv0',{dirstruc.name},'exact'))
   filesystemcase = 'lower';
else
   error('Unexpected mixed case filenames')
end

% check feature table inputs
if (~(isempty(featuretable)))
   if (~ischar(featuretable) & (~iscellstr(featuretable)))
      error('Feature Table Inputs must be strings or cell strings')
   end
end

%check property/value inputs
if ~isempty(property)
   if (mod(length(property), 2) ~= 0)
      error('Properties must be in pairs: { property1 {value[s]} property2 {value[s]} ... }')
   end
   f = 1:2:length(property);
   if ~iscellstr(property(f))
      error('Property Names must be Strings')
   end
   g = 2:2:length(property);
   if ~isa(property(g), 'double') & ~ischar(property(g)) & ~iscellstr(property(g)) & ~iscell(property(g))
      error ('Property Values must be doubles, strings or cell arrays of double/strings')
   end
end

% build the pathname so that [pathname filename] is the full filename

switch filesystemcase
case 'upper'
   filepath = fullfile(devicename,'VMAPLV0',upper(library),filesep);
case 'lower'
   filepath = fullfile(devicename,'vmaplv0',lower(library),filesep);
end

dirstruc = dir(filepath);
if isempty(dirstruc)
   error(['VMAP Level 0 disk ' upper(library) ' not mounted or incorrect devicename ']); 
end

% check for valid theme request

CAT = vmap0read(filepath,'CAT');

if isempty(strmatch(theme,{CAT.coverage_name},'exact'))
   
   linebreak = double(sprintf('\n'));
   goodthemes = [str2mat(CAT.coverage_name) ...
         char(58*ones(length(CAT),1)) ...
         char(32*ones(length(CAT),1)) ...
         str2mat(CAT.description) ...
         char(linebreak*ones(length(CAT),1)) ];
   goodthemes = goodthemes';
   goodthemes = goodthemes(:);
   goodthemes = goodthemes';
   
   error(['Theme not present in library ' library char(linebreak) char(linebreak) ...
         'Valid theme identifiers are: ' char(linebreak) ...
         goodthemes ...
   ])
end

% BROWSE layer is untiled

if strcmp(lower(library),'rference')
   dotiles = 1;
   tFT(1).tile_name = '';
   tFT(1).fac_id = 1;
else
   
   % Get the essential libref information (tile name/number, bounding boxes)
   
   switch filesystemcase
   case 'upper'
      filepath = fullfile(devicename,'VMAPLV0',upper(library),'TILEREF',filesep);
   case 'lower'
      filepath = fullfile(devicename,'vmaplv0',lower(library),'tileref',filesep);
   end
   
   tFT = vmap0read(filepath,'TILEREF.AFT');
   FBR = vmap0read(filepath,'FBR');
   
   % find which tiles are fully or partially covered by the desired region
   
   dotiles = vmap0do(FBR,latlim,lonlim)	;
   
end

% Here is where the value description and feature tables reside

switch filesystemcase
case 'upper'
   themepath = fullfile(devicename,'VMAPLV0',upper(library),upper(theme),filesep);
case 'lower'
   themepath = fullfile(devicename,'vmaplv0',lower(library),lower(theme),filesep);
end

% get a list of files in the requested directory

dirstruc = dir(themepath);
names = {dirstruc.name};
names = uppercell(names); % because pc converts to lowercase

% read the Integer Value Description Table. This contains the integer
% values used to distinguish between types of features using integer keys

VDT = [];
if any(strcmp(uppercell(names),'INT.VDT'))==1
   VDT = vmap0read(themepath,'INT.VDT');
end


% read the Character Value Description Table if present.
% This contains the character values used to distinguish
% between types of features using character keys

cVDT = [];
if any(strcmp(uppercell(names),'CHAR.VDT'))==1
   cVDT = vmap0read(themepath,'CHAR.VDT');
end


% loop over points, lines, text
% handle faces separately

FACstruct = [];
EDGstruct = [];
ENDstruct = [];
TXTstruct = [];

%hwt = waitbar(0,'Working');
%starttime = now;
%hfig = figure;


for i=1:length(dotiles)
   
   %   waitbar(i/length(dotiles),hwt)
   %   starttime(end+1)=now;
   %   timeperstep = diff(starttime);
   %   if i <= 10;
   %      avetimeperstep = mean(timeperstep);
   %   else
   %      avetimeperstep = mean(timeperstep(end-10:end));
   %   end
   %   
   %   endtime = now + avetimeperstep*(length(dotiles)-i);
   %   set(get(get(hwt,'children'),'title'),'string',['Expected completion time: ' datestr(endtime,14)])
   %   
   %   figure(hfig);
   %   plot(starttime(1:end-1),timeperstep)
   %   datetick('x',14)
   %   
   %   
   %   drawnow
   
   FAC = [];
   EDG = [];
   END = [];
   TXT = [];
   SYM = [];
   
   
   % extract pathname
   % replace directory separator with the one for current platform
   
   tileid = find(dotiles(i)==[tFT.fac_id]);
   
   tilepath = tFT(tileid).tile_name;
   tilepath = [ strrep(tilepath,'\',filesep) filesep];
   
   switch filesystemcase
   case 'upper'
      tilepath = upper(tilepath);
   case 'lower'
      tilepath = lower(tilepath);
   end
   
   tilepath = [themepath tilepath];
   tilepath = strrep(tilepath,[filesep filesep],filesep); % for the Browse library
   
   dirstruc = dir(tilepath);
   tilenames = {dirstruc.name};
   tilenames = uppercell(tilenames);
   
   %
   % loop over feature topology level
   %
   
   for j=1:4
      
      %
      % construct the feature table name. We know it will be of form
      % '**'POINT.PFT', etc.
      %
      switch j
         % Patch
      case 1
         
         if any(topoindx ==1)
            
            EntityName =  'FAC';
            
            wildcard = '*.AFT';
            if strcmp(filesystemcase,'lower'); wildcard = lower(wildcard); end
            
            FTfilenames = dir([themepath wildcard]);
            
            if (~isempty(featuretable))
               FTfilenames = vmappatchft(featuretable, FTfilenames, topolevel, wildcard, themepath, theme);
            end
            
            
            if isempty(FTfilenames) |  ~(any(strmatch(EntityName,tilenames))==1)
               % 					warning('No patch data for this theme')
            else
               
               for k=1:length(FTfilenames)
                  
                  FTfilename = FTfilenames(k).name;
                  
                  if isempty(EDG); 
                     EDGname =  'EDG';
                     EDG = vmap0read(tilepath,EDGname);
                  end
                  
                  FACstruct = vmap0factl(themepath,tilepath,FTfilename,FACstruct,VDT,cVDT,EDG, property);
                  if ~isempty(FACstruct);
                     varargout(find(topoindx ==1))  = {FACstruct};
                  end
                  
               end % do k				
               
            end % if
            
         end % if
         
         % Line		
      case 2
         
         if any(topoindx ==2)
            
            EntityName =  'EDG';
            
            wildcard = '*.LFT';
            if strcmp(filesystemcase,'lower'); wildcard = lower(wildcard); end
            
            FTfilenames = dir([themepath wildcard]);
            
            if (~isempty(featuretable))
               FTfilenames = vmaplineft(featuretable, FTfilenames, topolevel, wildcard, themepath, theme);   
            end
            
            if isempty(FTfilenames) |  ~(any(strmatch(EntityName,tilenames))==1)
               %				   warning('No line data for this theme')
            else
               for k=1:length(FTfilenames)
                  FTfilename = FTfilenames(k).name;
                  
                  if isempty(EDG); EDG = vmap0read(tilepath,EntityName); end
                  
                  EDGstruct = vmap0edgtl(themepath,tilepath,FTfilename,EDGstruct,VDT,cVDT,EntityName,EDG, property);
                  
                  if ~isempty(EDGstruct);
                     varargout(find(topoindx ==2)) = {EDGstruct};
                  end
                  
               end % do k				
               
            end % if
            
         end % if
         
         % Point
         
      case 3
         
         if any(topoindx ==3)
            
            EntityName =  'END'; %new CND contains unique information?
            
            wildcard = '*.PFT';
            if strcmp(filesystemcase,'lower'); wildcard = lower(wildcard); end
            
            FTfilenames = dir([themepath wildcard]);
            
            if (~isempty(featuretable))
               FTfilenames = vmappointft(featuretable, FTfilenames, topolevel, wildcard, themepath, theme);
            end
            
            if isempty(FTfilenames) |  ~(any(strmatch(EntityName,tilenames))==1)
               % 					warning('No point data for this theme')
            else
               
               for k=1:length(FTfilenames)
                  
                  FTfilename = FTfilenames(k).name;
                  
                  if isempty(END); END = vmap0read(tilepath,EntityName); end
                  
                  EDGstruct = vmap0endtl(themepath,tilepath,FTfilename,EDGstruct,VDT,cVDT,EntityName,END,property);
                  if ~isempty(EDGstruct);
                     varargout(find(topoindx ==3)) = {EDGstruct};
                  end
               end % do k			
               
            end % if
            
         end % if
         % Text			
      otherwise
         
         if any(topoindx ==4)
            EntityName =  'TXT';
            
            % check for and read SYMBOL.RAT file, which contains font sizes and colors
            
            SymbolName =  'SYMBOL.RAT';
            if strcmp(filesystemcase,'lower'); SymbolName = lower(SymbolName); end
            SymbolDirListing = dir([themepath SymbolName]);
            if length(SymbolDirListing) ~= 0
               SYM = vmap0read(themepath,SymbolName); 
            end
            
            wildcard = '*.TFT';
            if strcmp(filesystemcase,'lower'); wildcard = lower(wildcard); end
            
            FTfilenames = dir([themepath wildcard]);
            
            if (~isempty(featuretable))
               FTfilenames = vmaptextft(featuretable, FTfilenames, topolevel, wildcard, themepath, theme);
            end
            
            if isempty(FTfilenames) | ~(any(strmatch(EntityName,tilenames))==1)
               % 					warning('No text data for this theme')
            else
               
               for k=1:length(FTfilenames)
                  
                  FTfilename = FTfilenames(k).name;
                  
                  if isempty(TXT); TXT = vmap0read(tilepath,EntityName); end
                  
                  TXTstruct = vmap0txttl(themepath,tilepath,TXTstruct,cVDT,FTfilename,TXT,SYM, property);
                  if ~isempty(TXTstruct);
                     varargout(find(topoindx ==4)) = {TXTstruct};
                  end
               end % do k				
               
            end % if textdata
            
         end % if topoindx
         
      end % switch
      
   end % for j
   
end %for i

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function carray = uppercell(carray)
%UPPERCELL converts a cell array of strings to uppercase

for i=1:length(carray);carray{i} = upper(carray{i});end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [savelat,savelong] = vmap0gbfac(facenum,EDG,FAC,RNG)
%VMAP0GFAC builds a Digital Chart of the World Browse layer face from its edges

if facenum ==1;
   
   % outer ring of the universe face cannot be displayed
   
   savelat = [];
   savelong = [];
   return
end

ringptrs = find([RNG.face_id]==facenum);

savelat = [];
savelong = [];
for i=1:length(ringptrs)
   
   checkface = RNG(ringptrs(i)).face_id;
   if checkface ~= facenum; warning('Face and Ring tables inconsistent');return; end
   
   startedge = RNG(ringptrs(i)).start_edge;
   
   [lat,long] = vmap0gbrng(EDG,startedge,facenum);
   
   if isempty(savelat)
      savelat = lat;
      savelong = long;
   else
      savelat = [savelat;NaN;lat];
      savelong = [savelong;NaN;long];
   end
   
end

% [savelat,savelong] = polycut(savelat,savelong);

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [savelat,savelong] = vmap0gbrng(EDG,startedge,facenum)

if nargin ~= 3
   error('Incorrect number of arguments')
end


% Follow face until we end up where we started. If left and right face
% are identical, use left/right edges to break the tie; if that's not
% unambiguous, use start/end nodes

llchunk = EDG(startedge).coordinates;

if  EDG(startedge).right_face(1) == facenum
   nextedge = EDG(startedge).right_edge(1);  % stay on this tile
   savelat = llchunk(:,2);
   savelong = llchunk(:,1);
elseif EDG(startedge).left_face(1) == facenum
   nextedge = EDG(startedge).left_edge(1);
   savelat  = flipud(llchunk(:,2));
   savelong = flipud(llchunk(:,1));
else
   warning('Error following face.');return
end % if

lastedge=startedge;
lastnodes = [EDG(startedge).start_node(1)  ...
      EDG(startedge).end_node(1)  ];

while ~(nextedge == startedge)
   
   curnodes = [EDG(nextedge).start_node EDG(nextedge).end_node];
   
   llchunk = EDG(nextedge).coordinates;
   lat=llchunk(:,2);
   long=llchunk(:,1);
   
   rface = EDG(nextedge).right_face(1);
   lface = EDG(nextedge).left_face(1);
   
   if lface == rface
      
      % Breaking tie with nextedge
      
      if EDG(nextedge).right_edge(1) == nextedge
         
         savelat = [savelat;lat;flipud(lat)];
         savelong = [savelong;long;flipud(long)];
         lastedge = nextedge;
         nextedge = EDG(nextedge).left_edge(1);
         
      elseif EDG(nextedge).left_edge(1) == nextedge
         
         savelat = [savelat;flipud(lat);lat];
         savelong = [savelong;flipud(long);long];
         lastedge = nextedge;
         nextedge = EDG(nextedge).right_edge(1);  %stay on this tile
         
      else
         
         % Breaking tie with nodes
         
         starttest = find(curnodes(1) == lastnodes);
         endtest = find(curnodes(2) == lastnodes);
         
         if isempty(starttest) & ~isempty(endtest)
            
            savelat = [savelat;flipud(lat)];
            savelong = [savelong;flipud(long)];
            nextedge = EDG(nextedge).left_edge(1);
            
         elseif ~isempty(starttest) & isempty(endtest)
            
            savelat = [savelat;lat];
            savelong = [savelong;long];
            nextedge = EDG(nextedge).right_edge(1);  % stay on this tile
            
         else
            warning('Error following face..')
            return
            
         end % if
      end % if
      
   elseif rface == facenum
      savelat = [savelat;lat];
      savelong = [savelong;long];
      lastedge = nextedge;
      nextedge = EDG(nextedge).right_edge(1);  % stay on this tile
   elseif lface == facenum
      savelat = [savelat;flipud(lat)];
      savelong = [savelong;flipud(long)];
      lastedge = nextedge;
      nextedge = EDG(nextedge).left_edge(1);
   else
      warning('Error following face...')
      return
   end % if
   
   nextedge = nextedge(1);
   lastnodes = curnodes;
   
end % while

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function struc = vmap0edgtl(themepath,tilepath,FTfilename,struc,VDT,cVDT,EntityName,ET, property)

% Read the feature table and the entity table. The feature table contains
% the integer feature type. The entity file contains the coordinates.

if isempty(ET); return; end

etfields = fieldnames(ET); % match fieldnames to current entity table

endofword = find(~isletter(FTfilename))-1;
matchthis = lower(FTfilename(1:endofword));
ftfieldindx = strmatch(matchthis,etfields); % which lft_id field goes with the current feature table filename

% verify that there are some references to a feature table ID. Some data (germany, point trans)
% is missing the pft_id field in the Entity Table.
extension = lower(FTfilename(min(endofword+2,end):end));
ftids = findstrmat(str2mat(etfields{:}),extension,'findstr');

if isempty(ftfieldindx) % field name doesn't match what was expected for key
   if isempty(ftids)
      indx = 1:length(ET); % must be in browse layer, so there are no tiles, and we want all elements
   else
      return % missing feature table id field in entity table when others are present. Interpret this as an error in file format
   end
else
   eval(['indx = [ET.' etfields{ftfieldindx} '];']) % retrieve only elements in this tile
   ET = ET( indx > 0 );
   indx = indx(indx > 0); % These are the keys into the various feature tables. Positive ones go with the current feature table
   if isempty(indx); return; end % all of the LFT indices are keys into other LFT tables, so nothing to extract
end

[FT, FTfield]  = vmap0read(themepath,FTfilename, indx );

if (~isempty(property))
   [FT, ET] = PropertyMatch(property, FT, ET, themepath, FTfilename, VDT, cVDT);
end

%
% find which fields of the feature table contain integer keys, text or values, for
% extraction as a tag. Later try to expand the text fields using the character value 
% description table (char.vdt). 
%

ftfields = fieldnames(FT);

FTindx = strmatch('int.vdt',{FTfield.VDTname}); 	% fields that are indices into the integer value description table


% Assume that 'crv' field is only occurance of a value. All other descriptive fields are 
% keys into integer or character description tables.

valfieldIDs = strmatch('crv',ftfields);

textfieldIDs = strmatch('T',{FTfield.type},'exact'); % into fields of FT

%
% Find out how many feature types we have by getting the indices
% into the feature table relating to the current topological entity
% (edge). Look for integer description keys, values, and text

valmat = [];
vdtfieldIDs = [];


if ~isempty(FTindx) % have integer feature, so gather  a matrix of the value combos
   
   valmat = [];
   
   for i=1:length(FTindx)
      
      eval(['valvec = [ FT.' ftfields{FTindx(i)} ']'' ;' ])
      valmat = [valmat valvec];
      
   end % for
   
   
end % if


% don't include VAL fields if they are keys into VDT?

valfieldIDs = valfieldIDs(find(~ismember( valfieldIDs, vdtfieldIDs)));

if  ~isempty(valfieldIDs) % have value fields, so gather them
   
   cells = struct2cell(FT);
   
   featvalvec = [cells{valfieldIDs,:}] ;
   featvalmat = reshape(featvalvec, length(valfieldIDs), length(featvalvec)/length(valfieldIDs));
   VALfeatvalmat = featvalmat';
   
   valmat = [valmat VALfeatvalmat];
end

if  ~isempty(textfieldIDs) % no integer feature, so depend on text strings in feature table. Only expect one.
   
   for i=1:length(textfieldIDs);
      eval(['strs = str2mat(FT.' ftfields{textfieldIDs(i)}	');']);
      valmat = [valmat double(strs)];
   end % for
   
end

[uniquecombos,cindx1,cindx2] = unique(valmat,'rows');
ncombos = size(cindx1,1);

%
% Extract the data
%

warned = 0;

i=length(struc);
for j=1:ncombos
   
   indx = find(cindx2==j);
   
   description = descript(valfieldIDs,textfieldIDs,ftfields,indx,FT,FTfield,FTindx,FTfilename,cVDT,VDT);
   
   struc(i+1).type= 'line';
   struc(i+1).otherproperty= {};
   struc(i+1).altitude= [];
   
   ll = [];
   for k=1:length(indx)
      llchunk = ET(indx(k)).coordinates;
      llchunk = llchunk(:,1:2); % for some reason we now have a trailing column of NaNs
      ll = [ll; NaN NaN; llchunk];
   end % for k
   
   
   struc(i+1).lat=ll(:,2);
   struc(i+1).long=ll(:,1);
   struc(i+1).tag=deblank(leadblnk(description));
   
   i=i+1;
   
   
end; %for j


return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [struc,EDG] = vmap0factl(themepath,tilepath,FTfilename,struc,VDT,cVDT,EDG,property)

% read the feature table and the entity table. The feature table has in
% it the integer feature type and (optionally?) the name of the feature.
% The entity file contains the coordinates.

FAC = vmap0read(tilepath,'FAC');
RNG = vmap0read(tilepath,'RNG');


etfields = fieldnames(FAC); % assume name of key into feature table is second field

endofword = find(~isletter(FTfilename))-1;
matchthis = lower(FTfilename(1:endofword));
ftfieldindx = strmatch(matchthis,etfields); % which lft_id field goes with the current feature table filename

% verify that there are some references to a feature table ID. Some data (germany, point trans)
% is missing the pft_id field in the Entity Table.
extension = lower(FTfilename(min(endofword+2,end):end));
ftids = findstrmat(str2mat(etfields{:}),extension,'findstr');

if isempty(ftfieldindx) % field name doesn't match what was expected for key
   if isempty(ftids)
      indx = 1:length(FAC); % must be in browse layer, so there are no tiles, and we want all elements
   else
      return % missing feature table id field in entity table when others are present. Interpret this as an error in file format
   end
else
   eval(['indx = [FAC.' etfields{ftfieldindx} '];']) % retrieve only elements in this tile
   FAC = FAC( indx > 0 );
   indx = indx(indx > 0); % These are the keys into the various feature tables. Positive ones go with the current feature table
   if isempty(indx); return; end % all of the FT indices are keys into other FT tables, so nothing to extract
end

[FT, FTfield]  = vmap0read(themepath,FTfilename,indx );

% check to see if property/value given
if (~isempty(property))
   ET = [];
   ET = FAC;
   [FT, ET] = PropertyMatch(property, FT, ET, themepath, FTfilename, VDT, cVDT);
   FAC = ET;
end

%
% find which fields of the feature table contain integer keys, text or values, for
% extraction as a tag. Later try to expand the text fields using the character value 
% description table (char.vdt). 
%

ftfields = fieldnames(FT);
FTindx = strmatch('int.vdt',{FTfield.VDTname}); 	% fields that are indices into the integer value description table


% Assume that 'crv' field is only occurance of a value. All other descriptive fields are 
% keys into integer or character description tables.

valfieldIDs = strmatch('crv',ftfields);
textfieldIDs = strmatch('T',{FTfield.type},'exact'); % into fields of FT


%
% Find out how many feature types we have by getting the indices
% into the feature table relating to the current topological entity
% (edge). Look for integer description keys, values, and text

valmat = [];
vdtfieldIDs = [];


if ~isempty(FTindx) % have integer feature, so gather  a matrix of the value combos
   
   valmat = [];
   
   for i=1:length(FTindx)
      
      eval(['valvec = [ FT.' ftfields{FTindx(i)} ']'' ;' ])
      valmat = [valmat valvec];
      
   end % for
   
   
end % if


% don't include VAL fields if they are keys into VDT

valfieldIDs = valfieldIDs(find(~ismember( valfieldIDs, vdtfieldIDs)));

if  ~isempty(valfieldIDs) % have value fields, so gather them
   
   cells = struct2cell(FT);
   
   featvalvec = [cells{valfieldIDs,:}] ;
   featvalmat = reshape(featvalvec, length(valfieldIDs), length(featvalvec)/length(valfieldIDs));
   VALfeatvalmat = featvalmat';
   
   valmat = [valmat VALfeatvalmat];
end

if  ~isempty(textfieldIDs) % no integer feature, so depend on text strings in feature table. Only expect one.
   
   for i=1:length(textfieldIDs);
      eval(['strs = str2mat(FT.' ftfields{textfieldIDs(i)}	');']);
      valmat = [valmat double(strs)];
   end % for
   
end

[uniquecombos,cindx1,cindx2] = unique(valmat,'rows');
ncombos = size(cindx1,1);

%
% Extract the data
%

warned = 0;

i=length(struc);
for j=1:ncombos
   
   indx = find(cindx2==j);
   description = descript(valfieldIDs,textfieldIDs,ftfields,indx,FT,FTfield,FTindx,FTfilename,cVDT,VDT);
   
   for k=1:length(indx)
      
      [lat,long] = vmap0gbfac(FT(indx(k)).fac_id,EDG,FAC,RNG)   ;        % different
      
      if ~isempty(lat)
         
         struc(i+1).type= 'patch';                 % different
         struc(i+1).otherproperty= {};             % different
         
         struc(i+1).altitude= [];
         
         struc(i+1).lat=lat;
         struc(i+1).long=long;
         
         struc(i+1).tag=description;
         
         i=i+1;
         
      end %if
   end % for k
   
end; %for j

return


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function struc = vmap0endtl(themepath,tilepath,FTfilename,struc,VDT,cVDT,EntityName,ET,property)

% Read the feature table and the entity table. The feature table contains
% the integer feature type. The entity file contains the coordinates.

etfields = fieldnames(ET); % match fieldnames to current entity table

endofword = find(~isletter(FTfilename))-1;
matchthis = lower(FTfilename(1:endofword));
ftfieldindx = strmatch(matchthis,etfields); % which pft_id field goes with the current feature table filename

% verify that there are some references to a feature table ID. Some data (germany, point trans)
% is missing the pft_id field in the Entity Table.
extension = lower(FTfilename(min(endofword+2,end):end));
ftids = findstrmat(str2mat(etfields{:}),extension,'findstr');

if isempty(ftfieldindx) % field name doesn't match what was expected for key
   if isempty(ftids)
      indx = 1:length(ET); % must be in browse layer, so there are no tiles, and we want all elements
   else
      return % missing feature table id field in entity table when others are present. Interpret this as an error in file format
   end
else
   eval(['indx = [ET.' etfields{ftfieldindx} '];']) % retrieve only elements in this tile
   ET = ET( indx > 0 );
   indx = indx(indx > 0); % These are the keys into the various feature tables. Positive ones go with the current feature table
   if isempty(indx); return; end % all of the LFT indices are keys into other LFT tables, so nothing to extract
end

[FT, FTfield]  = vmap0read(themepath,FTfilename, indx  );


if (~isempty(property))
   [FT, ET] = PropertyMatch(property, FT, ET, themepath, FTfilename, VDT, cVDT);
end

%
% find which fields of the feature table contain integer keys, text or values, for
% extraction as a tag. Later try to expand the text fields using the character value 
% description table (char.vdt). 
%

ftfields = fieldnames(FT);

FTindx = strmatch('int.vdt',{FTfield.VDTname}); 	% fields that are indices into the integer value description table


% Assume that 'crv' field is only occurance of a value. All other descriptive fields are 
% keys into integer or character description tables.

valfieldIDs = strmatch('crv',ftfields);

textfieldIDs = strmatch('T',{FTfield.type},'exact'); % into fields of FT

%
% Find out how many feature types we have by getting the indices
% into the feature table relating to the current topological entity
% (edge). Look for integer description keys, values, and text

valmat = [];
vdtfieldIDs = [];


if ~isempty(FTindx) % have integer feature, so gather  a matrix of the value combos
   
   valmat = [];
   
   for i=1:length(FTindx)
      
      eval(['valvec = [ FT.' ftfields{FTindx(i)} ']'' ;' ])
      valmat = [valmat valvec];
      
   end % for
   
   
end % if


% don't include VAL fields if they are keys into VDT?

valfieldIDs = valfieldIDs(find(~ismember( valfieldIDs, vdtfieldIDs)));

if  ~isempty(valfieldIDs) % have value fields, so gather them
   
   cells = struct2cell(FT);
   
   featvalvec = [cells{valfieldIDs,:}] ;
   featvalmat = reshape(featvalvec, length(valfieldIDs), length(featvalvec)/length(valfieldIDs));
   VALfeatvalmat = featvalmat';
   
   valmat = [valmat VALfeatvalmat];
end

if  ~isempty(textfieldIDs) % no integer feature, so depend on text strings in feature table. Only expect one.
   
   for i=1:length(textfieldIDs);
      
      eval(['indx = find(strcmp('''',{FT.' ftfields{textfieldIDs(i)} '}));' ] ) % empty strings
      if ~isempty(indx) & length(indx) < length(FT)
         for j=indx
            eval(['FT(j).' ftfields{textfieldIDs(i)} '= ''no string provided'';' ] ) % empty strings
         end
      end
      
      eval(['strs = str2mat(FT.' ftfields{textfieldIDs(i)}	');']);
      valmat = [valmat double(strs)];
   end % for
   
end

[uniquecombos,cindx1,cindx2] = unique(valmat,'rows');
ncombos = size(cindx1,1);

%
% Extract the data
%

warned = 0;

i=length(struc);
for j=1:ncombos
   
   indx = find(cindx2==j);
   
   description = descript(valfieldIDs,textfieldIDs,ftfields,indx,FT,FTfield,FTindx,FTfilename,cVDT,VDT);
   
   struc(i+1).type= 'line';
   struc(i+1).otherproperty= {};
   struc(i+1).altitude= [];
   
   ll = [];
   for k=1:length(indx)
      llchunk = ET(indx(k)).coordinate;
      llchunk = llchunk(:,1:2); % for some reason we now have a trailing column of NaNs
      ll = [ll; NaN NaN; llchunk];
   end % for k
   
   
   struc(i+1).lat=ll(:,2);
   struc(i+1).long=ll(:,1);
   struc(i+1).tag=deblank(leadblnk(description));
   
   i=i+1;
   
   
end; %for j


return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function struc = vmap0txttl(themepath,tilepath,struc,cVDT,FTfilename,ET,SYM,property)


% read the feature table and the entity table. The feature table has in
% it the integer feature type and (optionally?) the name of the feature.
% The entity file contains the coordinates.

etfields = fieldnames(ET); % assume name of key into feature table is second field

endofword = find(~isletter(FTfilename))-1;
matchthis = lower(FTfilename(1:endofword));
ftfieldindx = strmatch(matchthis,etfields); % which lft_id field goes with the current feature table filename

if ftfieldindx % field name doesn't match what was expected for key
   indx = 1:length(ET); % must be in browse layer, so there are no tiles, and we want all elements
else
   eval(['indx = [ET.' etfields{ftfieldindx} '];']) % retrieve only elements in this tile
end


[FT,FTfield]  = vmap0read(themepath,FTfilename,indx);

if (~isempty(property))
   [FT, ET] = PropertyMatch(property, FT, ET, themepath, FTfilename, VDT, cVDT);
end


%
% find out how many feature types we have by getting the indices
% into the feature table relating to the current topological entity
% (point, edge, face)
%


FTindx = strmatch(lower(FTfilename),{cVDT.table}); 	% the indices of the entries in the VDT pertinent to the current topology level

if isempty(FTindx)
   return % No appropriate Feature Table entry in Value Description Table
end

cVDT = cVDT(FTindx);
values = str2mat(cVDT.value);

symcodes = [SYM.symbol_id];


i=length(struc);
for j=1:length(FT)
   
   struc(i+1).type= 'text';
   
   indx = strmatch(FT(j).f_code,values,'exact');
   
   struc(i+1).tag=deblank(cVDT(indx).description);
   struc(i+1).string=deblank(ET(j).string);
   struc(i+1).altitude= [];
   
   
   
   ll = ET(j).shape_line;
   
   
   struc(i+1).lat=ll(1,2);
   struc(i+1).long=ll(1,1);
   
   symindx = find(symcodes == FT(j).symbol_id);
   properties = {'fontsize',SYM(symindx(1)).size}; % FT(j).symbol_id not unique?
   
   switch SYM(symindx(1)).col % FT(j).symbol_id not unique?
   case 1
      properties = { properties{:},'color','k'};
   case 4
      properties = { properties{:},'color','b'};
   case 9	
      properties = { properties{:},'color','r'};
   case 12
      properties = { properties{:},'color','m'};
   end	
   
   if length(ll(:,1)) > 1
      
      dx = ll(2,1) - ll(1,1);
      dy = ll(2,2) - ll(1,2);
      ang = 180/pi*(atan2(dy,dx));
      properties = { properties{:},'rotation',ang};
      
   end %if
   
   struc(i+1).otherproperty= properties;
   
   i=i+1;
   
end; %for j

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function description = descript(valfieldIDs,textfieldIDs,ftfields,indx,FT,FTfield,FTindx,FTfilename,cVDT,VDT)

% build up description codes

description = '';

% extract integer based descriptions	

for k = 1:length(FTindx)
   
   
   fieldname = ftfields{FTindx(k)};
   
   eval(['val = FT(indx(1)).' fieldname	';']);
   strng = num2str(val);
   
   tableindx = strmatch(lower(FTfilename), {VDT.table});
   fieldindx = strmatch(fieldname, {VDT.attribute});
   valueindx = find(val == [VDT.value]);
   VDTindx = intersect(tableindx, intersect(fieldindx,valueindx));
   
   if ~isempty(VDTindx)
      strng = VDT(VDTindx(1)).description;
      if strmatch(strng,'Unknown')  % expand labels of things with value unknown, 
         strng = [ FTfield(FTindx(k)).description ': ' strng];
      end
   end
   
   description = [description '; ' deblank(strng)];
   
end %k

%  Extract text-based descriptions. In the VMAP0, it seems that all text is used 
%  as keys into the character description table. Look the text strings up in that
%  table, being careful to extract the correct occurance of duplicate codes. 

if ~isempty(textfieldIDs) 
   
   for k = length(textfieldIDs):-1:1
      
      fieldname = ftfields{textfieldIDs(k)};
      
      eval(['strng = FT(indx(1)).' fieldname	';']);
      
      if ~isempty(cVDT)
         tableindx = strmatch(lower(FTfilename), {cVDT.table});
         fieldindx = strmatch(fieldname, {cVDT.attribute});
         valueindx = strmatch(strng,{cVDT.value});
         cVDTindx = intersect(tableindx, intersect(fieldindx,valueindx));
         
         if ~isempty(cVDTindx)
            strng = cVDT(cVDTindx(1)).description;
         end
      end
      
      description = [description '; ' deblank(strng)];
      
   end % for k
   
end %  ~isempty(textfieldIDs)

% extract value fields

if ~isempty(valfieldIDs) % have contour values 
   
   for k = 1:length(valfieldIDs)
      
      eval(['val = FT(indx(1)).' ftfields{valfieldIDs(k)}	';']);
      description = [description '; ' num2str(val)];
      
   end %k
   
end % ~isempty(valfieldIDs)


description = description(3:length(description));


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
end

%*********************************************************************
%*********************************************************************
%*********************************************************************

function ErrorValues(prop, VDT, cVDT, FTfilename,s, VDTmatch, cVDTmatch)

val = [];
valdescript = [];
goodvalues = [];

% Check if non-matching values are in Value or Character Description Table
if isempty(cVDTmatch)
   
   % Find values for appropriate feature table
   tabmatch = strmatch(lower(FTfilename), {VDT.table});
   VDTmatch = intersect(VDTmatch, tabmatch);
   val = {VDT(VDTmatch).value};
   val = ([val{:}]);
   
   if (~isa(val, 'double'))
      val = str2mat(val);
   else
      val = num2str(val(:));
   end
   
   if (isempty(VDTmatch))
      error('No Valid Values for property');
   end
   
   valdescript = str2mat({VDT(VDTmatch).description});
   valsize = length(val);
else
   if (isempty(cVDTmatch))
      error('No Valid Values for property')
   end
   
   % Find values for appropriate feature table
   tabmatch = strmatch(lower(FTfilename), {cVDT.table});
   cVDTmatch = intersect(cVDTmatch, tabmatch);
   
   if iscellstr({cVDT(cVDTmatch).value})
      if (length({cVDT(cVDTmatch).value}) == 1)
         temp = {cVDT(cVDTmatch).value};
         val = str2mat(temp(:));
      else
         val = str2mat({cVDT(cVDTmatch).value});
      end                          
   else
      val = str2mat({cVDT(cVDTmatch).value});
   end
   
   if (length(unique({cVDT(cVDTmatch).value})) == 1)
      valdescript = str2mat(unique({cVDT(cVDTmatch).description}));
   else
      valdescript = str2mat({cVDT(cVDTmatch).description});
   end
   
   [m,n] = size(valdescript);
   valsize = m;
end

%Print error msg
linebreak = double(sprintf('\n'));
goodvalues = [val ...
      char(58*ones(valsize,1)) ...
      char(32*ones(valsize,1)) ...
      valdescript ...
   char(linebreak*ones(valsize,1)) ];
goodvalues = goodvalues';
goodvalues = goodvalues(:);
goodvalues = goodvalues';

error(['Invalid Value for property ' prop.name{s} char(linebreak) char(linebreak) ...
      'Valid values are: ' char(linebreak) ...
      goodvalues ...
]);      

%*********************************************************************
%*********************************************************************
%*********************************************************************

function [FT, ET] = PropertyMatch(property, FT, ET, themepath, FTfilename, VDT, cVDT)

% Extract property names and values from orginal format and place elements into 
% corresponding struct fields
propvalue = [];
for t = 1:2:(length(property) - 1)
   prop.name{(t+1)/2} = property{t};
   prop.value{(t+1)/2} = property{t + 1};
end


% Check for valid property names
if ~all(ismember(prop.name, fieldnames(FT)))
   headerstr = vmap0rhead(themepath,FTfilename);
   [field,varlen,description,narrativefile] =  vmap0phead(headerstr);
   
   linebreak = double(sprintf('\n'));
   goodprop = [str2mat(fieldnames(FT)) ...
         char(58*ones(length({field.description}),1)) ...
         char(32*ones(length({field.description}),1)) ...
         str2mat({field.description}) ...
         char(linebreak*ones(length({field.description}),1)) ];
   goodprop = goodprop';
   goodprop = goodprop(:);
   goodprop = goodprop';
   
   error(['Property not present in theme ' FTfilename char(linebreak) char(linebreak) ...
         'Valid property identifiers are: ' char(linebreak) ...
         goodprop ...
   ])
end

% loop over multiple properties
for s = 1:length(prop.name)
   
   % Get matching values from Value and Character Description Tables
   VDTpropmatch = strmatch({prop.name{s}}, {VDT.attribute});
   cVDTpropmatch = strmatch({prop.name{s}}, {cVDT.attribute});
   
   % Get the indices of entries associated with the current feature table
   VDTftmatch = strmatch(lower(FTfilename), {VDT.table});
   cVDTftmatch = strmatch(lower(FTfilename), {cVDT.table});
   
   % Which entries is the value description tables match 
   % both the property name and the feature table name
   VDTmatch = intersect(VDTpropmatch, VDTftmatch);
   cVDTmatch = intersect(cVDTpropmatch , cVDTftmatch);
   
   % Index out match Value and Character Description Table entries
   newVDT = VDT(VDTmatch);
   newcVDT = cVDT(cVDTmatch);
   
   % get values from feature table
   if (~iscellstr(prop.value) & ~ischar(prop.value{s}) & ~iscellstr(prop.value{s}))
      eval(['propvalue = [FT.' prop.name{s} '];']);
   else
      eval(['propvalue = {FT.' prop.name{s} '};']);
   end
   
   % check value type of cell array double and extract index values for feature table
   if((length(prop.value{s}) > 1 & length(prop.value(s)) > 1) | iscell(prop.value{s})) & (~iscellstr(prop.value) & ~iscellstr(prop.value{s}))      
      for i = 1:length(prop.value{s})
         match{s}{i} = find(prop.value{s}{i} == [newVDT.value]);
         
         % Check for valid property values
         if isempty(match{s}{i})
            ErrorValues(prop, VDT, cVDT, FTfilename,s, VDTmatch, cVDTmatch);
         end
         
         %Get matching feature table index values
         F{s}{i} = find(prop.value{s}{i} == propvalue(:));
      end
      
      T{s} = [];
      
      % Get union(s) of property values if more than one is entered
      for j = 1:(length(prop.value{s}))
         T{s} = union(F{s}{j}, T{s});
      end
      
      %Get matching feature table index values
      F{s} = T{s};
   else
      if(iscellstr(prop.value)) | (iscellstr(prop.value{s}))
         if ~iscellstr(propvalue)
            propvalue = {'****'};
         end
         
         % perform string/cell string operations to retrieve matching feature table index values
         if(iscellstr(prop.value))
            
            % Check for valid property values
            if ~all(ismember(lower(prop.value(s)), lower({newcVDT.value})))
               ErrorValues(prop, VDT, cVDT, FTfilename,s, VDTmatch, cVDTmatch);
            end
            
            %Get matching feature table index values
            F{s} = find(ismember(lower(propvalue),lower(prop.value)));
         else
            if(iscellstr(prop.value(s)))
               match{s} = strmatch(lower(prop.value(s)), lower({newcVDT.value}));
               
               % Check for valid property values
               if isempty(match{s})
                  ErrorValues(prop, VDT, cVDT, FTfilename,s, VDTmatch, cVDTmatch);
               end
               
               %Get matching feature table index values
               F{s} = strmatch(lower(prop.value(s)), lower(propvalue));
            else
               
               ismem = ismember(lower(prop.value{s}), lower({newcVDT.value}));
               
               % Check for valid property values               
               if ~all(ismem)
                  ErrorValues(prop, VDT, cVDT, FTfilename,s, VDTmatch, cVDTmatch);
               end
               
               %Get matching feature table index values
               F{s} = find(ismember(lower(propvalue),lower(prop.value{s})));
               
            end
         end
      else
         match{s} = find(prop.value{s} == [newVDT.value]);
         
         % Check for valid property values
         if isempty(match{s})
            ErrorValues(prop, VDT, cVDT, FTfilename,s, VDTmatch, cVDTmatch);
         end
         
         % Get matching feature table index values
         F{s} = find(prop.value{s} == propvalue);
      end
   end
end

if(s > 1)
   a = [];
   MutualUnion = F{1};
   
   for n = 2:(length(prop.name))
      MutualUnion = union(MutualUnion, F{n});
   end
   
   a = MutualUnion;
else
   a = F{1};
end

% Index out matching values from feature and entity tables
FT = FT(a);
ET = ET(a);

%*********************************************************************
%*********************************************************************
%*********************************************************************

function FTfilenames = vmappatchft(featuretable, FTfilenames, topolevel, wildcard, themepath, theme)

feature = {strcat(featuretable, wildcard(2:length(wildcard)))};
names = strrep({FTfilenames.name}, '.AFT', '');
errorCHK = 0;
descript = [];

% Get file header information for feature table descriptions
for j=1:length(FTfilenames)
   headerstr = vmap0rhead(themepath,FTfilenames(j).name);
   [field,varlen,description,narrativefile] =  vmap0phead(headerstr);
   descript{j} = strrep(description,' Area Feature Table','');
end

% Match inputed feature table with feature tables from appropriate layer
if (ischar(feature{1}))
   [a,b,match] = intersect(lower(feature), lower({FTfilenames.name}));
   if (isempty(match))
      errorCHK = 1;
   end
else
   [a,b,match] = intersect(lower(feature{1}), lower({FTfilenames.name}));
   if ((length(match) ~= length(feature{1})) & (ischar(topolevel))) | isempty(match)
      errorCHK = 1;
   end
end

% Printing error
if (errorCHK == 1)
   linebreak = double(sprintf('\n'));
   goodFTs = [str2mat(lower(names)) ...
         char(58*ones(length(names),1)) ...
         char(32*ones(length(names),1)) ...
         str2mat(descript) ...
         char(linebreak*ones(length(names),1)) ];
   goodFTs = goodFTs';
   goodFTs = goodFTs(:);
   goodFTs = goodFTs';
   
   error(['Patch Feature Table not present in theme ' theme char(linebreak) char(linebreak) ...
         'Valid layer identifiers are: ' char(linebreak) ...
         goodFTs ...
   ])   
else
   tempFTfilenames = FTfilenames(match);
end

% Index out matching feature tables
FTfilenames = tempFTfilenames;

%*********************************************************************
%*********************************************************************
%*********************************************************************

function FTfilenames = vmaplineft(featuretable, FTfilenames, topolevel, wildcard, themepath, theme)

feature = {strcat(featuretable, wildcard(2:length(wildcard)))};
names = strrep({FTfilenames.name}, '.LFT', '');
errorCHK = 0;
descript = [];

% Get file header information for feature table descriptions
for j=1:length(FTfilenames)
   headerstr = vmap0rhead(themepath,FTfilenames(j).name);
   [field,varlen,description,narrativefile] =  vmap0phead(headerstr);
   descript{j} = strrep(description,' Line Feature Table','');
end

% Match inputed feature table with feature tables from appropriate layer
if (ischar(feature{1}))
   [a,b,match] = intersect(lower(feature), lower({FTfilenames.name}));
   if (isempty(match))
      errorCHK = 1;
   end
else
   [a,b,match] = intersect(lower(feature{1}), lower({FTfilenames.name}));
   if ((length(match) ~= length(feature{1})) & (ischar(topolevel))) | isempty(match)
      errorCHK = 1;
   end
end

% Printing error
if (errorCHK == 1)
   linebreak = double(sprintf('\n'));
   goodFTs = [str2mat(lower(names)) ...
         char(58*ones(length(names),1)) ...
         char(32*ones(length(names),1)) ...
         str2mat(descript) ...
         char(linebreak*ones(length(names),1)) ];
   goodFTs = goodFTs';
   goodFTs = goodFTs(:);
   goodFTs = goodFTs';
   
   error(['Line Feature Table not present in theme ' theme char(linebreak) char(linebreak) ...
         'Valid layer identifiers are: ' char(linebreak) ...
         goodFTs ...
   ])
else
   tempFTfilenames = FTfilenames(match);
end

% Index out matching feature tables
FTfilenames = tempFTfilenames;

%*********************************************************************
%*********************************************************************
%*********************************************************************

function FTfilenames = vmappointft(featuretable, FTfilenames, topolevel, wildcard, themepath, theme)

feature = {strcat(featuretable, wildcard(2:length(wildcard)))};
names = strrep({FTfilenames.name}, '.PFT', '');
errorCHK = 0;
descript = [];

% Get file header information for feature table descriptions
for j=1:length(FTfilenames)
   headerstr = vmap0rhead(themepath,FTfilenames(j).name);
   [field,varlen,description,narrativefile] =  vmap0phead(headerstr);
   descript{j} = strrep(description,' Point Feature Table','');
end

% Match inputed feature table with feature tables from appropriate layer
if (ischar(feature{1}))
   [a,b,match] = intersect(lower(feature), lower({FTfilenames.name}));
   if (isempty(match))
      errorCHK = 1;
   end
else
   [a,b,match] = intersect(lower(feature{1}), lower({FTfilenames.name}));
   if ((length(match) ~= length(feature{1})) & (ischar(topolevel))) | isempty(match)
      errorCHK = 1;
   end
end

% Printing error
if (errorCHK == 1)
   linebreak = double(sprintf('\n'));
   goodFTs = [str2mat(lower(names)) ...
         char(58*ones(length(names),1)) ...
         char(32*ones(length(names),1)) ...
         str2mat(descript) ...
         char(linebreak*ones(length(names),1)) ];
   goodFTs = goodFTs';
   goodFTs = goodFTs(:);
   goodFTs = goodFTs';
   
   error(['Point Feature Table not present in theme ' theme char(linebreak) char(linebreak) ...
         'Valid layer identifiers are: ' char(linebreak) ...
         goodFTs ...
   ])
else
   tempFTfilenames = FTfilenames(match);
end

% Index out matching feature tables
FTfilenames = tempFTfilenames;

%*********************************************************************
%*********************************************************************
%*********************************************************************

function FTfilenames = vmaptextft(featuretable, FTfilenames, topolevel, wildcard, themepath, theme)

feature = {strcat(featuretable, wildcard(2:length(wildcard)))};
names = strrep({FTfilenames.name}, '.TFT', '');
errorCHK = 0;
descript = [];

% Get file header information for feature table descriptions
for j=1:length(FTfilenames)
   headerstr = vmap0rhead(themepath,FTfilenames(j).name);
   [field,varlen,description,narrativefile] =  vmap0phead(headerstr);
   descript{j} = strrep(description,' Text Feature Table','');
end

% Match inputed feature table with feature tables from appropriate layer
if (ischar(feature{1}))
   [a,b,match] = intersect(lower(feature), lower({FTfilenames.name}));
   if (isempty(match))
      errorCHK = 1;
   end
else
   [a,b,match] = intersect(lower(feature{1}), lower({FTfilenames.name}));
   if ((length(match) ~= length(feature{1})) & (ischar(topolevel))) | isempty(match)
      errorCHK = 1;
   end
end

% Printing error
if (errorCHK == 1)
   linebreak = double(sprintf('\n'));
   goodFTs = [str2mat(lower(names)) ...
         char(58*ones(length(names),1)) ...
         char(32*ones(length(names),1)) ...
         str2mat(descript) ...
         char(linebreak*ones(length(names),1)) ];
   goodFTs = goodFTs';
   goodFTs = goodFTs(:);
   goodFTs = goodFTs';
   
   error(['Text Feature Table not present in theme ' theme char(linebreak) char(linebreak) ...
         'Valid layer identifiers are: ' char(linebreak) ...
         goodFTs ...
   ])
else
   tempFTfilenames = FTfilenames(match);
end

% Index out matching feature tables
FTfilenames = tempFTfilenames;
