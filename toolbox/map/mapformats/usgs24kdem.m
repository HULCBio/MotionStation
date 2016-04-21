function [latgrat,longrat,mat,Astruc,Bstruc] = usgs24kdem(filename, ...
                                           scalefactor,latlim,lonlim,gsize)
% USGS24KDEM Read USGS 1:24,000 (30 m) Digital Elevation Model files.
% 
%   [latgrat,longrat,mat] = USGS24KDEM reads a USGS 1:24,000 Digital 
%   Elevation Map (DEM) file in standard format.  The file is selected 
%   interactively.  The entire file is read and subsampled by a factor of
%   5,  and returned as a general matrix map.  The 1:24,000 series of DEMs
%   are  stored as a grid of elevations spaced 30 meters apart. The number
%   of  points in a file will vary with the geographic location.
%   
%   [latgrat,longrat,mat] = USGS24KDEM(filename) specifies the name of the 
%   DEM file.
%   
%   [latgrat,longrat,mat] = USGS24KDEM(filename,scalefactor) subsamples the
%   file by the scalefactor.  if omitted, the default is 5, which returns 
%   every 5th point.
%   
%   [latgrat,longrat,mat] = USGS24KDEM(filename,scalefactor,latlim,lonlim) 
%   returns data focusing on the requested geographic area. The area is 
%   specified as two element vectors in units of degrees. The data  will
%   extend somewhat outside the requested area. If omitted, the  entire
%   area covered by the DEM file is returned.
%   
%   [latgrat,longrat,mat] =
%   USGS24KDEM(filename,scalefactor,latlim,lonlim,gsize)  also controls the
%   graticule size. gsize is a two element vector  specifying the number of
%   rows and columns in the latitude and longitude  matrices. If omitted, a
%   graticule the same size as the map is returned. Use empty matrices for
%   latlim and lonlim to specify the graticule size without specifying the
%   geographic limits.
% 
%   [latgrat,longrat,mat,A,B] = USGS24KDEM(...) also returns the contents
%   of  the A and B records of the DEM file. The A record is a header to
%   the file  containing descriptions of the data. The B record is the raw
%   profile data  from which the matrix map is constructed.
%   
%   The data files can be obtained by contacting the U.S. Geological
%   Survey.   Other agencies have made some of the data available online.
%   A source for  data for the San Francisco Bay area is
%   <http://bard.wr.usgs.gov/> and
%   <ftp://bard.wr.usgs.gov/bard/dem/dems24k/>
%   
%   Extensive documentation on the data format and standards are available
%   from <http://mapping.usgs.gov/www/ti/DEM/standards_dem.html> and 
%   <ftp://mapping.usgs.gov/pub/ti/DEM/demguide/>
%   
%   See also USGSDEM, GTOPO30, SATBATH, TBASE, ETOPO5

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:24:03 $

if nargin < 1; 	filename = []; 		end
if nargin < 2;	scalefactor=5; 		end
if nargin < 3;	latlim = [];		end
if nargin < 4;	lonlim = [];		end
if nargin < 5;	gsize = [];			end

% if subset, check limits of bounding box and bail if outside


fid = -1;
if ~ isempty(filename); 
	fid = fopen(filename,'r');
end

if fid==-1
	[filename, path] = uigetfile('', 'Please select the USGS 1:24,000 DEM file');
	if filename == 0 ; return; end
	filename = [path filename];
	fid = fopen(filename,'r');
end

% Define the structure of the header records and data records

Afield = Adescription;

% Read the header record. Some fields may be empty, so assume 
% a fixed format as documented in the DEM Data User's Guide 5 (1993),
% and read the header field-by-field.

Astruc = readfields(filename,Afield,1,'native',fid);

if Astruc.PlanimetricReferenceSystemCode == 0
	error('DEM file is in geographic coordinates, not UTM. Try using USGSDEM.')	
elseif Astruc.PlanimetricReferenceSystemCode ~= 1
	error('DEM file is not in UTM coordinates.')
end

% define a map structure for the UTM data
% Need to check that UTM updates values properly

mstruct = defaultm('utm');
mstruct.zone = [num2str(Astruc.Zone) 'T'];  % remove extraneous 'T' when UTM modified
% mstruct.geoid = almanac('earth','clarke66','km'); % make depend on data in structure if available
mstruct.geoid = almanac('earth','clarke66','meters'); % make depend on data in structure if available
mstruct.maplatlimit = [];
mstruct.maplonlimit = [];
mstruct.origin = [];

mstruct = defaultm(utm(mstruct));
mstruct.maplonlimit = [];


%%***** had to remove the hard coding of zone in UTM(1arg)


% spatial resolutions
deltax = Astruc.XYZresolutions(1);
deltay = Astruc.XYZresolutions(2);
deltaz = Astruc.XYZresolutions(3);
rot = Astruc.RotationAngle;

% Just in case the number of rows and columns aren't provided, read 
% until something doesn't look right.

if isempty(Astruc.NrowsCols)
	nprofiles = 1e9; % do while not end of file
else
	nprofiles  = Astruc.NrowsCols(2);
end


% Read the B records

% Move forward a couple off characters to skip to the next record. 
% Some files seem to have a few more fields of data in the A record  
% that are not decribed in DEM Data User's Guide 5 (1993). 


fseek(fid,20,'cof');


% The 24k/30 meter UTM DEM data has a variable number of points per row.
% File may or may not have line endings in them, making the byte 
% locations of the data change. So read all of the profiles into a structure
% using sequential formatted reads.

% keep track of the max and min locations so we can later make a rectangular matrix
maxn = -inf; minn = inf;
maxe = -inf; mine = inf;

for i=1:nprofiles
	
	% read the raw data
	[rowcol,count] 		= fscanf(fid,'%d',2);	if count ~= 2; break; end
	[nelev,count] 		= fscanf(fid,'%d',2);	if count ~= 2; break; end
	[x0y0,count] 		= fscanfdouble(fid,2);	if count ~= 2; break; end
	[localdatum,count] 	= fscanfdouble(fid,1);	if count ~= 1; break; end
	[minmaxelev,count] 	= fscanfdouble(fid,2);	if count ~= 2; break; end
	[profile,count] 	= fscanf(fid,'%d',nelev(1)); % in normalized elevations
												if count ~= nelev(1); break; end

	% If we're still here at this point, this must still be a part of the
	% B record, so start saving the elements, and compute the derived 
	% quantities like actual elevations and location.

	Bstruc(i).rowcol 		= rowcol;
	Bstruc(i).nelev 		= nelev;
	Bstruc(i).x0y0 			= x0y0;
	Bstruc(i).localdatum 	= localdatum;
	Bstruc(i).minmaxelev 	= minmaxelev;

	Bstruc(i).profile = profile * deltaz + localdatum;

	% Convert raw data to actual locations (UTM coordinates, elevations)
						
	% Locations in rotated coordinate system with origin at the first point
	% Profiles are lines south to north, first profile is west, profiles
	% move progressively east
	
	y = (0:Bstruc(i).nelev(1)-1) * deltay ;
	x = zeros(size(y));
	
	easting  = Bstruc(i).x0y0(1) + x*cos(rot) - y*sin(rot);
	Bstruc(i).easting = easting(:);
	
	northing = Bstruc(i).x0y0(2) + x*sin(rot) + y*cos(rot);
	Bstruc(i).northing = northing(:);
	
	
	maxn = max(maxn,max(northing));
	minn = min(minn,min(northing));
	maxe = max(maxe,max(easting));
	mine = min(mine,min(easting));
	
	pos = ftell(fid); % to reposition after reading past the end of the B record
	
end

% fill in with NaNs to make a rectangular matrix

yres = Astruc.XYZresolutions(2);
nrows = (maxn-minn)/yres+1;
ncols = nprofiles;
x1 = mine;
y1 = maxn;
yperrow = -Astruc.XYZresolutions(2);
xpercol =  Astruc.XYZresolutions(1);

mat = repmat(NaN,nrows,ncols);

for i=1:nprofiles
	ntop = round((maxn-max(Bstruc(i).northing))/yres);
	nbot = round((min(Bstruc(i).northing)-minn)/yres);
	mat(:,i) = 	flipud([repmat(NaN,[nbot 1]); Bstruc(i).profile; repmat(NaN,[ntop 1])]);
end

% At this point we have a rectangular grid in projected coordinates.

if isempty(latlim) | isempty(lonlim) 	% return the whole matrix
	rlim = [1 nrows];
	clim = [1 ncols];
else									% Map requested region into the matrix 
	
	% ensure that latlim and lonlim are within the ranges ? and ?
	latlim = latlim(:)';
	lonlim = lonlim(:)';
	
	lonlim = npi2pi(lonlim);

	% Construct a frame around desired region
	[latfrm,lonfrm] = framemll(latlim,lonlim,10);

	% Transform the frame to projected coordinates and then to row and column indices
		
	[xfrm,yfrm] = mfwdtran(mstruct,latfrm,lonfrm);
	[rfrm,cfrm] = yx2rc(yfrm,xfrm,y1,x1,yperrow,xpercol);

% Find the extent of the desired region in matrix indices. This is
% necessary because the desired region is not rectangular in the 
% projected data. The returned data will extend beyond the requested
% region

	rlim = [max([1,min(rfrm)]) min([max(rfrm),nrows])];
	clim = [max([1,min(cfrm)]) min([max(cfrm),ncols])];
end

% extract the map matrix

readrows = rlim(1):scalefactor:rlim(2);
readcols = clim(1):scalefactor:clim(2);

oldmat = mat;

mat = mat(readrows,readcols);

% construct a graticule of row and column indices

if isempty(gsize) 											% size(grat) = size(mat)
	[rIndGrat,cIndGrat] = meshgrat(readrows,readcols);
else  													% texture map the data to a smaller graticule
	[rIndGrat,cIndGrat] = meshgrat([min(readrows) max(readrows)],[min(readcols) max(readcols)],gsize);
end

% map row and column graticule to x and y values
  
[ygrat,xgrat] = rc2yx(rIndGrat,cIndGrat,y1,x1,yperrow,xpercol);

% map x and y graticule to lat and long

[latgrat,longrat] = minvtran(mstruct,xgrat,ygrat);

% reposition and read C record

fclose(fid);

% Convert codes to text fields

if nargout > 3
	Astruc = explainA(Astruc);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function a = Adescription

% Data Set Identification (A) record contents

% Data Set Identification (A) record contents

a( 1).length = 40;    a( 1).name = 'Quadrangle name';      
a( 2).length = 40;    a( 2).name = 'Textual Info';      
a( 3).length = 55;    a( 3).name = 'Filler';
a( 4).length = 1;     a( 4).name = 'Process Code';     
a( 5).length = 1;     a( 5).name = 'Filler2';     
a( 6).length = 3;     a( 6).name = 'Sectional Indicator';        
a( 7).length = 4;     a( 7).name = 'MC origin Code';        
a( 8).length = 1;     a( 8).name = 'DEM level Code'; 						a(8).type = '%6g';    
a( 9).length = 1;     a( 9).name = 'Elevation Pattern Code'; 				a(9).type = '%6g';    
a(10).length = 1;     a(10).name = 'Planimetric Reference System Code'; 	a(10).type = '%6g'; 
a(11).length = 1;     a(11).name = 'Zone';      							a(11).type = '%6g';
a(12).length = 15;    a(12).name = 'Projection Parameters'; 				a(12).type = '%24D';  
a(13).length = 1;     a(13).name = 'Horizontal Units';  					a(13).type = '%6g';       
a(14).length = 1;     a(14).name = 'Elevation Units';  						a(14).type = '%6g';   
a(15).length = 1;     a(15).name = 'N sides To Bounding Box'; 				a(15).type = '%6g';    
a(16).length = 8;     a(16).name = 'Bounding Box';     						a(16).type = '%24D';
a(17).length = 2;     a(17).name = 'Min Max Elevations';        			a(17).type = '%24D';
a(18).length = 1;     a(18).name = 'Rotation Angle';     					a(18).type = '%24D';
a(19).length = 1;     a(19).name = 'Accuracy Code';       					a(19).type = '%6g';
a(20).length = 3;     a(20).name = 'XYZ resolutions ';        				a(20).type = '%12E';
a(21).length = 2;     a(21).name = 'Nrows Cols';      						a(21).type = '%6g';

% Old format stops here

a(22).length = 1;     a(22).name = 'MaxPcontourInt';      					a(22).type = '%5g';
a(23).length = 1;     a(23).name = 'SourceMaxCintUnits';     				a(23).type = '%1g';
a(24).length = 1;     a(24).name = 'Smallest Primary';        				a(24).type = '%5g';
a(25).length = 1;     a(25).name = 'SourceMinCintUnits';      				a(25).type = '%1g';
a(26).length = 1;     a(26).name = 'Data Source Date';        				a(26).type = '%4g';
a(27).length = 1;     a(27).name = 'DataInspRevDate';       				a(27).type = '%4g';
a(28).length = 1;     a(28).name = 'InspRev Flag';        
a(29).length = 1;     a(29).name = 'DataValidationFlag'; 	      			a(29).type = '%1g';
a(30).length = 1;     a(30).name = 'SuspectVoidFlag';    	    			a(30).type = '%2g';
a(31).length = 1;     a(31).name = 'Vertical Datum';       					a(31).type = '%2g';
a(32).length = 1;     a(32).name = 'Horizontal Datum';        				a(32).type = '%2g';
a(33).length = 1;     a(33).name = 'DataEdition';       					a(33).type = '%4g';
a(34).length = 1;     a(34).name = 'Percent Void';      					a(34).type = '%4g';



for i=1:length(a);
    if isempty(a(i).type)
		a(i).type = 'char';
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [b,bdata] = Bdescription

% Elevation Data (B) record contents


b( 1).type = '%6g';		b( 1).length = 2;     b( 1).name = 'RowColID';      
b( 2).type = '%6g';		b( 2).length = 2;     b( 2).name = 'NElevations';      
b( 3).type = '%24D';	b( 3).length = 2;     b( 3).name = 'XYstart';
b( 4).type = '%24D';	b( 4).length = 1;     b( 4).name = 'LocalDatumElevation';     
b( 5).type = '%24D';	b( 5).length = 2;     b( 5).name = 'MinMaxElevations';     
b( 6).type = '%6g';	    b( 6).length = 0;     b( 6).name = 'Profile';     

bdata( 1).type = '%6g';	
bdata( 1).length = [];     
bdata( 1).name = 'Profile';        

% field 6 is variable length, so reset field(6).length based what is read for field 2

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [number,count] = fscanfdouble(fid,n)

% scans one fortran style double precision formatted number

number = [];
for i=1:n
	str = fscanf(fid,'%s',1);
	str = strrep(str,'D','e');
	number = [number ; sscanf(str,'%e')];
end

count = length(number);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function A = explainA(A)
% Fill in text associated with numeric codes in the USGS DEM A record

if ~isempty(A.ProcessCode)
	switch A.ProcessCode
	case '1' , A.ProcessCode = 'GPM';
	case '2' , A.ProcessCode = 'Manual Profile';
	case '3' , A.ProcessCode = 'DLG2DEM';
	case '4' , A.ProcessCode = 'DCASS';
	end
end
	

if ~isempty(A.ElevationPatternCode)
	switch A.ElevationPatternCode
	case 1, A.ElevationPatternCode = 'regular';
	case 2, A.ElevationPatternCode = 'random';
	end
end

if ~isempty(A.PlanimetricReferenceSystemCode)
	switch A.PlanimetricReferenceSystemCode
	case 0, A.PlanimetricReferenceSystemCode = 'Geographic';
	case 1, A.PlanimetricReferenceSystemCode = 'UTM';
	case 2, A.PlanimetricReferenceSystemCode = 'State Plane';
	end
end

if ~isempty(A.HorizontalUnits)
	switch A.HorizontalUnits
	case 0, A.HorizontalUnits = 'radians';
	case 1, A.HorizontalUnits = 'feet';
	case 2, A.HorizontalUnits = 'meters';
	case 3, A.HorizontalUnits = 'arc-seconds';
	end
end
	
if ~isempty(A.ElevationUnits)
	switch A.ElevationUnits
	case 1, A.ElevationUnits = 'feet';
	case 2, A.ElevationUnits = 'meters';
	end
end
	
if ~isempty(A.AccuracyCode)
	switch A.AccuracyCode
	case 0, A.AccuracyCode = 'unknown accuracy';
	case 1, A.AccuracyCode = 'accuracy information in record C';
	end
end
	
if ~isempty(A.SourceMaxCintUnits)
	switch A.SourceMaxCintUnits
	case 0, A.SourceMaxCintUnits = 'N.A.';
	case 1, A.SourceMaxCintUnits = 'feet';
	case 2, A.SourceMaxCintUnits = 'meters';
	end
end
	
if ~isempty(A.SourceMinCintUnits)
	switch A.SourceMinCintUnits
	case 1, A.SourceMinCintUnits = 'feet';
	case 2, A.SourceMinCintUnits = 'meters';
	end
end
	
if ~isempty(A.DataValidationFlag)
	switch A.DataValidationFlag
	case 0, A.DataValidationFlag = 'No validation performed';
	case 1, A.DataValidationFlag = 'TESDEM (record C added) no qualitative test (no DEM Edit System [DES] review)';
	case 2, A.DataValidationFlag = 'Water body edit and TESDEM run';
	case 3, A.DataValidationFlag = 'DES (includes water edit) no qualitiative test (no TESDEM)';
	case 4, A.DataValidationFlag = 'DES with record C added, qualitative and quantitative tests for level 1 DEM';
	case 5, A.DataValidationFlag = 'DES and TESTDEM qualitative and quantitative tests for levels 2 and 3 DEMs';
	end
end
	
if ~isempty(A.SuspectVoidFlag)
	switch A.SuspectVoidFlag
	case 0, A.SuspectVoidFlag = 'none';
	case 1, A.SuspectVoidFlag = 'suspect areas';
	case 2, A.SuspectVoidFlag = 'void areas';
	case 3, A.SuspectVoidFlag = 'suspect and void areas';
	end
end
	
if ~isempty(A.VerticalDatum)
	switch A.VerticalDatum
	case 1, A.VerticalDatum = 'local means sea level';
	case 2, A.VerticalDatum = 'National Geodetic Vertical Datum 1929 (NGVD 29)';
	case 3, A.VerticalDatum = 'North American Vertical Datum 1988 (NAVD 88)';
	end
end
	
if ~isempty(A.HorizontalDatum)
	switch A.HorizontalDatum
	case 1, A.HorizontalDatum = 'North American Datum 1927 (NAD27)';
	case 2, A.HorizontalDatum = 'World Geodetic System 1972 (WGS72)';
	case 3, A.HorizontalDatum = 'WGS84';
	case 4, A.HorizontalDatum = 'NAD83';
	case 5, A.HorizontalDatum = 'Old Hawaii Datum';
	case 6, A.HorizontalDatum = 'Puerto Rico Datum';
	case 7, A.HorizontalDatum = 'NAD 83 Provisional';
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [latfrm,lonfrm] = framemll(framelat,framelon,fillpts)

%FRAMELL returns the unprojected frame points for lat and long limits

epsilon   = 1000*epsm('degrees');


% Construct the frame

framelat = framelat + [epsilon -epsilon];    %  Avoid clipping at edge of
framelon = framelon + [epsilon -epsilon];    %  of map

lats = linspace(min(framelat),max(framelat),fillpts)';       %  Fill vectors with
lons = linspace(min(framelon),max(framelon),fillpts)';   %  frame limits

latfrm = [lats;           framelat(2)*ones(size(lats));  %  Construct
	      flipud(lats);   framelat(1)*ones(size(lats))]; %  complete frame
lonfrm = [framelon(1)*ones(size(lons));    lons;         %  vectors
          framelon(2)*ones(size(lons));    flipud(lons);];


