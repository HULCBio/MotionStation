function varargout = projlist(varargin)
%PROJLIST List map projections supported by PROJFWD and PROJINV.
%
%  PROJFWD and PROJINV may be used to process certain forward or inverse
%  map projection.  These functions are implemented in C using the PROJ.4
%  library. PROJLIST provides a convenient list of the projections that
%  may be used with PROJFWD or PROJINV. Because PROJFWD and PROJINV accept
%  either a map projection structure (mstruct) or a GeoTIFF info structure,
%  PROJLIST provides separate lists for each case. It can also list the
%  projections for which GeoTIFF info structures may be converted to
%  MSTRUCTs.
%
%  PROJLIST(LISTMODE) displays a table of projection names, IDs and
%  availablity. LISTMODE is a string with value 'mapprojection', 'geotiff',
%  'geotiff2mstruct', or 'all'. The default value is 'mapprojection'.
%
%  S = PROJLIST(LISTMODE) returns a structure array containing projection
%  names, IDs and availablity.  
%
%  LISTMODE        DESCRIPTION OF TABLE AND STRUCTURE
%  --------        ----------------------------------
%  mapprojection   Lists the map projection IDs that are
%                  available for use with PROJFWD and PROJINV.
%                  The output structure contains the fields:
%
%                  Fieldname      Description
%                  -----------    -----------
%                  Name           The projection name.
%                  MapProjection  The projection ID string.
%
%
%  geotiff         Lists the GeoTIFF projection IDs that are
%                  available for use with PROJFWD and PROJINV.
%                  The output structure contains the fields:
%
%                  Fieldname      Description
%                  -----------    -----------
%                  GeoTIFF        The GeoTIFF projection ID string.
%                  Available      A logical array with values 1 or 0.
%
%
%  geotiff2mstruct Lists the GeoTIFF projection IDs that are
%                  available for use with GEOTIFF2MSTRUCT.
%                  The output structure contains the fields:
%
%                  Fieldname      Description
%                  -----------    -----------
%                  GeoTIFF        The GeoTIFF projection ID string.
%                  MapProjection  The projection ID string.
%
%
%  all             Lists the map and GeoTIFF projection IDs that are
%                  available for use with PROJFWD and PROJINV.
%                  The output structure contains the fields:
%
%                  Fieldname      Description
%                  -----------    -----------
%                  GeoTIFF        The GeoTIFF projection ID string.
%                  MapProjection  The projection ID string.
%                  info           A logical array with values 1 or 0.
%                  mstruct        A logical array with values 1 or 0.
%
%
%  See also GEOTIFF2MSTRUCT, MAPLIST, MAPS, PROJFWD, PROJINV.

%  Copyright 1996-2003 The MathWorks, Inc.

% Check the input count
checknargin(0,1,nargin,mfilename);

% Get a valid input string, if present
makeFcn = 'printAll';
if nargin == 1
  validStrings = {'All', 'GeoTIFF', 'GeoTIFF2Mstruct',  'MapProjection'};
  inputStr = checkstrs(varargin{1}, validStrings,mfilename,'LISTMODE',1);
  makeFcn = ['make' inputStr 'List'];
end

% Create the list 
% Print the list if nargout is 0
% otherwise return the list
list = feval(makeFcn,getProjCodes,nargout == 0);
if nargout == 1
   varargout{1} = list;
end

%--------------------------------------------------------------------------
function list = getProjCodes
id = 1;
proj = projcode(id);
list = [];

while (proj.CTcode ~= 32767)
   list(id).Name = proj.Name;
   list(id).MapProjection = proj.mapprojection;
   list(id).GeoTIFF = proj.CTProjection;
   list(id).Proj4 = proj.projname;
   id = id+1;
   proj = projcode(id);
end
[list(strmatch('Unknown',{list.MapProjection})).MapProjection] = ...
                                                 deal('[none]');
[list(strmatch('Unknown',{list.Proj4})).Proj4] = deal('[none]');

%--------------------------------------------------------------------------
function list = printAll(codes, printFlag)
list=makeMapProjectionList(codes, printFlag);

%--------------------------------------------------------------------------
function list = makeAllList(codes, printFlag)
[list(1:numel(codes)).GeoTIFF]       = deal(codes.GeoTIFF);
[list(1:numel(codes)).MapProjection] = deal(codes.MapProjection);
[list(1:numel(codes)).info]          = deal(codes.Proj4);
[list(1:numel(codes)).mstruct]       = deal(codes.MapProjection);
infoNo  =  strcmp('[none]',{list.info});
infoYes = ~infoNo;
mapNo   =  strcmp('[none]',{list.mstruct});
mapYes  = ~mapNo;

if printFlag
  header = sprintf('%s\n%s', ...
            'Availability of PROJFWD and PROJINV for use with', ...
            'GeoTIFF info or map projection structures.'); 
  [list(infoYes).info] = deal('yes');
  [list(infoNo ).info] = deal('no');
  [list(mapYes).mstruct] = deal('yes');
  [list(mapNo ).mstruct] = deal('no');
  printList('%-34s %-18s %-13s %-10s \n', ...
            header, ...
            {'GeoTIFF Projection ID', 'Map Projection ID', ...
            'GeoTIFF info', 'mstruct'}, ...
            list);
end
[list(infoYes).info] = deal(true);
[list(infoNo ).info] = deal(false);
[list(mapYes).mstruct] = deal(true);
[list(mapNo ).mstruct] = deal(false);

%--------------------------------------------------------------------------
function list = makeMapProjectionList(codes, printFlag)
[list(1:numel(codes)).Name]          = deal(codes.Name);
[list(1:numel(codes)).MapProjection] = deal(codes.MapProjection);
list(strmatch('[none]',{list.MapProjection})) = [];
if printFlag
  header = sprintf('%s\n%s', ...
            'MSTRUCTs containing the following projection IDs ', ...
            'may be used with PROJFWD and PROJINV.');
  printList('%-30s %-15s \n', ...
            header, ...
            {'Projection Name','Map Projection ID'}, ...
            list);
end

%--------------------------------------------------------------------------
function list = makeGeoTIFFList(codes, printFlag)
[list(1:numel(codes)).GeoTIFF]     = deal(codes.GeoTIFF);
[list(1:numel(codes)).Available]   = deal(codes.Proj4);
no  = strcmp('[none]',{list.Available});
yes = ~no;
if printFlag
  header = sprintf('%s\n%s', ...
            'Availability of PROJFWD and PROJINV ', ...
            'for use with GeoTIFF info structures.'); 
  [list(yes).Available] = deal('yes');
  [list(no ).Available] = deal('no');
  printList('%-35s %-15s \n', ...
            header, ...
            {'GeoTIFF Projection ID', 'Available'}, ...
            list);
end
[list(yes).Available] = deal(true);
[list(no ).Available] = deal(false);

%--------------------------------------------------------------------------
function list = makeGeoTIFF2MstructList(codes, printFlag)
[list(1:numel(codes)).GeoTIFF]       = deal(codes.GeoTIFF);
[list(1:numel(codes)).MapProjection] = deal(codes.MapProjection);
list(strmatch('[none]',{list.MapProjection})) = [];
if printFlag
  header = sprintf('%s\n%s\n%s', ...
            'GeoTIFF info structures containing the following', ...
            'GeoTIFF projection IDs may be converted to MSTRUCTs', ...
            'using GEOTIFF2MSTRUCT.');
  printList('%-30s %-15s \n', ...
            header,  ...
            {'GeoTIFF Projection ID', 'Map Projection ID'}, ...
            list);
end

%--------------------------------------------------------------------------
function printList(formatstr, heading, colHeading, list)
fprintf('\n%s\n\n',heading)
underscore = cell(1,numel(colHeading));
for i=1:numel(colHeading)
   underscore{i} = repmat('-',1,numel(colHeading{i}));
end
fprintf(formatstr, colHeading{:});
fprintf(formatstr, underscore{:});
s=struct2cell(list);
fprintf(formatstr,s{:});

%--------------------------------------------------------------------------
function list = makeTableList(list, printFlag)
if printFlag
  printList('%-38s %-15s %-35s %-15s \n', ...
     'PROJ.4 Projections.', ...
     {'Projection Name', 'Projection ID', 'GeoTIFF CTProjection', 'PROJ.4'}, ...
     list);
end



