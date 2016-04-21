function varargout = dcwdata(varargin)
%DCWDATA Read selected data from the Digital Chart of the World.
%
%   S = DCWDATA(LIBRARY,LATLIM,LONLIM,THEME,TOPLEVEL) reads the data
%   for the specified theme and topology level directly from the named DCW
%   CD-ROM. There are four CD's, one each for the library: 'NOAMER' (North
%   America), 'SASAUS' (Southern Asia and Australia), 'EURNASIA' (Europe
%   and Northern Asia) and 'SOAMAFR' (South America and Africa). The
%   desired theme is specified by a two letter code string.  A list of
%   valid codes will be displayed when an invalid code, such as '?', is
%   entered.  The region of interest can be given as a point latitude and
%   longitude or as a region with two-element vectors of latitude and
%   longitude limits.  The units of latitude and longitude are degrees. The
%   data covering the requested region is returned, but will include data
%   extending to the edges of the 5 by 5 degree tiles.  The result is
%   returned as a Mapping Toolbox Geographic Data Structure.
%   
%   [S1, S2, ...]  = ...
%   DCWDATA(LIBRARY,LATLIM,LONLIM,THEME,{topolevel1,topolevel2,...}) reads
%   several topology levels.  The levels must be specified as a cell array
%   with the entries 'patch', 'line', 'point' or 'text'.  Entering {'all'}
%   for the topology level argument is equivalent to {'patch', 'line',
%   'point','text'}. Upon output, the data are returned in the output
%   arguments by topology level in the same order as they were requested.
%
%   DCWDATA(DEVICENAME,LIBRARY,LATLIM,...) specifies the logical device
%   name of the CD-ROM for computers which do not automatically name the
%   mounted disk.
%
%   The Digital Chart of the World is now out of print, and has been 
%   superceded by the Vector Map Level 0 (VMAP0). The documentation  for
%   the VMAP0DATA function has more information on VMAP0.
%
%   See also DCWGAZ, DCWREAD, DCWRHEAD, VMAP0DATA, MLAYERS, DISPLAYM,
%   EXTRACTM.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by:  W. Stumpf
%   $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:20:48 $

% check for valid inputs

checknargin(5,6,nargin,mfilename);
if nargin == 5
   library = varargin{1};
   latlim = varargin{2};
   lonlim = varargin{3};
   theme = varargin{4};
   topolevel = varargin{5};
   devicename = library;
elseif nargin == 6
   devicename = varargin{1};
   library = varargin{2};
   latlim = varargin{3};
   lonlim = varargin{4};
   theme = varargin{5};
   topolevel = varargin{6};
end

%  Test the inputs
if  isequal(size(latlim),[1 1])
   latlim = latlim*[1 1];
elseif ~isequal(sort(size(latlim)),[1 2])
    eid = sprintf('%s:%s:invalidLatLimitSize', getcomp, mfilename);
    error(eid,'%s','Latitude limit input must be a scalar or 2 element vector')
end

if isequal(size(lonlim),[1 1])
   lonlim = lonlim*[1 1];
elseif ~isequal(sort(size(lonlim)),[1 2])
    eid = sprintf('%s:%s:invalidLonLimitSize', getcomp, mfilename);
    error(eid,'%s','Longitude limit input must be a scalar or 2 element vector')
end

%  Test for real inputs
latlim = ignoreComplex(latlim, mfilename, 'LATLIM');
lonlim = ignoreComplex(lonlim, mfilename, 'LONLIM');

% check for valid topology level inputs
if ischar(topolevel)

   topoindx = strmatch(topolevel,{'patch','line','point','text'},'exact');
   if isempty(topoindx)
      eid = sprintf('%s:%s:invalidTOPOLEVEL', getcomp, mfilename);
      error(eid,'%s','Topology level is not ''patch'', ''line'', ''point'' or ''text'' ');
   end
   if nargout ~= 1
      eid = sprintf('%s:%s:invalidOutputArgumentCount', getcomp, mfilename);
      error(eid,'%s','Number of output arguments doesn''t match requested topology levels');
   end

elseif iscell(topolevel)

   if length(topolevel)==1 & strcmp(topolevel,'all');
      topolevel = {'patch','line','point','text'};
   end

   topoindx = [];

   for i=1:length(topolevel)
      if ~ischar(topolevel{i})
         eid = sprintf('%s:%s:invalidTOPOLEVEL', getcomp, mfilename);
         error(eid,'%s','Topology level must be a cell array of strings');
      end
      thistopoindx = strmatch(topolevel{i},{'patch','line','point','text'},'exact');
      if isempty(thistopoindx)
         eid = sprintf('%s:%s:invalidTOPOLEVELTYPE', getcomp, mfilename);
         error(eid,'%s','Topology level must be ''patch'', ''line'', ''point'' or ''text'' ');
      end
      topoindx = [topoindx thistopoindx];
   end % for

   topoindx = unique(topoindx);
   if length(topoindx) ~=length(topolevel)
      eid = sprintf('%s:%s:invalidTOTOREQUESTS', getcomp, mfilename);
      error(eid,'%s','Redundant requests in topology levels')
   elseif nargout ~= length(topoindx)
      eid = sprintf('%s:%s:invalidNumberOfOutputs', getcomp, mfilename);
      error(eid,'%s','Number of outputs doesn''t match requested topology levels')
   end
else
   eid = sprintf('%s:%s:invalidTOPOLEVEL', getcomp, mfilename);
   error(eid,'%s','Topology level must be a string or cell array of strings')
end % if

varargout = cell(1,nargout);

%for i=1:nargout
%varargout(i) = {[]};
%end %for

% Check that the top of the database file heirarchy is visible,
% and note the case of the directory and filenames.

filepath = fullfile(devicename,filesep);
dirstruc = dir(filepath);
if isempty(strmatch('DCW',upper(strvcat(dirstruc.name)),'exact'))
   eid = sprintf('%s:%s:deviceError', getcomp, mfilename);
   error(eid,'%s',['DCW disk ' upper(library) ' not mounted or incorrect devicename ']); 
end


if ~isempty(strmatch('DCW',{dirstruc.name},'exact'))
   filesystemcase = 'upper';
elseif ~isempty(strmatch('dcw',{dirstruc.name},'exact'))
   filesystemcase = 'lower';
else
   filesystemcase = 'lower';
end


% build the pathname so that [pathname filename] is the full filename

switch filesystemcase
case 'upper'
   filepath = fullfile(devicename,'DCW',upper(library),filesep);
case 'lower'
   filepath = fullfile(devicename,'dcw',lower(library),filesep);
end

dirstruc = dir(filepath);
if isempty(dirstruc)
   eid = sprintf('%s:%s:deviceError', getcomp, mfilename);
   error(eid,'%s',['DCW disk ' upper(library) ' not mounted or incorrect devicename ']); 
end

% check for valid theme request

CAT = dcwread(filepath,'CAT');

if isempty(strmatch(theme,{CAT.COVERAGE_NAME},'exact'))

   linebreak = double(sprintf('\n'));
   goodthemes = [str2mat(CAT.COVERAGE_NAME) ...
            char(58*ones(length(CAT),1)) ...
              char(32*ones(length(CAT),1)) ...
            str2mat(CAT.DESCRIPTION) ...
            char(linebreak*ones(length(CAT),1)) ];
   goodthemes = goodthemes';
   goodthemes = goodthemes(:);
   goodthemes = goodthemes';

   eid = sprintf('%s:%s:invalidLibrary', getcomp, mfilename);
   error(eid,'%s',['Theme not present in library ' library char(linebreak) char(linebreak) ...
          'Valid two-letter theme identifiers are: ' char(linebreak) ...
          goodthemes ...
         ])
end

if strcmp(upper(library),'BROWSE')

% BROWSE layer is untiled

   dotiles = 1;
   tFT(1).TILE_NAME = '';

else

% Get the essential libref information (tile name/number, bounding boxes)

   switch filesystemcase
   case 'upper'
      filepath = fullfile(devicename,'DCW',upper(library),'TILEREF',filesep);
   case 'lower'
      filepath = fullfile(devicename,'dcw',lower(library),'tileref',filesep);
   end
   
   tFT = dcwread(filepath,'TILEREF.AFT');
   FBR = dcwread(filepath,'FBR');

% find which tiles are fully or partially covered by the desired region

   dotiles = dcwdo(FBR,latlim,lonlim)   ;

end

% Here is where the value description and feature tables reside

switch filesystemcase
case 'upper'
   themepath = fullfile(devicename,'DCW',upper(library),upper(theme),filesep);
case 'lower'
   themepath = fullfile(devicename,'dcw',lower(library),lower(theme),filesep);
end

% get a list of files in the requested directory

dirstruc = dir(themepath);
names = {dirstruc.name};
names = uppercell(names); % because pc converts to lowercase

% read the Integer Value Description Table. This contains the integer
% values used to distinguish between types of features

VDT = [];
if any(strcmp(uppercell(names),'INT.VDT'))==1
   VDT = dcwread(themepath,'INT.VDT');
end


% read the Character Value Description Table if present.
% This contains the character values used to distinguish
% between types of features

cVDT = [];
if any(strcmp(uppercell(names),'CHAR.VDT'))==1
   cVDT = dcwread(themepath,'CHAR.VDT');
end


% loop over points, lines, text
% handle faces separately

FACstruct = [];
EDGstruct = [];
ENDstruct = [];
TXTstruct = [];


for i=1:length(dotiles)

   EDG = [];


% extract pathname
% replace directory separator with the one for current platform

   tilepath = tFT(dotiles(i)).TILE_NAME;
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
      case 1
         if any(topoindx ==1)
            FTfilename = [theme 'AREA.AFT'];
            EntityName =  'FAC';
 
            if ~(any(strcmp(names,FTfilename))==1)
               wid = sprintf('%s:%s:patchData', getcomp, mfilename);
               warning(wid, '%s', 'No patch data for this theme on this tile')
            elseif ~(any(strcmp(tilenames,EntityName))==1)
               wid = sprintf('%s:%s:patchData', getcomp, mfilename);
               warning(wid, '%s', 'No patch data for this theme on this tile')
            else

               EDG = dcwread(tilepath,'EDG');

               if ~isempty(cVDT)
                  cVDTindx = strmatch(FTfilename,str2mat(cVDT.TABLE));
                  FACstruct = dcwfactl(themepath,tilepath,FTfilename,FACstruct,VDT,cVDT(cVDTindx),EDG);
               else
                  FACstruct = dcwfactl(themepath,tilepath,FTfilename,FACstruct,VDT,cVDT,EDG);
               end

               if ~isempty(FACstruct);
                  varargout(find(topoindx ==1))  = {FACstruct};
               end
            end


         end %if
%
% for the entities that are within the region of interest,
%
      case 2

         if any(topoindx ==2)
            FTfilename = [theme 'LINE.LFT'];
            EntityName =  'EDG';
 
            if ~(any(strcmp(names,FTfilename))==1)
               wid = sprintf('%s:%s:lineData', getcomp, mfilename);
               warning(wid, '%s', 'No line data for this theme on this tile')
            elseif ~(any(strcmp(tilenames,EntityName))==1)
               wid = sprintf('%s:%s:lineData', getcomp, mfilename);
               warning(wid, '%s', 'No line data for this theme on this tile')
            else

               if isempty(EDG); EDG = dcwread(tilepath,'EDG'); end

               EDGstruct = dcwedgtl(themepath,tilepath,FTfilename,EDGstruct,VDT,'EDG',EDG);
               if ~isempty(EDGstruct);
                  varargout(find(topoindx ==2)) = {EDGstruct};
               end

            end %if
         end % if
      case 3

         if any(topoindx ==3)

            FTfilename = [theme  'POINT.PFT'];
            EntityName =  'END';

            if ~(any(strcmp(names,FTfilename))==1)
               wid = sprintf('%s:%s:pointData', getcomp, mfilename);
               warning(wid, '%s', 'No point data for this theme on this tile')
            elseif ~(any(strcmp(tilenames,EntityName))==1)
               wid = sprintf('%s:%s:pointData', getcomp, mfilename);
               warning(wid, '%s', 'No point data for this theme on this tile')
            else
               if ~isempty(cVDT)
                  cVDTindx = strmatch(FTfilename,str2mat(cVDT.TABLE));
               end
               ENDstruct = dcwendtl(themepath,tilepath,ENDstruct,VDT,FTfilename,'END',cVDT);
               if ~isempty(ENDstruct);
                  varargout(find(topoindx ==3)) = {ENDstruct};
               end
            end %if

         end % if

      otherwise

         if any(topoindx ==4)
            FTfilename = [theme 'TEXT.TFT'];
            EntityName =  'TXT';

            if ~(any(strcmp(names,FTfilename))==1)
               wid = sprintf('%s:%s:textData', getcomp, mfilename);
               warning(wid, '%s', 'No text data for this theme on this tile')
            elseif ~(any(strcmp(tilenames,EntityName))==1)
               wid = sprintf('%s:%s:textData', getcomp, mfilename);
               warning(wid, '%s', 'No text data for this theme on this tile')
            else

               TXTstruct = dcwtxttl(themepath,tilepath,TXTstruct,VDT,FTfilename,'TXT');
               if ~isempty(TXTstruct);
                  varargout(find(topoindx ==4)) = {TXTstruct};
               end
            end

         end % if

      end % switch

   end % for j

end %for i

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function carray = uppercell(carray)
%UPPERCELL converts a cell array of strings to uppercase

for i=1:length(carray);carray{i} = upper(carray{i});end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [savelat,savelong] = dcwgbfac(facenum,EDG,FAC,RNG)
%DCWGFAC builds a Digital Chart of the World Browse layer face from its edges

if facenum ==1;

% outer ring of the universe face cannot be displayed

   savelat = [];
   savelong = [];
   return
end

ringptrs = find([RNG.FACE_ID]==facenum);

savelat = [];
savelong = [];
for i=1:length(ringptrs)

   checkface = RNG(ringptrs(i)).FACE_ID;
   if checkface ~= facenum
      wid = sprintf('%s:%s:faceAndRingTable', getcomp, mfilename);
      warning(wid, '%s', 'Face and Ring tables inconsistent');
      return; 
   end

   startedge = RNG(ringptrs(i)).START_EDGE;

   [lat,long] = dcwgbrng(EDG,startedge,facenum);


   if isempty(savelat)
      savelat = lat;
      savelong = long;
   else
      savelat = [savelat;NaN;lat];
      savelong = [savelong;NaN;long];
   end

end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [savelat,savelong] = dcwgbrng(EDG,startedge,facenum)

if nargin ~= 3
   eid = sprintf('%s:%s:incorrectArgumentCount', getcomp, mfilename);
   error(eid,'%s','Incorrect number of arguments')
end


% Follow face until we end up where we started. If left and right face
% are identical, use left/right edges to break the tie; if that's not
% unambiguous, use start/end nodes

llchunk = EDG(startedge).COORDINATES;

if  EDG(startedge).RIGHT_FACE(1) == facenum
        nextedge = EDG(startedge).RIGHT_EDGE(1);  % stay on this tile
        savelat = llchunk(:,2);
        savelong = llchunk(:,1);
elseif EDG(startedge).LEFT_FACE(1) == facenum
        nextedge = EDG(startedge).LEFT_EDGE(1);
        savelat  = flipud(llchunk(:,2));
        savelong = flipud(llchunk(:,1));
else
        wid = sprintf('%s:%s:faceWarning', getcomp, mfilename);
        warning(wid, '%s', 'Error following face.');
        return
end % if

lastedge=startedge;
lastnodes = [EDG(startedge).START_NODE(1)  ...
                                EDG(startedge).END_NODE(1)  ];

while ~(nextedge == startedge)

        curnodes = [EDG(nextedge).START_NODE EDG(nextedge).END_NODE];

        llchunk = EDG(nextedge).COORDINATES;
        lat=llchunk(:,2);
        long=llchunk(:,1);

        rface = EDG(nextedge).RIGHT_FACE(1);
        lface = EDG(nextedge).LEFT_FACE(1);

        if lface == rface

% Breaking tie with nextedge

                if EDG(nextedge).RIGHT_EDGE(1) == nextedge

                        savelat = [savelat;lat;flipud(lat)];
                        savelong = [savelong;long;flipud(long)];
                        lastedge = nextedge;
                        nextedge = EDG(nextedge).LEFT_EDGE(1);

                elseif EDG(nextedge).LEFT_EDGE(1) == nextedge

                        savelat = [savelat;flipud(lat);lat];
                        savelong = [savelong;flipud(long);long];
                        lastedge = nextedge;
                        nextedge = EDG(nextedge).RIGHT_EDGE(1);  %stay on this tile

                else

% Breaking tie with nodes

                        starttest = find(curnodes(1) == lastnodes);
                        endtest = find(curnodes(2) == lastnodes);

                        if isempty(starttest) & ~isempty(endtest)

                                savelat = [savelat;flipud(lat)];
                                savelong = [savelong;flipud(long)];
                                nextedge = EDG(nextedge).LEFT_EDGE(1);

                        elseif ~isempty(starttest) & isempty(endtest)

                                savelat = [savelat;lat];
                                savelong = [savelong;long];
                                nextedge = EDG(nextedge).RIGHT_EDGE(1);  % stay on this tile

                        else
                                wid = sprintf('%s:%s:faceWarning', getcomp, mfilename);
                                warning(wid, '%s', 'Error following face..')
                        return

                        end % if
                end % if

        elseif rface == facenum
                savelat = [savelat;lat];
                savelong = [savelong;long];
                lastedge = nextedge;
                nextedge = EDG(nextedge).RIGHT_EDGE(1);  % stay on this tile
        elseif lface == facenum
                savelat = [savelat;flipud(lat)];
                savelong = [savelong;flipud(long)];
                lastedge = nextedge;
                nextedge = EDG(nextedge).LEFT_EDGE(1);
        else
                wid = sprintf('%s:%s:faceWarning', getcomp, mfilename);
                warning(wid, '%s', 'Error following face...')
                return
        end % if

        nextedge = nextedge(1);
        lastnodes = curnodes;

end % while

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [struc,ET] = dcwedgtl(themepath,tilepath,FTfilename,struc,VDT,EntityName,ET)

% Read the feature table and the entity table. The feature table contains
% the integer feature type. The entity file contains the coordinates.

if nargin == 6
   ET = dcwread(tilepath,EntityName);
elseif nargin ~= 7
   eid = sprintf('%s:%s:argumentCount', getcomp, mfilename);
   error(eid,'%s','Incorrect number of arguments')
end

etfields = fieldnames(ET); % assume name of key into feature table is second field


endofword = find(~isletter(FTfilename))-1;
matchthis = lower(FTfilename(1:endofword));
if isempty(strmatch(matchthis,lower(etfields{2}))) % field name doesn't match what was expected for key
   indx = 1:length(ET); % must be in browse layer, so there are no tiles, and we want all elements
else
   eval(['indx = [ET.' etfields{2} '];']) % retrieve only elements in this tile
end

[FT, FTfield]  = dcwread(themepath,FTfilename, indx  );

if length(ET) ~= length(FT)'
   eid = sprintf('%s:%s:tableLengths', getcomp, mfilename);
   error(eid,'%s','Feature table and entity table are different lengths'); 
end

%
% find which fields of the feature table contain integer keys, text or values, for
% extraction as a tag
%

ftfields = fieldnames(FT);

FTindx = strmatch(FTfilename,{VDT.TABLE});    % the indices of the entries in the VDT pertinent to the current topology level

valfieldIDs = strmatch('LAV',shiftspc(fliplr(str2mat(char(ftfields))),'left')); % field name ends in 'VAL'

textfieldIDs = strmatch('T',{FTfield.type},'exact'); % into fields of FT


%
% Find out how many feature types we have by getting the indices
% into the feature table relating to the current topological entity
% (edge). Look for integer description keys, values, and text

valmat = [];
vdtfieldIDs = [];

if ~isempty(FTindx) % have integer feature, so gather  a matrix of the value combos

   vdtvalues = [VDT.VALUE];               % all the values found in the Feature Table (over all topologies)
   featurevalues = vdtvalues(FTindx);         % the values found in the Feature Table (for this topology level)

%
% Get locations of the attribute indexed in the Feature Table
% within the Value Description Table, since this changes from
% layer to layer
%

   vdtfieldIDs = strmatch('INT.VDT',{FTfield.VDTname},'exact');

   if ~isempty(vdtfieldIDs)
      vdtfieldnames = ftfields(vdtfieldIDs);

%
% Get all the attribute codes out of the Feature Table.
% Do this by converting the structure to a cell array.
% There may be several simultaneous attributes
%

      cells = struct2cell(FT);

      featvalvec = [cells{vdtfieldIDs,:}] ;
      featvalmat = reshape(featvalvec, length(vdtfieldIDs), length(featvalvec)/length(vdtfieldIDs));
      VDTfeatvalmat = featvalmat';

      valmat = [valmat VDTfeatvalmat];

   end % if
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
       eval(['strs = str2mat(FT.' ftfields{textfieldIDs(i)}   ');']);
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

% build up description codes

   description = '';

   if ~isempty(vdtfieldIDs) % we have integer description values; expecting one or two

      for k = 1:length(vdtfieldIDs)

         eval(['val = FT(indx(1)).' ftfields{vdtfieldIDs(k)}   ';']);

         ind1 = find(strcmp(vdtfieldnames{k},{VDT.ATTRIBUTE}) & [VDT.VALUE] == val); % into VDT

         desc = '';
         if ~isempty(ind1)
            desc = VDT(ind1).DESCRIPTION;
            if strcmp(desc,'feet above mean sea level')
               desc = [num2str(val) ' ' desc ];
            end
         end % if
         description = [description '; ' desc];

      end %k

   end % ~isempty(FTindx)

   if ~isempty(valfieldIDs) % we have integer values

      for k = 1:length(valfieldIDs)

         eval(['val = FT(indx(1)).' ftfields{valfieldIDs(k)}   ';']);
         description = [description '; ' num2str(val)];

      end %k

   end % ~isempty(valfieldIDs)

   if ~isempty(textfieldIDs) % we have no integer description values; expecting a text field in the feature table

      for k = 1:length(textfieldIDs)
         
         eval(['strs = FT(indx(1)).' ftfields{textfieldIDs(k)}   ';']);
         description = [description '; ' deblank(strs)];

      end % for k

   end

   description = description(3:length(description));

   struc(i+1).type= 'line';
   struc(i+1).otherproperty= {};
   struc(i+1).altitude= [];

   ll = [];
   for k=1:length(indx)
      llchunk = ET(indx(k)).COORDINATES;
      ll = [ll; NaN NaN; llchunk];
   end % for k


   struc(i+1).lat=ll(:,2);
   struc(i+1).long=ll(:,1);
   struc(i+1).tag=deblank(leadblnk(description));

   i=i+1;


end; %for j


return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [struc,EDG] = dcwfactl(themepath,tilepath,FTfilename,struc,VDT,cVDT,EDG)


if nargin == 6
   EDG  = dcwread(tilepath,'EDG');
elseif nargin ~= 7
   eid = sprintf('%s:%s:argumentCount', getcomp, mfilename);
   error(eid,'%s','Incorrect number of arguments')
end

% read the feature table and the entity table. The feature table has in
% it the integer feature type and (optionally?) the name of the feature.
% The entity file contains the coordinates.

FAC = dcwread(tilepath,'FAC');
RNG = dcwread(tilepath,'RNG');


etfields = fieldnames(FAC); % assume name of key into feature table is second field

endofword = find(~isletter(FTfilename))-1;
matchthis = lower(FTfilename(1:endofword));
if isempty(strmatch(matchthis,lower(etfields{2}))) % field name doesn't match what was expected for key
   indx = 1:length(FAC); % must be in browse layer, so there are no tiles, and we want all elements
else
   eval(['indx = [FAC.' etfields{2} '];']) % retrieve only elements in this tile
end

[FT, FTfield]  = dcwread(themepath,FTfilename,indx );

if length(FAC) ~= length(FT)'
   wid = sprintf('%s:%s:tableLength', getcomp, mfilename);
   warning(wid, '%s', 'Feature table and entity table are different lengths'); 
   return;
end

%
% find which fields of the feature table contain text, for
% extraction as an alternate tag
%

ftfields = fieldnames(FT);
textfieldIDs = strmatch('T',{FTfield.type},'exact'); % into fields of FT

%
% find out how many feature types we have by getting the indices
% into the feature table relating to the current topological entity
% (face). If there are no integer values describing the data,
% we will have to use character lookup codes or straight character strings
%

FTindx = strmatch(FTfilename,{VDT.TABLE}) ;   % the indices of the entries in the VDT pertinent to the current topology level

if isempty(FTindx)
   ncombos = 1;
else
   vdtvalues = [VDT.VALUE];               % all the values found in the Feature Table (over all topologies)
   featurevalues = vdtvalues(FTindx);         % the values found in the Feature Table (for this topology level)

%
% Get locations of the attribute indexed in the Feature Table
% within the Value Description Table, since this changes from
% layer to layer
%

   vdtfieldIDs = strmatch('INT.VDT',{FTfield.VDTname},'exact');


%
% Get all the attribute codes out of the Feature Table.
% Do this by converting the structure to a cell array.
% There may be several simultaneous attributes in general,
% but I don't expect more than one for faces.
%

   cells = struct2cell(FT);

   featvalvec = [cells{vdtfieldIDs,:}] ;
   featvalmat = reshape(featvalvec, length(vdtfieldIDs), length(featvalvec)/length(vdtfieldIDs));
   featvalmat = featvalmat';

%
% Measure the number of attributes and unique combinations
% of integer description values
%

   fvsz = size(featvalmat);
   nprop = fvsz(2);
   if nprop > 1
      wid = sprintf('%s:%s:importWarning', getcomp, mfilename);
      warning(wid, '%s', 'Cannot import with more than 1 integer value field')
      return
   end


   uniquecombos = unique(featvalmat,'rows');
   ucsz = size(uniquecombos);
   ncombos = ucsz(1);

%
% Get attribute field names so we may later build up strings
% describing unique combinations of attributes
%

   ftfields = fieldnames(FT);
   vdtfieldnames = ftfields(vdtfieldIDs);

end

%
% Extract the data
%


i=length(struc);
for j=1:ncombos

      description = '';

      if ~isempty(FTindx)

         indx = find(uniquecombos(j) == featvalmat); % into FT
         ind1 = find(strcmp(vdtfieldnames{1},{VDT.ATTRIBUTE}) & [VDT.VALUE] == uniquecombos(j,1) ); % into VDT
         if ~isempty(ind1); description = VDT(ind1).DESCRIPTION; end
      else
         indx = [FAC.ID];

      end

      for k=1:length(indx)

         [lat,long] = dcwgbfac(indx(k),EDG,FAC,RNG)   ;        % different

         if ~isempty(lat)

            struc(i+1).type= 'patch';                 % different
            struc(i+1).otherproperty= {};             % different

            struc(i+1).altitude= [];

            struc(i+1).lat=lat;
            struc(i+1).long=long;

            struc(i+1).tag=description;
%
% create an alternate tag from the text fields in the feature table
%
            alttag = '';
            longalttag = '';
            lookedup = 0;
            for n=1:length(textfieldIDs)

               thisvalue = eval(['[FT(indx(k)).' ftfields{textfieldIDs(n)} ']']);
               alttag = [alttag '; ' thisvalue];

               thisdescriptn = thisvalue;

               if ~isempty(thisvalue) & ~isempty(cVDT)
                  cVDTindx = strmatch(ftfields{textfieldIDs(n)},str2mat(cVDT.ATTRIBUTE)); % entries in the cVDT for this attribute (region, country, etc)
                  if ~isempty(cVDTindx)
                     cVDTvalindx = strmatch(thisvalue,str2mat(cVDT(cVDTindx).VALUE)); % entries in the cVDT for this attribute (region, country, etc)
                     if ~isempty(cVDTvalindx)
                        thisdescriptn = cVDT(cVDTindx(cVDTvalindx)).DESCRIPTION;
                        lookedup = 1;

                     end
                  end
               end
               longalttag = [longalttag '; ' thisdescriptn];
            end %n
            alttag = alttag(3:length(alttag));
            longalttag = longalttag(3:length(longalttag));


            if isempty(description);
               struc(i+1).tag=deblank(leadblnk(alttag));
            else
               struc(i+1).tag2=deblank(leadblnk(alttag));
            end

            if lookedup
               if isempty(description);
                  struc(i+1).tag2=deblank(leadblnk(longalttag));
               else
                  struc(i+1).tag3=deblank(leadblnk(longalttag));
               end
            end

            i=i+1;

         end %if
      end % for k

end; %for j

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function struc = dcwendtl(themepath,tilepath,struc,VDT,FTfilename,EntityName,cVDT)


% read the feature table and the entity table. The feature table has in
% it the integer feature type and (optionally?) the name of the feature.
% The entity file contains the coordinates.

ET = dcwread(tilepath,EntityName);
etfields = fieldnames(ET); % assume name of key into feature table is second field

endofword = find(~isletter(FTfilename))-1;
matchthis = lower(FTfilename(1:endofword));
if isempty(strmatch(matchthis,lower(etfields{2}))) % field name doesn't match what was expected for key
   indx = 1:length(ET); % must be in browse layer, so there are no tiles, and we want all elements
else
   eval(['indx = [ET.' etfields{2} '];']) % retrieve only elements in this tile
end

[FT,FTfield]  = dcwread(themepath,FTfilename,indx );


if length(ET) ~= length(FT)'
   eid = sprintf('%s:%s:tableLengths', getcomp, mfilename);
   error(eid,'%s','Feature table and entity table different lengths'); 
end

%
% find which fields of the feature table contain text or values, for
% extraction as an alternate tag
%

ftfields = fieldnames(FT);
textfieldIDs = strmatch('T',{FTfield.type},'exact'); % into fields of FT

valfieldIDs = strmatch('LAV',shiftspc(fliplr(str2mat(char(ftfields))),'left')); % field name ends in 'VAL'

%
% find out how many feature types we have by getting the indices
% into the feature table relating to the current topological entity
% (point).If there are no integer values describing the data,
% we will have to use character lookup codes or straight character strings
%

vdtfields = fieldnames(VDT);

FTindx = strmatch(FTfilename,{VDT.TABLE});    % the indices of the entries in the VDT pertinent to the current topology level

if isempty(FTindx) & ~isempty(textfieldIDs) % no integer feature, so depend on text strings in feature table. Only expect one.


   eval(['strs = str2mat(FT.' ftfields{textfieldIDs(1)}   ');']);
   uniquestrs = unique(strs,'rows');
    ncheck = size(uniquestrs,1);

elseif isempty(FTindx) & isempty(textfieldIDs) & ~isempty(valfieldIDs) % no integer feature, no text strings, must have integer values (like in HS)

   ncheck = 1 ; % all individual points, no classes

else

   vdtvalues = [VDT.VALUE]   ;               % all the values found in the Feature Table (over all topologies)
   featurevalues = vdtvalues(FTindx);         % the values found in the Feature Table (for this topology level)
   ncheck = length(featurevalues);
%
% get the name of the attribute indexed in the Feature Table
% from the Value Description Table, since this changes from
% layer to layer
%

   attributeName = deblank(VDT(FTindx(1)).ATTRIBUTE);  % assume always same (questionable?)

%
% Get all the attribute codes out of the Feature Table. Do
% this by converting the structure to a cell array
%

   attributeCol = strmatch(deblank(attributeName), fieldnames(FT));
   cells = struct2cell(FT);
   allFeatVals = [cells{attributeCol,:}];
end %if

% gather nodes in nan-clipped vectors for manipulation as a class
i=length(struc);
for j=1:ncheck

   indx = [];
   if ~isempty(FTindx)
      indx = find(featurevalues(j) == allFeatVals);
      if ~isempty(indx); description =  deblank(VDT(FTindx(j)).DESCRIPTION);   end
   elseif ~isempty(textfieldIDs)
      description = deblank(uniquestrs(j,:));
      indx = strmatch(description,strs,'exact');
   elseif ~isempty(valfieldIDs)
      description = 'unknown';
      indx = [ET.ID];
   end

   if ~isempty(indx)

      struc(i+1).type= 'line';
      struc(i+1).otherproperty= {}; % {'.','markersize',12};


      struc(i+1).altitude= [];


      ll = [];

      for k=1:length(indx)
         llchunk = ET(indx(k)).COORDINATE;
         ll = [ll; NaN NaN; llchunk];
      end % for k


      struc(i+1).lat=ll(:,2);
      struc(i+1).long=ll(:,1);

      struc(i+1).tag=description;
      struc(i+1).tag2='Classes of points';

      i=i+1;

   end %if

end; %for j

% Gather nodes as separate points for manipulation individually
% Use text fields in the feature table as an alternate tag.


if ( ~isempty(FTindx) & ~isempty(textfieldIDs) )  | ...
   (isempty(FTindx) & length(textfieldIDs)>2 )  | ...
    ~isempty(valfieldIDs)


   i=length(struc);
   for j=1:ncheck

      indx = [];
      if ~isempty(FTindx)
         indx = find(featurevalues(j) == allFeatVals);
         if ~isempty(indx); description = deblank(VDT(FTindx(j)).DESCRIPTION);   end
      elseif ~isempty(textfieldIDs)
         description = deblank(uniquestrs(j,:));
         indx = strmatch(description,strs,'exact');
      elseif ~isempty(valfieldIDs)
         description = '';
         indx = [ET.ID];
      end

      if ~isempty(indx)

         for k=1:length(indx)
            struc(i+1).type= 'line';
            struc(i+1).otherproperty= {}; %{'.','markersize',12};


            struc(i+1).altitude= [];

            llchunk = ET(indx(k)).COORDINATE;


            struc(i+1).lat=llchunk(:,2);
            struc(i+1).long=llchunk(:,1);

            struc(i+1).tag= ['Individual points; ' description];
%
% create an alternate tag from the text fields in the feature table
%
            expanded = 0;
            alttag = '';
            longalttag = '';
            if~isempty(textfieldIDs)

               for n=1:length(textfieldIDs)

                  thisvalue = eval(['[FT(indx(k)).' ftfields{textfieldIDs(n)} ']']);
                  alttag = [alttag '; ' thisvalue];

                  thisdescriptn = thisvalue;

                  if ~isempty(thisvalue) & ~isempty(cVDT)
                     cVDTindx = strmatch(ftfields{textfieldIDs(n)},str2mat(cVDT.ATTRIBUTE)); % entries in the cVDT for this attribute (region, country, etc)
                     if ~isempty(cVDTindx)
                        cVDTvalindx = strmatch(thisvalue,str2mat(cVDT(cVDTindx).VALUE)); % entries in the cVDT for this attribute (region, country, etc)
                        if ~isempty(cVDTvalindx)
                           thisdescriptn = cVDT(cVDTindx(cVDTvalindx)).DESCRIPTION;
                           expanded = 1;
                        end
                     end
                  end
                  longalttag = [longalttag '; ' thisdescriptn];
               end %n


            end

            if ~isempty(valfieldIDs)

               thisvalue = '';
               for n=1:length(valfieldIDs)

                  thisvalue = eval(['[FT(indx(k)).' ftfields{valfieldIDs(n)} ']']);
                  alttag = [alttag '; ' num2str(thisvalue)];
                  longalttag = [longalttag '; ' num2str(thisvalue)];

               end %n

            end


            alttag = alttag(3:length(alttag));
            longalttag = longalttag(3:length(longalttag));

            struc(i+1).tag2=deblank(leadblnk(alttag));
            if expanded
               struc(i+1).tag3=deblank(leadblnk(longalttag));
            end

            i=i+1;

         end % for k
      end %if

   end; %for j
end % if

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function struc = dcwtxttl(themepath,tilepath,struc,VDT,FTfilename,EntityName)


% read the feature table and the entity table. The feature table has in
% it the integer feature type and (optionally?) the name of the feature.
% The entity file contains the coordinates.

ET = dcwread(tilepath,EntityName);

etfields = fieldnames(ET); % assume name of key into feature table is second field

endofword = find(~isletter(FTfilename))-1;
matchthis = lower(FTfilename(1:endofword));
if isempty(strmatch(matchthis,lower(etfields{2}))) % field name doesn't match what was expected for key
   indx = 1:length(ET); % must be in browse layer, so there are no tiles, and we want all elements
else
   eval(['indx = [ET.' etfields{2} '];']) % retrieve only elements in this tile
end


FT  = dcwread(themepath,FTfilename,indx);


if length(ET) ~= length(FT)'
   eid = sprintf('%s:%s:tableLengths', getcomp, mfilename);
   error(eid,'%s','Feature table and entity table different lengths'); 
end


%
% find out how many feature types we have by getting the indices
% into the feature table relating to the current topological entity
% (point, edge, face)
%


FTindx = strmatch(FTfilename,{VDT.TABLE});    % the indices of the entries in the VDT pertinent to the current topology level

if isempty(FTindx)
   wid = sprintf('%s:%s:featureTable', getcomp, mfilename);
   warning(wid,'%s','No appropriate Feature Table entry in Value Description Table')
   return
end

vdtvalues = [VDT.VALUE]   ;               % all the values found in the Feature Table (over all topologies)
featurevalues = unique(vdtvalues(FTindx));   % the values found in the Feature Table (for this topology level)

%
% get the name of the attribute indexed in the Feature Table
% from the Value Description Table, since this changes from
% layer to layer
%

attributeName = deblank(VDT(FTindx(1)).ATTRIBUTE);  % assume always same (questionable?)

%
% Get all the attribute codes out of the Feature Table. Have to do
% this by converting the structure to a cell array, to work around some
% difficulty in 'eval'ing a big structure
%

attributeCol = strmatch(deblank(attributeName), fieldnames(FT));
cells = struct2cell(FT);
allFeatVals = [cells{attributeCol,:}];



i=length(struc);
for j=1:length(featurevalues)


   indx = find(featurevalues(j) == allFeatVals);
   for k=1:length(indx)

      struc(i+1).type= 'text';


      struc(i+1).tag=deblank(VDT(FTindx(j)).DESCRIPTION);
      struc(i+1).string=deblank(FT(indx(k)).TEXT);
      struc(i+1).altitude= [];



      ll = ET(indx(k)).SHAPE_LINE;


      struc(i+1).lat=ll(1,2);
      struc(i+1).long=ll(1,1);

      struc(i+1).otherproperty= {'fontsize',[9]};
      if length(ll(:,1)) > 1

         dx = ll(2,1) - ll(1,1);
         dy = ll(2,2) - ll(1,2);
         ang = 180/pi*(atan2(dy,dx));
         struc(i+1).otherproperty= {'fontsize',[9], 'rotation',ang};

      end %if

      i=i+1;
   end % for k


end; %for j

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

