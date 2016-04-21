function [latgrat,longrat,mat] = avhrrlambert(region,filename,scalefactor, ...
                                              latlim,lonlim,gsize,precision)
%AVHRRLAMBERT Read AVHRR data stored in the LAMBERT Projection.
% 
%  [LATGRAT, LONGRAT, MAT] = AVHRRLAMBERT(REGION) reads data from an 
%  Advanced Very High Resolution Radiometer (AVHRR) dataset with a nominal 
%  resolution of 1 km that is stored in the Lambert projection.  Data of
%  this  type includes the Global Land Cover Characteristics (GLCC) The
%  region  specifies the coverage of the file.  Valid regions are 'g' or
%  'global',  'af' or 'africa', 'ap' or 'australia/pacific', 'e' or
%  'europe', 'a' or  'asia', 'na' or 'north america', 'sa' or 'south
%  america', 'af' or 'africa'.  
%   Data is returned as a general matrix map with the graticule matrices in
%   units of degrees.
%  
%  [...] = AVHRRLAMBERT(REGION, FILENAME) uses the provided filename.
%  
%  [...] = AVHRRLAMBERT(REGION, FILENAME, SCALEFACTOR) uses the integer
%  scalefactor  to downsample the data.  A scalefactor of 1 returns every
%  point.  A  scalefactor of 10 returns every 10th point.  If omitted, 100
%  is assumed.
%  
%  [...] = AVHRRLAMBERT(REGION, FILENAME, SCALEFACTOR, LATLIM, LONLIM)
%  returns data for  the specified region.  The returned data will extend
%  somewhat beyond the  requested area.  If omitted, the entire area
%  covered by the data file is  returned. The limits are two element
%  vectors in units of degrees, with  latlim in the range [-90 90] and
%  lonlim in the range [-180 180].
% 
%  [...] = AVHRRLAMBERT(REGION, FILENAME, SCALEFACTOR, LATLIM, LONLIM,
%  GSIZE) controls  the size of the graticule matrices.  Gsize is a
%  two-element vector  containing the number of rows and columns desired.
%  If omitted, a  graticule the size of the map is returned.
% 
%  [...] = AVHRRLAMBERT(REGION, FILENAME, SCALEFACTOR, LATLIM, LONLIM,
%  GSIZE, PRECISION)  reads a dataset with the integer precision specified.
%  If omitted, 'uint8'  is assumed.  'uint16' is appropriate for some
%  files.  Check the data's  README file for specification of the file
%  format and contents.
% 
%  The AVHRR Global Land Cover Characteristics (GLCC) dataset is described in 
%    http://edcwww.cr.usgs.gov/landdaac/glcc/glcc_na.html
%  
%  Data may be obtained from
%    <ftp://edcftp.cr.usgs.gov/pub/data/glcc/>
% 
%  This function reads the binary files as-is. You should not use byte
%  swapping software on these files.
% 
%  See also AVHRRGOODE.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by: W. Stumpf
%  $Revision: 1.1.6.1 $    $Date: 2003/08/01 18:20:47 $

checknargin(1,7,nargin,mfilename);
checkinput(region,{'char'},{},mfilename,'REGION',1);

if nargin < 2;	filename = [];		end
if nargin < 3;	scalefactor=100; 	end
if nargin < 4;	latlim = [];		end
if nargin < 5;	lonlim = [];		end
if nargin < 6;	gsize = [];			end
if nargin < 7;	precision = 'int8';	end  % the DEM image is 'integer*2'
	
% ensure row vectors
latlim = latlim(:)';
lonlim = lonlim(:)';
	
yperrow = -1000; 		% Meters
xpercol =  1000; 		% Meters
geoid = [6370997 0];	% Meters

switch lower(region)
case {'af','africa'}
	nrows = 9276;
	ncols = 8350;
	x1 = -4458000-xpercol/2;% Meters
	y1 =  4480000-yperrow/2;% Meters
	origin = [5 20 0];	% Degrees
case {'ap','australia/pacific'}
	nrows = 8000;
	ncols = 9300;
	x1 = -5000000-xpercol/2;% Meters
	y1 =  4054109-yperrow/2;% Meters
	origin = [-15 135 0];	% Degrees
case {'sa','south america'}
	nrows = 8000;
	ncols = 6000;
	x1 = -3000000-xpercol/2;% Meters
	y1 =  3100000-yperrow/2;% Meters
	origin = [-15 -60 0];	% Degrees
case {'e','europe'}
	nrows = 13000;
	ncols = 13000;
	x1 = -3000000-xpercol/2;% Meters
	y1 =  8000000-yperrow/2;% Meters
	origin = [55 20 0];	% Degrees
case {'a','asia'}
	nrows = 12000;
	ncols = 13000;
	x1 = -8000000-xpercol/2;% Meters
	y1 =  6500000-yperrow/2;% Meters
	origin = [45 100 0];	% Degrees
case {'na','north america'}
	nrows = 8996;
	ncols = 9223;
	x1 = -4487000-xpercol/2;% Meters
	y1 =  4480000-yperrow/2;% Meters
	origin = [50 -100 0];	% Degrees
otherwise
   eid = sprintf('%s:%s:invalidRegionString', getcomp, mfilename);
   error(eid,'%s\n%s\n%s\n%s\n%s\n%s\n%s','Valid region strings are ', ...
         '   ''a''  or ''asia'', ', ...
         '   ''af'' or ''africa'', ', ... 
         '   ''ap'' or ''australia/pacific'', ', ...
         '   ''e'' or  ''europe'', ', ...
         '   ''na'' or ''north america'', ', ...
         '   ''sa'' or ''south america''. ');

end
		
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
checkinput(precision, {'char'}, {}, mfilename,'PRECISION',7);

	
% define a map structure for the lambert data
mstruct = defaultm('eqaazim');
mstruct.origin = origin;
mstruct.geoid = geoid;
mstruct = defaultm(eqaazim(mstruct));

if isempty(latlim) || isempty(lonlim) 	% read the whole matrix
	rlim = [1 nrows];
	clim = [1 ncols];
else									% Map requested region into the matrix 
	
% ensure that latlim and lonlim are within range
	latlim = latlim(:)';
	lonlim = lonlim(:)';
	lonlim = zero22pi(lonlim);
	
% Construct a frame around desired region
	[latfrm,lonfrm] = framemll(latlim,lonlim,50);

% Transform the frame to projected coordinates and then to row and column indices
	[xfrm,yfrm] = mfwdtran(mstruct,latfrm,lonfrm);
	[rfrm,cfrm] = yx2rc(yfrm,xfrm,y1,x1,yperrow,xpercol);

% Find the extent of the desired region in matrix indices. This is
% necessary because the desired region is not rectangular in the 
% projected data. The returned data will extend beyond the requested
% region
	rlim = [max([1,min(rfrm)]) min([max(rfrm),nrows])];
	clim = [max([1,min(cfrm)]) min([max(cfrm),ncols])];
	
	if diff(rlim) <= 0 || diff(clim) <= 0 ; 
      eid = sprintf('%s:%s:invalidGeographicLimits', getcomp, mfilename);
		msg=sprintf('%s\n%s', ...
          'Geographic limits fall outside of this file''s coverage. ', ...
          'Incorrect limits, region or filename?'); 
      error(eid, '%s',msg);
	end
	
end

% extract the map matrix
readrows = rlim(1):scalefactor:rlim(2);
readcols = clim(1):scalefactor:clim(2);
mat = readmtx(filename,nrows,ncols,precision,readrows,readcols,'ieee-be');

% construct a graticule of row and column indices
if isempty(gsize) 											% size(grat) = size(mat)
	[rIndGrat,cIndGrat] = meshgrat(readrows,readcols);
else  													% texture map the data to a smaller graticule
	[rIndGrat,cIndGrat] = meshgrat([min(readrows) max(readrows)],[min(readcols) max(readcols)],gsize);
end

% map row and column graticule to x and y values
[ygrat,xgrat] = rc2yx(rIndGrat,cIndGrat,y1,x1,yperrow,xpercol);

ygrat = ygrat-yperrow/2;
xgrat = xgrat-xpercol/2;

% map x and y graticule to lat and long
[latgrat,longrat] = minvtran(mstruct,xgrat,ygrat);



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


