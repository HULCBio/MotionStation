function [map,maplegend,UHL,DSI,ACC] = dted(varargin)
%DTED Read U.S. Department of Defense Digital Terrain Elevation Data (DTED) data.
%
%  [MAP, MAPLEGEND] = DTED returns all of the elevation data in a DTED file
%  as  a regular matrix map with elevations in meters.  The file is
%  selected  interactively.  This function reads the DTED elevation files,
%  which  generally have filenames ending in ".dtN", where N is 0,1,2,3,...
%
%  [MAP, MAPLEGEND] = DTED(FILENAME) returns all of the elevation data in
%  the  specified DTED file.  The file must be found on the MATLAB path.
%  If not  found, the file may be selected interactively.
%
%  [MAP, MAPLEGEND] = DTED(FILENAME, SCALEFACTOR) returns data from the 
%  specified DTED file, downsampled by the scalefactor.  If omitted, a 
%  scalefactor of 1 is assumed.
% 
%  [MAP, MAPLEGEND] = DTED(FILENAME, SCALEFACTOR, LATLIM, LONLIM) reads the
%  data  for the part of the DTED file within the latitude and longitude
%  limits.   The limits must be two-element vectors in units of degrees. 
%
%  [MAP, MAPLEGEND] = DTED(DIRNAME, SCALEFACTOR, LATLIM, LONLIM) reads and 
%  concatenates data from multiple files within a DTED CD-ROM or directory 
%  structure. The dirname input is a string with the name of a directory 
%  containing the DTED directory. Within the DTED directory are
%  subdirectories for each degree of longitude, each of which contain files
%  for each degree  of latitude. For DTED CD-ROMs, dirname is the device
%  name of the CD-ROM  drive. 
%
%  [MAP, MAPLEGEND, UHL, DSI, ACC] = DTED(...)  also returns the DTED User
%  Header  Label (UHL), Data Set Identification (DSI) and ACCuracy metadata
%  records  as structures.
%
%  Official documentation describing the meaning of the DTED metadata
%  records is available online at 
%      http://www.nima.mil/publications/specs/printed/DTED/dted1-2.doc
%  A third-party description of the DTED data may be found at
%      http://www.fas.org/irp/program/core/dted.htm
%
%  DTED files contain digital elevation maps covering 1 by 1 degree 
%  quadrangles at horizontal resolutions ranging from about 1 kilometer to
%  1  meter.  The 1 kilometer data is available online at 
%      http://www.nima.mil/geospatial/products/DTED/dted.html 
%  The higher resolution data is available to the U.S. Department of
%  Defense  and its contractors from the National Imagery and Mapping
%  Agency (NIMA).
%
%  The DTED files are binary.  No line ending conversion or byte swapping
%  is  required.
%
%  See also DTEDS, USGSDEM, GTOPO30, TBASE, ETOPO5.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $ $Date: 2003/08/01 18:20:53 $

if nargin < 1; 
    [map,maplegend,UHL,DSI,ACC] = dtedf; 
    return
end

name = varargin{1};
if exist(name,'dir') == 7
   if nargin < 4
      error('Latlim and lonlim required for directory calling form')
   end
  [map,maplegend,UHL,DSI,ACC] = dtedc(varargin{:});
else
   [map,maplegend,UHL,DSI,ACC] = dtedf(varargin{:});
end

   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [map,maplegend,UHL,DSI,ACC] = dtedc(rd,samplefactor,latlim,lonlim)


%DTEDC concatenate adjacent DTED tiles

% The edges of of adjacent files contain redundant data

% DTED format specification document: http://164.214.2.59/publications/specs/printed/DTED/dted1-2.doc

% this function for DTED files delivered on CD-ROM

% DTED0 is 120x120
% DTED1 is 1201x1201
%
% except at higher latitudes, where there are fewer longitude records

% add file separator to root directory if necessary
switch rd(end)
case {filesep}
otherwise, rd = [rd filesep];
end

% error checking for input arguments

if nargin < 1; error('Incorrect number of input arguments'); end
if nargin < 2; samplefactor = 1; end
if nargin < 3; latlim = []; end
if nargin < 4; lonlim = []; end

% get the warning state
warnstate = warning;
warning off

% If request just touches edge of the next tile, don't read it

if mod(latlim(2),1) == 0; latlim(2) = latlim(2)-epsm('deg'); end
if mod(lonlim(2),1) == 0; lonlim(2) = lonlim(2)-epsm('deg'); end

% round the limits since DTED is read in 1 deg x 1 deg square tiles
latmin = floor(latlim(1));
latmax = floor(latlim(2));
lonmin = floor(lonlim(1));
lonmax = floor(lonlim(2));

% define columns and rows for tiles to be read
uniquelons = [lonmin:lonmax];
uniquelats = [latmin:latmax];
londir{length(uniquelons)} = '';
latdir{length(uniquelats)} = '';
dtedfile{length(uniquelons),length(uniquelats)} = '';

% redefine uniquelons if lonlim extends across the International Dateline
if lonmin > lonmax
	indx1 = [lonmin:179];
	indx2 = [-180:lonmax];
	uniquelons = [indx1 indx2];
end	

[latdir,londir] = dteddirs(uniquelons,uniquelats,'');

% define the file names
numberoffiles = length(uniquelats)*length(uniquelons);

% assume that all required files can be found in the default root directory
fileexist = 1;


% check to see if the files exist
levels = cell(length(uniquelons),length(uniquelats)); 
for i = 1:length(uniquelons)
   for j = 1:length(uniquelats)
      for k = 0:3;
         filename = [rd,londir{i},latdir{j} 'dt' num2str(k)];		
         if exist(filename,'file')
            dtedfile{i,j} = filename;
            levels{i,j} = k;
            break
         end
         filename(end) = '*';
         dtedfile{i,j} = filename;
      end
   end
end

% trim off requests for missing files around edges
changed = 1;
while changed
   changed = 0;
   if ~isempty(levels) & isempty([ levels{:,1} ])
      dtedfile(:,1) = [];
      levels(:,1) = [];
      changed = 1;
   end
   if ~isempty(levels) & isempty([ levels{:,end} ])
      dtedfile(:,end) = [];
      levels(:,end) = [];
      changed = 1;
   end
   if ~isempty(levels) & isempty([ levels{1,:} ])
      dtedfile(1,:) = [];
      levels(1,:) = [];
      changed = 1;
   end
   if ~isempty(levels) & isempty([ levels{end,:} ])
      dtedfile(end,:) = [];
      levels(end,:) = [];
      changed = 1;
   end
end

% Stop if missing files
if isempty(dtedfile); error('No data for requested area.'); end

level = unique([levels{:}]);
if length(level)>1
   error('Inconsistent Levels between files. Check path or CD')
end

% If the first file does not exist, determine what the maplegend would be
% if it did exist.
if exist(dtedfile{1,1}) == 0
    [map{1},maplegend{1},UHL(1,1),DSI(1,1),ACC(1,1)] =...
        readFirstNonEmpty(dtedfile,samplefactor,latlim,lonlim);
end

nrowMat = repmat(nan,size(dtedfile));  
ncolMat = nrowMat;
% read all files to compute number of rows and number of columns
for i = 1:size(dtedfile,1) 
    for j = 1:size(dtedfile,2)
        if exist(dtedfile{i,j}) ~= 0 
            tmap = dted(dtedfile{i,j},samplefactor,latlim,lonlim);  
            nrowMat(i,j) = size(tmap,1);
            ncolMat(i,j) = size(tmap,2);
        end
    end
end

% replace nans with the values required for correct concatenation
nrowMat = repmat(max(nrowMat,[],2),1,size(nrowMat,2));
ncolMat = repmat(max(ncolMat,[],1),size(ncolMat,1),1);

% read the first file (bottom left hand corner of map)
if exist(dtedfile{1,1}) ~= 0
    [map{1},maplegend{1},UHL(1,1),DSI(1,1),ACC(1,1)] = ...
        dted(dtedfile{1,1},samplefactor,latlim,lonlim);
else
    map{1} = repmat(nan,nrowMat(1,1),ncolMat(1,1));
end

% Create Structures with fields that contain no data. We'll use it if we're missing a data file.
UHLempty = UHL(1,1);
fdnames = fieldnames(UHLempty);
for i = 1:length(fdnames)
    UHLempty = setfield(UHLempty,fdnames{i},'');
end
DSIempty = DSI(1,1);
fdnames = fieldnames(DSIempty);
for i = 1:length(fdnames)
    DSIempty = setfield(DSIempty,fdnames{i},'');
end
ACCempty = ACC(1,1);
fdnames = fieldnames(ACCempty);
for i = 1:length(fdnames)
    ACCempty = setfield(ACCempty,fdnames{i},'');
end

% break out if only 1 tile is required
if all(size(dtedfile) == 1)
   nmap = map{1}; nmaplegend = maplegend{1};
   map = nmap; maplegend = nmaplegend;
   return
end	

if size(dtedfile,2) > 1
	% read remaining files in 1st column (same longitude, increasing latitudes)
	for j = 2:size(dtedfile,2)
        if exist(dtedfile{1,j}) ~= 0
			[map{j},maplegend{j},UHL(1,j),DSI(1,j),ACC(1,j)] = dted(dtedfile{1,j},samplefactor,...
                latlim,lonlim);
        else
            map{j} = repmat(nan,nrowMat(1,j),nrowMat(1,j));
            maplegend{j} = nan;
            UHL(1,j) = UHLempty;
            DSI(1,j) = DSIempty;
            ACC(1,j) = ACCempty;
        end
		map{j}(1,:) = [];
	end
	fmaplegend = maplegend{j};
else	
	fmaplegend = maplegend{1};
end

% concatenate tiles in column wise direction
tmap= [];
for j = 1:size(dtedfile,2)
	tmap = [tmap; map{j}];
end	
fmap{1} = tmap;

% clear temporary data
clear map maplegend

if size(dtedfile,1)>1
	% read remaining files for remaining columns and rows
	for k = 2:size(dtedfile,1)
        if exist(dtedfile{k,1}) ~= 0
			% read file corresponding to bottom tile in the column
			[map{1},maplegend{1},UHL(k,1),DSI(k,1),ACC(k,1)] = dted(dtedfile{k,1},samplefactor,latlim,lonlim);
        else
            map{1} = repmat(nan,nrowMat(k,1),nrowMat(k,1));
            maplegend{1} = nan;
            UHL(k,1) = UHLempty;
            DSI(k,1) = DSIempty;
            ACC(k,1) = ACCempty;
        end
		map{1}(:,1) = [];
		% read the remaining files
		for m = 2:size(dtedfile,2)
            if exist(dtedfile{k,m}) ~= 0
				[map{m},maplegend{m},UHL(k,m),DSI(k,m),ACC(k,m)] = dted(dtedfile{k,m},samplefactor,latlim,lonlim);
            else
                map{m} = repmat(nan,nrowMat(k,m),nrowMat(k,m));
                maplegend{m} = nan;
                UHL(k,m) = UHLempty;
                DSI(k,m) = DSIempty;
                ACC(k,m) = ACCempty;
            end
			map{m}(1,:) = [];
			map{m}(:,1) = [];
		end	
		% concatenate tiles in column wise direction
		tmap= [];
		for j = 1:size(dtedfile,2)
			tmap = [tmap; map{j}];
		end	
		fmap{k} = tmap;
		% clear temporary data
		clear map maplegend
	end	
else
	k = 1;
end
	
% concatenate all maps
tmap = [];
for i = 1:k
	tmap = [tmap fmap{i}];	
end
map = tmap; maplegend = fmaplegend;


% reset the warning state
warning(warnstate); 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [map,maplegend,UHL,DSI,ACC] = dtedf(filename,scalefactor,latlim,lonlim)
%DTED read U.S. Department of Defense Digital Terrain Elevation Data (DTED) data
%
%  [map,maplegend] = DTED returns all of the elevation data in a DTED file as 
%  a regular matrix map with elevations in meters.  The file is selected 
%  interactively.  This function reads the DTED elevation files, which 
%  generally have filenames ending in ".dtN", where N is 0,1,2,3,...  .
%
%  [map,maplegend] = DTED(filename) returns all of the elevation data in the 
%  specified DTED file.  The file must be found on the MATLAB path.  If not 
%  found, the file may be selected interactively.
%
%  [map,maplegend] = DTED(filename,scalefactor) returns data from the 
%  specified DTED file, downsampled by the scalefactor.  If omitted, a 
%  scalefactor of 1 is assumed.
% 
%  [map,maplegend] = DTED(filename,scalefactor,latlim,lonlim) reads the data 
%  for the part of the DTED file within the latitude and longitude limits.  
%  The limits must be two-element vectors in units of degrees.
%
%  [map,maplegend,UHL,DSI,ACC] = DTED(...)  also returns the DTED User Header 
%  Label (UHL), Data Set Identification (DSI) and ACCuracy metadata records 
%  as structures.
% 
%  Official documentation describing the meaning of the DTED metadata
%  records is available online at 
%      http://www.nima.mil/publications/specs/printed/DTED/dted1-2.doc
%  A third-party description of the DTED data may be found at
%      http://www.fas.org/irp/program/core/dted.htm
%
%  DTED files contain digital elevation maps covering 1 by 1 degree 
%  quadrangles at horizontal resolutions ranging from about 1 kilometer to 1 
%  meter.  The 1 kilometer data is available online at 
%      http://www.nima.mil/geospatial/products/DTED/dted.html 
%  The higher resolution data is available to the U.S. Department of Defense 
%  and its contractors from the National Imagery and Mapping Agency (NIMA).

%  The DTED files are binary.  No line ending conversion or byte swapping is 
%  required.
%
% See also USGSDEM, GTOPO30, TBASE, ETOPO5

%  Written by:  W. Stumpf

% The edges of of adjacent files contain redundant data

% need general matrix map output

% this function for DTED files delivered on CD-ROM

% DTED0 is 120x120
% DTED1 is 1201x1201
%
% except at higher latitudes, where there are fewer longitude records

% map extending a half a cell outside the requested map limits.

if nargin==0;
   filename = [];
   scalefactor = 1;
   latlim = [];
   lonlim = [];
elseif nargin==1
   scalefactor = 1;
   latlim = [];
   lonlim = [];
elseif nargin==2
   latlim = [];
   lonlim = [];
elseif nargin==3
   lonlim = [];
elseif nargin ~=4
   error('Incorrect number of arguments')
end

% ensure row vectors

latlim = latlim(:)';
lonlim = npi2pi(lonlim(:)'); % No effort made (yet) to work across the dateline
if ~isempty(lonlim) & lonlim(2) < lonlim(1); lonlim(2) = lonlim(2) + 360; end

% check input arguments

if ~isempty(filename) & ~isstr(filename); 			error('Filename must be a string'); end
if length(scalefactor) > 1; 						error('Scalefactor must be a scalar'); end
if ~isempty(latlim) & ~isequal([1 2],size(latlim));					error('latlim must be a two element vector in units of degrees'); end 
if ~isempty(lonlim) & ~isequal([1 2],size(lonlim)); 					error('lonlim must be a two element vector in units of degrees'); end 

% define header formats

UHLfield = UHLdescription;
DSIfield = DSIdescription;
ACCfield = ACCdescription;

% Open the file to read the header information

fid = -1;
if ~ isempty(filename); 
   fid = fopen(filename,'rb','ieee-be');
end

if fid==-1
   [filename, path] = uigetfile('*.*', 'Please select the DTED file');
   if filename == 0 ; return; end
   filename = [path filename];
   fid = fopen(filename,'rb','ieee-be');
end

% Define the header format, and read the header records


UHLfield = UHLdescription;
DSIfield = DSIdescription;
ACCfield = ACCdescription;

UHL = readfields(filename,UHLfield,1,'ieee-be',fid);
DSI = readfields(filename,DSIfield,1,'ieee-be',fid);
ACC = readfields(filename,ACCfield,1,'ieee-be',fid);

fclose(fid);


% Data records information
%
% True longitude = longitude count x data interval + origin (Offset from the SW corner longitude)
% 
% True latitude = latitude count x data interval + origin (Offset from the SW corner latitude)
%
% 1x1 degree tiles, including all edges, edges duplicated across files.

nrows = str2num(DSI.NumberofLongitudelines); % number of longitude lines, arranged west to east
ncols = str2num(DSI.NumberofLatitudelines); % number of latitude point per line, arranged south to north
precision = 'int16';
nRowTrailBytes = 4; % checksum
machineformat = 'ieee-be';
nheadbytes = 3428;
nRowHeadBytes = 8; %
nRowTrailBytes = 4; % checksum

lato = dmsstr2deg(DSI.Latitudeoforigin);
lono = dmsstr2deg(DSI.Longitudeoforigin);

% special case for incorrectly formatted data files for region just north
% of equator (LSJ 01182003)
if ~isempty(strfind(filename,'n00.dt0'))
    if isequal(DSI.LatitudeofNWcorner,'010000S')
        % fix data (latitude of northern points should be at 1 deg North
        % not 1 deg South)
        DSI.LatitudeofNWcorner = '010000N';
        DSI.LatitudeofNEcorner = DSI.LatitudeofNWcorner;
    end
end

maplatlim = [ dmsstr2deg(DSI.LatitudeofSWcorner)  dmsstr2deg(DSI.LatitudeofNWcorner) ];
maplonlim = [ dmsstr2deg(DSI.LongitudeofSWcorner) dmsstr2deg(DSI.LongitudeofSEcorner) ];

skipfactor = 1;
dlat = secstr2deg(DSI.Latitudeinterval);
dlon = secstr2deg(DSI.Longitudeinterval);
[dlat0,dlon0] = deal(dlat,dlon);
if dlat ~= dlon
   warning('Latitude and longitude spacing differ; Using coarser grid')
   skipfactor = dlon/dlat;
   dlat = max([dlat dlon]);
   dlon = dlat;
end

%  Check to see if latlim and lonlim within map limits

if isempty(latlim); latlim = maplatlim; end
if isempty(lonlim); lonlim = maplonlim; end


errnote = 0;
if latlim(1)>latlim(2)
   warning('First element of latlim must be less than second')
   errnote = 1;
end
if lonlim(1)>lonlim(2)
   warning('First element of lonlim must be less than second')
   errnote = 1;
end
if errnote
   error('Check limits')
end

tolerance = 0;
linebreak = sprintf('\n');

if  latlim(1)>maplatlim(2)+tolerance | ...
      latlim(2)<maplatlim(1)-tolerance | ...
      lonlim(1)>maplonlim(2)+tolerance | ...
      lonlim(2)<maplonlim(1)-tolerance
   warning([ ...
         'Requested latitude or longitude limits are off the map' linebreak ...
         ' latlim for this dataset is ' ...
         mat2str( [maplatlim(1) maplatlim(2)],3) linebreak ...
         ' lonlim for this dataset is '...
         mat2str( [maplonlim(1) maplonlim(2)],3) ...
      ])
   map=[];maplegend = [];
   return
end

warn = 0;
if latlim(1)<maplatlim(1)-tolerance ; latlim(1)=maplatlim(1);warn = 1; end
if latlim(2)>maplatlim(2)+tolerance ; latlim(2)=maplatlim(2);warn = 1; end
if lonlim(1)<maplonlim(1)-tolerance ; lonlim(1)=maplonlim(1);warn = 1; end
if lonlim(2)>maplonlim(2)+tolerance ; lonlim(2)=maplonlim(2);warn = 1; end
if warn
   warning([ ...
         'Requested latitude or longitude limits exceed map limits' linebreak ...
         ' latlim for this dataset is ' ...
         mat2str( [maplatlim(1) maplatlim(2)],3) linebreak ...
         ' lonlim for this dataset is '...
         mat2str( [maplonlim(1) maplonlim(2)],3) ...
      ])
end


% convert lat and lonlim to column and row indices

[clim,rlim] = yx2rc(latlim,lonlim,lato,lono,dlat0,dlon0);

readrows = rlim(1):scalefactor:rlim(2);
readcols = clim(1):scalefactor*skipfactor:clim(2);

% extract the map matrix

map = readmtx(filename,nrows,ncols,precision,readrows,readcols,machineformat,nheadbytes,nRowHeadBytes,nRowTrailBytes);
map = map';

% DTED0 files downloaded from the internet have negative values that can be read correctly
% as signed 16 bit integers with big-endian byte ordering. DTED 1 or 2 files from CD don't all
% appear to follow the standard. Detect and correct those cases.

indx= find(map<-12000);
map(indx) = -32767-map(indx)-1;

% Construct the map legend. Add a half a cell offset to the map legend to 
% account for the difference between elevation profiles, the paradigm in the
% DTED files, and matrix cells with values at the middle, which is the model 
% for regular matrix maps. This will lead to the map extending a half a cell
% outside the requested map limits.

[readlat,readlon] = rc2yx(readcols,readrows,lato,lono,dlat0,dlon0);
maplegend = [1/(dlat*scalefactor) max(readlat)+dlat/2 min(readlon)-dlon];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deg = dmsstr2deg(str)

%DMSSTR2DEG converts a DTED DMS latitude or longitude string to a decimal degree number

deg = dms2deg(str2num(str(1:end-1))/100);
if strcmp(str(end),'S') | strcmp(str(end),'W'); 
   deg = -deg; 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function deg = secstr2deg(str)

%SECSTR2DEG converts a DTED seconds latitude or longitude string to a decimal degree number

sec = str2num(str)/10;
if sec <= 60
   deg =dms2deg(mat2dms(0,0,str2num(str)/10));
else
   deg =dms2deg(mat2dms(0,floor(sec/60),mod(sec,60)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function UHLfield = UHLdescription

% User Header Label field(UHL)

UHLfield( 1).length = 3;    UHLfield( 1).name = 'Recognition sentinel';      
UHLfield( 2).length = 1;    UHLfield( 2).name = 'Fixed by standard';     
UHLfield( 3).length = 8;    UHLfield( 3).name = 'Longitude of origin ';      
UHLfield( 4).length = 8;    UHLfield( 4).name = 'Latitude of origin ';       
UHLfield( 5).length = 4;    UHLfield( 5).name = 'Longitude data interval ';      
UHLfield( 6).length = 4;    UHLfield( 6).name = 'Latitude data interval ';       
UHLfield( 7).length = 4;    UHLfield( 7).name = 'Absolute Vertical Accuracy in Meters';      
UHLfield( 8).length = 3;    UHLfield( 8).name = 'Security Code';     
UHLfield( 9).length = 12;   UHLfield( 9).name = 'Unique reference number ';      
UHLfield(10).length = 4;    UHLfield(10).name = 'number of longitude lines ';        
UHLfield(11).length = 4;    UHLfield(11).name = 'number of latitude points ';        
UHLfield(12).length = 1;    UHLfield(12).name = 'Multiple accuracy';     
UHLfield(13).length = 24;   UHLfield(13).name = 'future use';        

for i=1:length(UHLfield);
   UHLfield(i).type = 'char';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DSIfield = DSIdescription

% Data Set Identification (DSI) record contents

DSIfield( 1).length = 3;     DSIfield( 1).name = 'Recognition Sentinel';      
DSIfield( 2).length = 1;     DSIfield( 2).name = 'Security Classification Code';      
DSIfield( 3).length = 2;     DSIfield( 3).name = 'Security Control and Release Markings';     
DSIfield( 4).length = 27;    DSIfield( 4).name = 'Security Handling Description';     
DSIfield( 5).length = 26;    DSIfield( 5).name = 'reserved1';     
DSIfield( 6).length = 5;     DSIfield( 6).name = 'DMA series';        
DSIfield( 7).length = 15;    DSIfield( 7).name = 'unique Ref Num';        
DSIfield( 8).length = 8;     DSIfield( 8).name = 'reserved2';     
DSIfield( 9).length = 2;     DSIfield( 9).name = 'Data Edition Number';       
DSIfield(10).length = 1;     DSIfield(10).name = 'Match Merge Version';       
DSIfield(11).length = 4;     DSIfield(11).name = 'Maintenance Date';      
DSIfield(12).length = 4;     DSIfield(12).name = 'Match Merge Date';      
DSIfield(13).length = 4;     DSIfield(13).name = 'Maintenance Description Code';      
DSIfield(14).length = 8;     DSIfield(14).name = 'Producer Code';     
DSIfield(15).length = 16;    DSIfield(15).name = 'reserved3';     
DSIfield(16).length = 9;     DSIfield(16).name = 'Product Specification';     
DSIfield(17).length = 2;     DSIfield(17).name = 'Product Specification Amendment Number';        
DSIfield(18).length = 4;     DSIfield(18).name = 'Date of Product Specification';     
DSIfield(19).length = 3;     DSIfield(19).name = 'Vertical Datum ';       
DSIfield(20).length = 5;     DSIfield(20).name = 'Horizontal Datum Code ';        
DSIfield(21).length = 10;    DSIfield(21).name = 'Digitizing Collection System';      
DSIfield(22).length = 4;     DSIfield(22).name = 'Compilation Date';      
DSIfield(23).length = 22;    DSIfield(23).name = 'reserved4';     
DSIfield(24).length = 9;     DSIfield(24).name = 'Latitude of origin';        
DSIfield(25).length = 10;    DSIfield(25).name = 'Longitude of origin ';      
DSIfield(26).length = 7;     DSIfield(26).name = 'Latitude of SW corner ';        
DSIfield(27).length = 8;     DSIfield(27).name = 'Longitude of SW corner ';       
DSIfield(28).length = 7;     DSIfield(28).name = 'Latitude of NW corner ';        
DSIfield(29).length = 8;     DSIfield(29).name = 'Longitude of NW corner ';       
DSIfield(30).length = 7;     DSIfield(30).name = 'Latitude of NE corner ';        
DSIfield(31).length = 8;     DSIfield(31).name = 'Longitude of NE corner ';       
DSIfield(32).length = 7;     DSIfield(32).name = 'Latitude of SE corner ';        
DSIfield(33).length = 8;     DSIfield(33).name = 'Longitude of SE corner ';       
DSIfield(34).length = 9;     DSIfield(34).name = 'Clockwise orientation angle ';      
DSIfield(35).length = 4;     DSIfield(35).name = 'Latitude interval ';        
DSIfield(36).length = 4;     DSIfield(36).name = 'Longitude interval ';       
DSIfield(37).length = 4;     DSIfield(37).name = 'Number of Latitude lines';      
DSIfield(38).length = 4;     DSIfield(38).name = 'Number of Longitude lines';     
DSIfield(39).length = 2;     DSIfield(39).name = 'Partial Cell Indicator ';       
DSIfield(40).length = 101;   DSIfield(40).name = 'reserved5';     
DSIfield(41).length = 100;   DSIfield(41).name = 'Reserved for producing nation use ';        
DSIfield(42).length = 156;   DSIfield(42).name = 'reserved6';     

for i=1:length(DSIfield);
   DSIfield(i).type = 'char';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ACCfield = ACCdescription

% Acuraccy field(ACC) record

ACCfield( 1).length = 3;        ACCfield( 1).name = 'Recognition Sentinel';      
ACCfield( 2).length = 4;        ACCfield( 2).name = 'Absolute Horizontal Accuracy ';     
ACCfield( 3).length = 4;        ACCfield( 3).name = 'Absolute Vertical Accuracy ';       
ACCfield( 4).length = 4;        ACCfield( 4).name = 'Relative Horizontal Accuracy';      
ACCfield( 5).length = 4;        ACCfield( 5).name = 'Relative Vertical Accuracy';        
ACCfield( 6).length = 4;        ACCfield( 6).name = 'reserved1';     
ACCfield( 7).length = 1;        ACCfield( 7).name = 'reserved2';     
ACCfield( 8).length = 31;       ACCfield( 8).name = 'reserved3';     
ACCfield( 9).length = 2;        ACCfield( 9).name = 'Multiple Accuracy Outline Flag';        
ACCfield(10).length = 4;        ACCfield(10).name = 'Sub Absolute Horizontal Accuracy ';     
ACCfield(11).length = 4;        ACCfield(11).name = 'Sub Absolute Vertical Accuracy';        
ACCfield(12).length = 4;        ACCfield(12).name = 'Sub Relative Horizontal Accuracy';      
ACCfield(13).length = 4;        ACCfield(13).name = 'Sub Relative Vertical Accuracy';        
ACCfield(14).length = 14*(2+9+10);      ACCfield(14).name = 'Sub Region Outlines';       
ACCfield(15).length = 18;       ACCfield(15).name = 'reserved4';     
ACCfield(16).length = 69;       ACCfield(16).name = 'reserved5';     

for i=1:length(ACCfield);
   ACCfield(i).type = 'char';
end

%--------------------------------------------------------------------------

function [latdir,londir] = dteddirs(uniquelons,uniquelats,ext)

hWestEast = 'wee';
londir{length(uniquelons)} = [];
for i = 1:length(uniquelons)                                              
    londir{i} = sprintf('dted%c%c%03d%c', filesep,...
        hWestEast(2+sign(uniquelons(i))), abs(uniquelons(i)), filesep);                                             
end	                                                                       

hSouthNorth = 'snn';
latdir{length(uniquelats)} = [];
for i = 1:length(uniquelats)                                              
	latdir{i} = sprintf( '%c%02d.%s',...
        hSouthNorth(2+sign(uniquelats(i))), abs(uniquelats(i)), ext);                
end

%--------------------------------------------------------------------------

function [map, maplegend, UHL, DSI, ACC] = ...
    readFirstNonEmpty(dtedfile, samplefactor, latlim, lonlim)

% get the origin of the first file
[p,latStr] = fileparts(dtedfile{1,1});
[p,lonStr] = fileparts([p '.*']);
lat0 = str2double(latStr(2:end));
lon0 = str2double(lonStr(2:end));
if strcmp(latStr(1),'s') == 1 || strcmp(latStr(1),'S') == 1
    lat0 = -lat0;
end
if strcmp(lonStr(1),'w') == 1 || strcmp(lonStr(1),'W') == 1
    lon0 = -lon0;
end

% read first non-empty file
nonEmptyFileIndx = [];
for k = 1:numel(dtedfile)
    if exist(dtedfile{k}) ~= 0
        nonEmptyFileIndx = k;
        break;
    end
end
if isempty(nonEmptyFileIndx)
    error('No data files for requested area.')
end
[map, maplegend, UHL, DSI, ACC] = ...
    dted(dtedfile{nonEmptyFileIndx(1)},samplefactor);

% latitude and longitude limits
dlat = secstr2deg(DSI.Latitudeinterval);
dlon = secstr2deg(DSI.Longitudeinterval);

% map limits for first file read
maplatlim = [ dmsstr2deg(DSI.LatitudeofSWcorner)...
              dmsstr2deg(DSI.LatitudeofNWcorner) ];
maplonlim = [ dmsstr2deg(DSI.LongitudeofSWcorner)...
              dmsstr2deg(DSI.LongitudeofSEcorner) ];

% adjust the maplegend
topLat = min([latlim(2) lat0+diff(maplatlim)]);
leftLon  = max([lonlim(1) lon0]);
maplegend(2) = topLat + dlat/2;
maplegend(3) = leftLon - dlon;
