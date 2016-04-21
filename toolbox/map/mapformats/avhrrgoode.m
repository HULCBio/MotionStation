function [latgrat,longrat,mat] = avhrrgoode(region,filename, ...
                                   scalefactor,latlim,lonlim, ...
                                   gsize,fnrows,fncols,resolution,precision)
%AVHRRGOODE Read AVHRR data stored in the Goode Projection.
% 
%  [LATGRAT, LONGRAT, MAP] = AVHRRGOODE reads data from an Advanced Very
%  High Resolution Radiometer (AVHRR) dataset with a nominal resolution of
%  1 km  that is stored in the Goode projection.  Data of this type
%  includes a  nondimensional vegetation index (NDVI) and Global Land Cover
%  Characteristics (GLCC).  These files have 17347 rows and 40031 columns
%  of  data, or somewhat more than the capacity of one CD-ROM. The file is 
%  selected interactively.  Data is returned as a general matrix map with
%  the  graticule matrices in units of degrees.
% 
%  [...] = AVHRRGOODE(REGION) Reads data from a file with data covering the
%  specified region.  Valid regions are 'g' or 'global', 'af' or 'africa',
%  'ap' or 'australia/pacific', 'ea' or 'eurasia', 'na' or 'north america',
%  'sa' or 'south america', 'af' or 'africa'.  The file is selected
%  interactively.  If omitted, 'global' is assumed.
%  
%  [...] = AVHRRGOODE(REGION, FILENAME) uses the provided filename.
%  
%  [...] = AVHRRGOODE(REGION, FILENAME, SCALEFACTOR) uses the integer
%  scalefactor to downsample the data.  A scalefactor of 1 returns every
%  point.  A  scalefactor of 10 returns every 10th point.  If omitted, 100
%  is assumed.
%  
%  [...] = AVHRRGOODE(REGION, FILENAME, SCALEFACTOR, LATLIM, LONLIM)
%  returns data for  the specified region.  The returned data will extend
%  somewhat beyond the  requested area.  If omitted, the entire area
%  covered by the data file is  returned. The limits are two element
%  vectors in units of degrees, with  latlim in the range [-90 90] and
%  lonlim in the range [-180 180].
% 
%  [...] = AVHRRGOODE(REGION, FILENAME, SCALEFACTOR, LATLIM, LONLIM, GSIZE)
%  controls the size of the graticule matrices.  Gsize is a two-element
%  vector  containing the number of rows and columns desired.  If omitted,
%  a  graticule the size of the map is returned.
% 
%  [...] = AVHRRGOODE(REGION, FILENAME, SCALEFACTOR, LATLIM, LONLIM, GSIZE,
%  FNROWS, FNCOLS)  overrides the standard file format for the selected
%  region.  This is  useful for data stored on CD-ROM, which may have been
%  truncated to fit.   Some data was distributed with 16347 rows and 40031
%  columns of data on  CD-ROMS. Nondimensional vegetation index data at 8
%  km spatial resolution  has 2168 rows and 5004 columns.
% 
%  [...] = AVHRRGOODE(REGION, FILENAME, SCALEFACTOR, LATLIM, LONLIM, GSIZE,
%  FNROWS, FNCOLS, RESOLUTION) reads a dataset with the spatial resolution
%  specified in meters.  If omitted, the full resolution of 1000 meters is
%  assumed.  Data is also available at 8000 meter resolution.
% 
%  [...] = AVHRRGOODE(REGION, FILENAME, SCALEFACTOR, LATLIM, LONLIM,
%  GSIZE, FNROWS, FNCOLS, RESOLUTION, PRECISION) reads a dataset with
%  the integer  precision specified.  If omitted, 'uint8' is assumed.
%  'uint16' is  appropriate for some files.  Check the data's README file
%  for  specification of the file format and contents.
% 
%  The AVHRR project and datasets are described in 
%    http://daac.gsfc.nasa.gov/DATASET_DOCS/avhrr_dataset.html
%    http://daac.gsfc.nasa.gov/CAMPAIGN_DOCS/FTP_SITE/readmes/pal.html
%    http://edcwww.cr.usgs.gov/landdaac/1KM/1kmhomepage.html
%    http://edcwww.cr.usgs.gov/landdaac/glcc/glcc_na.html
%  
%  Some sources for the data include
%    <ftp://daac.gsfc.nasa.gov/data/avhrr/>
%    <ftp://edcftp.cr.usgs.gov/pub/data/glcc/>
%
%  This function reads the binary files as-is. You should not use byte
%  swapping software on these files.
% 
%  See also AVHRRLAMBERT.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by: W. Stumpf
%  $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:20:46 $


checknargin(1,10,nargin,mfilename);
if nargin ==0; region = 'global'; end
checkinput(region,{'char'},{},mfilename,'REGION',1);

% There's an 8 km dataset in the goode projection too
% <ftp://daac.gsfc.nasa.gov/data/avhrr/Readme.pal>

if nargin < 9
	resolution = 1000; % meters
end

yperrow = -resolution; 		% Meters
xpercol =  resolution; 		% Meters

switch lower(region)
case {'g','global'}
	nrows = 17347;   % 16347 for some data on cd-rom
	ncols = 40031;   % 40031
	y1 =   8673000-xpercol/2;			% Numbers from Steinwand Web page, referenced above
	x1 = -20015000-yperrow/2;
case {'af','africa'}
	nrows = 8676;
	ncols = 8350;
	x1 = -1998000;
	y1 =  4529000;
case {'ap','australia/pacific'}
	nrows = 7700;
	ncols = 9100;
	x1 = 10084000;
	y1 =  2374000;
case {'sa','south america'}
	nrows = 8016;
	ncols = 5632;
	x1 = -9276000;
	y1 = 1630000;
case {'ea','eurasia'}
	nrows = 8570;
	ncols = 13800;
	x1 = -215000; % garbage or minus sign in original document? 
	y1 = 8673000;
case {'na','north america'}
	nrows = 7793;
	ncols = 11329;
	x1 = -17359000;
	y1 = 8423000;
otherwise
   eid = sprintf('%s:%s:invalidRegionString', getcomp, mfilename);
	error(eid,'%s\n%s\n%s\n%s\n%s\n%s\n%s','Valid region strings are ', ...
			'   ''g''  or ''global'', ', ...
			'   ''ap'' or ''australia/pacific'', ', ...
			'   ''ea'' or ''eurasia'', ', ...
			'   ''na'' or ''north america'', ', ...
			'   ''sa'' or ''south america'', ', ...
			'   ''af'' or ''africa''.' );
 end

% defaults

if nargin < 2; filename = []; 		end
if nargin < 3;	scalefactor=100; 	end
if nargin < 4;	latlim = [-90 90];	end
if nargin < 5;	lonlim = [-180 180];end
if nargin < 6;	gsize = [];			end
if nargin < 7;	fnrows = nrows;		end
if nargin < 8;	fncols = ncols;		end
if nargin < 10; precision = 'int8'; end

% ensure row vectors

latlim = latlim(:)';
lonlim = npi2pi(lonlim(:)'); % No effort made (yet) to work across the dateline


% Check input arguments
checkinput(filename,{'char'},{},mfilename,'FILENAME',2);
checkinput(scalefactor, {'numeric'}, {'scalar'}, mfilename, 'SCALEFACTOR', 3);
if ~isequal([1 2],size(latlim));					
   eid = sprintf('%s:%s:invalidLATLIM', getcomp, mfilename);
   error(eid,'%s','latlim must be a two element vector in units of degrees'); 
end 
if ~isequal([1 2],size(lonlim)); 					
   eid = sprintf('%s:%s:invalidLONLIM', getcomp, mfilename);
   error(eid,'%s','lonlim must be a two element vector in units of degrees'); 
end 
if ~isempty(gsize) && ~isequal([1 2],size(gsize)); 	
   eid = sprintf('%s:%s:invalidGSIZE', getcomp, mfilename);
   error(eid,'%s','gsize must be a two element vector or an empty matrix'); 
end 
checkinput(fnrows,    {'numeric'}, {'scalar'}, mfilename,'FNROWS', 7);
checkinput(fncols,    {'numeric'}, {'scalar'}, mfilename,'FNCOLS', 8);
checkinput(resolution,{'numeric'},{},          mfilename,'RESOLUTION',9);
checkinput(precision, {'char'},   {},          mfilename,'PRECISION',10);


% This data is stored in an interrupted goode projection. Each region 
% must be considered a different projection. Identify regions
% containing data

indx = dogoodeproj(latlim,lonlim);

% Convert latitude and longitude limits to x and y limits

mstruct = defaultm(defaultm('goode'));

mstruct.maplatlimit = latlim; mstruct.flatlimit = [];
mstruct.maplonlimit = lonlim; mstruct.flonlimit = [];
mstruct = defaultm(goode(mstruct));
[requestlat,requestlon] = framemll(mstruct);

xlim = [];
ylim = [];
for i=1:length(indx)
		mstruct = avhrrprj(mstruct,indx(i));
		[xinproj,yinproj] = mfwdtran(mstruct,requestlat,requestlon,[],'patch');
		xlim = [xlim; xinproj(~isnan(xinproj))];
		ylim = [ylim; yinproj(~isnan(yinproj))];
end

xlim = [min(xlim) max(xlim)];
ylim = [min(ylim) max(ylim)];

% Convert x and y limits to row and column limits

[rlim,clim] = yx2rc(ylim,xlim,y1,x1,yperrow,xpercol); 
rlim=flipud(rlim(:))';

rlim = [max([1,min(rlim)]) min([max(rlim),fnrows])];
clim = [max([1,min(clim)]) min([max(clim),fncols])];


% read the data

readrows = rlim(1):scalefactor:rlim(2);
readcols = clim(1):scalefactor:clim(2);

mat = readmtx(filename,fnrows,fncols,precision,readrows,readcols,'ieee-be'); 
if isempty(mat); return; end

% construct a graticule of row and column indices

if isempty(gsize)											% size(grat) = size(mat)
	[rIndGrat,cIndGrat] = meshgrat(readrows,readcols);
else  													% texture map the data to a smaller graticule
	[rIndGrat,cIndGrat] = meshgrat([min(readrows) max(readrows)],[min(readcols) max(readcols)],gsize);
end

% map row and column graticule to x and y values
% issues about centers and corners of cells?
  
[ygrat,xgrat] = rc2yx(rIndGrat,cIndGrat,y1,x1,yperrow,xpercol);

ygrat = ygrat-yperrow/2;
xgrat = xgrat-xpercol/2;

latgrat = NaN*ones(size(ygrat));
longrat = NaN*ones(size(xgrat));

% projections containing data

indx = dogoodeproj(latlim,lonlim);

% graticule points within the projection are transformed to geographic coordinates

for i=1:length(indx)

	mstruct = avhrrprj(mstruct,indx(i)); % current projection

% find points that are inside the current projection

% 	if isequal(latlim,[-90 90]) & isequal(lonlim,[-180 180]) & strcmp(region(1),'g')
% 		inproj = inframe2(xgrat,ygrat,mstruct);% uses matrices - faster but not general
% 	else
		inproj = inframe(xgrat,ygrat,mstruct); % uses inpolygon - general but slow
% 	end

	[latInFrame,lonInFrame] = minvtran(mstruct,xgrat(inproj),ygrat(inproj));% map x and y graticule to lat and long
	
	latgrat(inproj) = latInFrame;
	longrat(inproj) = lonInFrame;
end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function indx = dogoodeproj(latlim,lonlim)

platlim = [ ...
	0 90		% region 1 and 3
	0 90		% region 2 and 4
	-90 0		% region 5 and 9
	-90 0		% region 6 and 10
	-90 0		% region 7 and 11
	-90 0		% region 8 and 12
	];
	
plonlim = [ ...
	-180  -40		% region 1 and 3
	 -40  180		% region 2 and 4
	-180 -100		% region 5 and 9
	-100  -20		% region 6 and 10
	 -20   80		% region 7 and 11
	  80  180		% region 8 and 12
	];

indx = ...
 find( ...
		(...
		(latlim(1) <= platlim(:,1) & latlim(2) >= platlim(:,2)) | ... % tile is completely within region
		(latlim(1) >= platlim(:,1) & latlim(2) <= platlim(:,2)) | ... % region is completely within tile
		(latlim(1) >  platlim(:,1) & latlim(1) <  platlim(:,2)) | ... % min of region is on tile
		(latlim(2) >  platlim(:,1) & latlim(2) <  platlim(:,2))   ... % max of region is on tile
		) ...
			&...
		(...
		(lonlim(1) <= plonlim(:,1) & lonlim(2) >= plonlim(:,2)) | ... % tile is completely within region
		(lonlim(1) >= plonlim(:,1) & lonlim(2) <= plonlim(:,2)) | ... % region is completely within tile
		(lonlim(1) >  plonlim(:,1) & lonlim(1) <  plonlim(:,2)) | ... % min of region is on tile
		(lonlim(2) >  plonlim(:,1) & lonlim(2) <  plonlim(:,2))   ... % max of region is on tile
		)...
	);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function indx = goodeprojindx(lat,lon)
%goodeprojindx returns indices of Goode projection regions from latlim and lonlim

% eastern half of greenland data actually in a north american gore, inconsistent 
% with Steinwand specs. To fix this, need to redefine the north american gore in to 
% the separate sinusoid and mollweid parts, and extend the northern section furthur 
% east. Also have to redefine the european gores.

platlim = [ ...
	0 90		% region 1 and 3
	0 90		% region 2 and 4
	-90 0		% region 5 and 9
	-90 0		% region 6 and 10
	-90 0		% region 7 and 11
	-90 0		% region 8 and 12
	];
	
plonlim = [ ...
	-180  -40		% region 1 and 3
	 -40  180		% region 2 and 4
	-180 -100		% region 5 and 9
	-100  -20		% region 6 and 10
	 -20   80		% region 7 and 11
	  80  180		% region 8 and 12
	];

indx = ...
 find( ...
		(...
		(lat >=  platlim(:,1) & lat <=  platlim(:,2))  ... % min of region is on tile
		) ...
			&...
		(...
		(lon >=  plonlim(:,1) & lon <=  plonlim(:,2))  ... % min of region is on tile
		)...
	);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function inmat = inframe(xgrid,ygrid,mstruct)

%INFRAME returns a matrix the size of xgrid with 1 for points within the frame, 
% and 0 for points outside. Uses INPOLYGON. 

% construct the frame

[xframe,yframe] = frame(mstruct);

% reduce the number of points in the frame to avoid running out of memory in inpolygon

[xframe,yframe] = reducem(xframe,yframe);

% inpolygon is optimized for speed over memory usage. 

for i=1:size(ygrid,1)
	if any(~isnan(ygrid(i,:)))
		in = double(inpolygon(xgrid(i,:),ygrid(i,:),xframe,yframe));
		in(in == 0) = NaN;
		xgrid(i,:) = xgrid(i,:).*in; ygrid(i,:) = ygrid(i,:).*in;
	end
end

inmat = ~isnan(xgrid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function mat = inframe2(xgrat,ygrat,mstruct)

%INFRAME2 returns a matrix the size of xgrid with 1 for points within the frame, 
% and 0 for points outside. Uses matrix maps. Can't use for subsets of the world,
% because frame may be complete off the map because it encloses it entirely, or it 
% doesn't.


% construct the frame

[xframe,yframe] = frame(mstruct);

% The following code was adapted from VEC2MTX

% interpolate for conversion to matrix

dx = diff(xgrat(1,1:2)); % square pixels
scale = 1/dx;
[xframe,yframe] = interpm(xframe,yframe,(0.6/scale));

xlim = [min(xframe(:)) max(xframe(:))];
ylim = [min(yframe(:)) max(yframe(:))];

% convert to matrix. Suppress warnings about points outside of map

mat = zeros(size(xgrat));

[rowfrm,colfrm] = yx2rc(yframe,xframe,ygrat(1)-dx/2,xgrat(1)+dx/2,-dx,dx);

mat(sub2ind(size(mat),rowfrm,colfrm)) = 1; % like imbedm


% Optional fill

[r,c] = size(mat);
mat = encodem(mat,[1 1 2],1) ;% floodfill region outside face
mat = encodem(mat,[1 c 2],1) ;% floodfill region outside face
mat = encodem(mat,[r 1 2],1) ;% floodfill region outside face
mat = encodem(mat,[r c 2],1) ;% floodfill region outside face


% identify points within the frame

mat = (mat <= 1);

	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xframe,yframe] = frame(mstruct)

%FRAME returns the projected frame points

[latfrm,lonfrm] = framemll(mstruct);

%  Reset the origin so that the frame is computed relative to the
%  base projection (not a potentially skewed rotation)

mstruct.origin = [0 0 0];

% Transform the frame data to projected coordinates

[xframe,yframe] = mfwdtran(mstruct,latfrm,lonfrm);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [latfrm,lonfrm] = framemll(mstruct)

%FRAMELL returns the unprojected frame points

fillpts    = mstruct.ffill;

framelat  = sort(mstruct.flatlimit);
framelon  = sort(mstruct.flonlimit);

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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function out = avhrrprj(h,region)

%AVHRRPRJ defines one region in the Goode projection used for AVHRR data
%
% AVHRR(h,region) changes the projection of the map axes with handle h to 
% a subset of the Goode projection in which Advanced Very High Resolution 
% Radiometer (AVHRR) data is stored. The subset is defined by an integer 
% region number from 1 to 6. The regions are: 1) North America, 
% 2) North Africa, Europe and Asia, 3) South Pacific, 4) South America, 
% 5) Southern Africa and 6) Australia.
%
% mstruct = AVHRRPRJ(h,region) also returns the map structure for the region 
% in mstruct. If h is an empty matrix, the map structure can be defined 
% without requiring a map axes.
%
% mstruct = AVHRRPRJ(mstruct,region) reuses the map structure provided.
%
% Information on the file format and projection characteristics of the
% global land 1-km AVHRR data set may be found on the internet at
% http://edcwww.cr.usgs.gov/landdaac/1KM/goodesarticle.html
%
% See also AVHRR


% eastern half of greenland data actually in a north american gore, inconsistent 
% with Steinwand specs. To fix this, need to redefine the north american gore in to 
% the separate sinusoid and mollweid parts, and extend the northern section furthur 
% east. Also have to redefine the european gores.


if nargin ~= 2;
	error(eid,'%s','Incorrect number of arguments')
end

if length(region) ~= 1 || ~ismember(region,1:6)
	error(eid,'%s','region must be an integer from 1 to 6')
end

% if ishandle(h)
% 	mstruct = gcm(h)
% else
	
if isempty(h) || ishandle(h)
	mstruct = defaultm('goode');
	mstruct = defaultm(goode(mstruct));
else
	mstruct = h; 
end

units = mstruct.angleunits;

latlim = [ ...
	0 90		% region 1 and 3
	0 90		% region 2 and 4
	-90 0		% region 5 and 9
	-90 0		% region 6 and 10
	-90 0		% region 7 and 11
	-90 0		% region 8 and 12
	];
latlim = angledim(latlim,'deg',units);
	
lonlim = [ ...
	-180  -40		% region 1 and 3
	 -40  180		% region 2 and 4
	-180 -100		% region 5 and 9
	-100  -20		% region 6 and 10
	 -20   80		% region 7 and 11
	  80  180		% region 8 and 12
	];
lonlim = angledim(lonlim,'deg',units);

centralMeridian = [
	-100		% region 1 and 3
	  30		% region 2 and 4
	-160		% region 5 and 9
	 -60		% region 6 and 10
	  20		% region 7 and 11
	 140		% region 8 and 12
	];
centralMeridian = angledim(centralMeridian,'deg',units);
	

mstruct.mapprojection	= 'goode';
mstruct.origin 			= [0 centralMeridian(region) 0];
mstruct.maplatlimit 	= latlim(region,:);
mstruct.maplonlimit 	= lonlim(region,:);
mstruct.flatlimit 		= [];
mstruct.flonlimit 		= [];
mstruct.geoid 			= [6370997 0] ; % meters
mstruct.falseeasting 	= 6370997*angledim(centralMeridian(region),units,'radians');

eval(['mstruct = defaultm(' mstruct.mapprojection '(mstruct));'])

if ishandle(h);
	if ~ismap(h); axesm goode; end 
	setm(h,...
		'MapProjection', mstruct.mapprojection,...
		'Origin',mstruct.origin,...
		'MapLatLimit',mstruct.maplatlimit,...
		'MapLonLimit',mstruct.maplonlimit,...
		'FLatLimit',mstruct.flatlimit,...
		'FLonLimit',mstruct.flonlimit,...
		'Geoid',mstruct.geoid,...
		'FalseEasting',mstruct.falseeasting...
	); 
end

if nargout >=1;
	out = mstruct;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [latlim,lonlim] = limitmV(lat,long)

% lat = npi2pi(lat);
% long = npi2pi(long);

indx = find(~isnan(lat) & ~isnan(long)) ;

latlim = [min(lat(indx)) max(lat(indx)) ];
lonlim = [min(long(indx)) max(long(indx)) ];

 

