function [map,maplegend] = etopo5(varargin)
%ETOPO5 Read global 5-Min digital terrain data.
%
% [MAP, MAPLEGEND] = ETOPO5(SCALEFACTOR) reads the data for the entire
% world, downsampling the data by the scale factor. The result is returned
% as a regular matrix map and associated map legend. Scalefactor is an
% integer, which when equal to 1 gives the data at its full resolution
% (1080 by 4320 values).  When scalefactor is  an integer n larger than
% one, every nth point is returned.  The  scalefactor must divide evenly
% into the number of rows and columns  in the data file. Data values are in
% whole meters, representing  the elevation of the center of each cell.
%
% [MAP, MAPLEGEND] = ETOPO5(SCALEFACTOR, LATLIM, LONLIM) reads the data for
% the part of the world within the latitude and longitude limits. The
% limits must be two-element vectors in units of degrees.
%
% ETOPO5 reads either the binary data file new_etopo5.bil available over
% the internet at 
%    <http://www.geo.cornell.edu/geology/seber/datasets/>, 
%
% or a pair of text files (etopo5.southern.bat and etopo5.northern.bat)
% available from The MathWorks at
%    <ftp://ftp.mathworks.com/pub/mathworks/toolbox/map/extMapData/>.
%
% The binary file is prefered. It is smaller and faster to read.
%
% See also: GTOPO30, TBASE, USGSDEM.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:20:56 $
%  Written by:  A. Kim


%  Ascii data files (N & S hemispheres)
%  Data arranged in W-E columns (0 to 360) by N-S rows (90 to -90).
%  Elevation in meters


filesfound = checkforfiles;
if filesfound == 0; 
   error('Couldn''t find file new_etopo5.bil or both etopo5.northern.bat and etopo5.southern.bat')
end

switch filesfound
case 1 
   [map,maplegend] = newetopo5(varargin{:});
case 2
   [map,maplegend] = oldetopo5(varargin{:});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function filesfound = checkforfiles

if exist('new_etopo5.bil','file');
   filesfound = 1;
elseif (exist('etopo5.northern.bat','file') & ...
        exist('etopo5.southern.bat','file'))
   filesfound = 2;
else 
   filesfound = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [map,maplegend] = oldetopo5(scalefactor,latlim,lonlim)
%OLDETOPO5 read the ascii 2 file version of etopo5
if nargin==1
	subset = 0;
elseif nargin==3
	subset = 1;
else
	error('Incorrect number of arguments')
end

sf = scalefactor;
dcell = 5/60;			% 5 minute grid
shift = 0;


if ~subset

%  Check to see if scalefactor fits matrix dimensions
	if mod(1080,sf)~=0 | mod(4320,sf)~=0
		error('Scalefactor must divide evenly into 1080 rows and 4320 columns')
	end

else

%  Check to see if data needs to be shifted (-pi to pi)
	if lonlim(1)<0
		shift = 1;
	end

%  Check lat and lon limits
	errnote = 0;
	if latlim(1)>latlim(2)
		warning('1st element of latlim must be greater than 2nd')
		errnote = 1;
	end
	if lonlim(1)>lonlim(2)
		warning('1st element of lonlim must be greater than 2nd')
		errnote = 1;
	end
	if latlim(1)<-90 | latlim(2)>90
		warning('latlim must be between -90 and 90')
		errnote = 1;
	end
	if ~shift & (lonlim(1)<0 | lonlim(2)>360)
		warning('lonlim must be between 0 and 360')
		errnote = 1;
	end
	if shift & (lonlim(1)<-180 | lonlim(2)>180)
		warning('lonlim must be between -180 and 180')
		errnote = 1;
	end
	if errnote
		error('Check limits')
	end

%  Convert lat and lon limits to row and col limits
	if latlim(2)==90
		rowlim(1) = 1;
	else
		rowlim(1) = floor(-12*(latlim(2)-90)) + 1;
	end
	if latlim(1)==-90
		rowlim(2) = 2160;
	else
		rowlim(2) = ceil(-12*(latlim(1)-90));
	end
	if ~shift
		lon0 = 0;
	else
		lon0 = -180;
	end
	if (~shift & lonlim(1)==0) | (shift & lonlim(1)==-180)
		collim(1) = 1;
	else
		collim(1) = floor(12*(lonlim(1)-lon0)) + 1;
	end
	if (~shift & lonlim(2)==360) | (shift & lonlim(2)==180)
		collim(2) = 4320;
	else
		collim(2) = ceil(12*(lonlim(2)-lon0));
	end

end

%  Calculate row and col indices
srow = [0; (25923:25924:27971995)'];	% start row position indicators
if ~subset
	rowindx1 = 1:sf:1080;
	rowindx2 = 1:sf:1080;
	colindx = 1:sf:4320;
	maptop = 90;
	mapleft = 0;
else
	if rowlim(1)<=1080 & rowlim(2)<=1080		% submap in N hemisphere
		rowindx1 = rowlim(1):sf:rowlim(2);
		rowindx2 = [];
	elseif rowlim(1)>=1080 & rowlim(2)>=1080	% submap in S hemisphere
		rowindx1 = [];
		rowindx2 = rowlim(1)-1080:sf:rowlim(2)-1080;;
	elseif rowlim(1)<=1080 & rowlim(2)>=1080	% submap in both hemispheres
		rowindx1 = rowlim(1):sf:1080;
		row1 = sf - (1080-rowindx1(length(rowindx1)));
		rowindx2 = row1:sf:rowlim(2)-1080;
	end
	colindx = collim(1):sf:collim(2);
	maptop = 90 - dcell*(rowlim(1)-1);
	mapleft = dcell*(collim(1)-1);
	if shift
		mapleft = dcell*(collim(1)-1) - 180;
	end
end

%  Read ETOPO5 ascii image files
%  Read from bottom to top of map (first row of matrix is bottom of map)

%  Northern hemisphere file
fid = fopen('etopo5.northern.bat','r');
if fid==-1
	error('File ''etopo5.northern.bat''  not found')
end
if ~isempty(rowindx1)
	y = srow(rowindx1);
	new_m = length(y);
	for m=new_m:-1:1
		if mod(m,10)==0
			disp(['N' num2str(m)])
		end
		fseek(fid,y(m),'bof');
		temp = fscanf(fid,'%d',[1 4320]);
        % pad data if necessary
        if size(temp,2) ~= 4320
            numberMissing = 4320-size(temp,2);
            temp = [temp temp(1:numberMissing)];
        end
		if shift
			temp = [temp(2161:4320) temp(1:2160)];
		end
		mapN(new_m+1-m,:) = temp(colindx);
	end
	fclose(fid);
else
	mapN = [];
end

%  Southern hemisphere file
fid = fopen('etopo5.southern.bat','r');
if fid==-1
	error('File ''etopo5.southern.bat''  not found')
end
if ~isempty(rowindx2)
	y = srow(rowindx2);
	new_m = length(y);
	for m=new_m:-1:1
		if mod(m,10)==0
			disp(['S' num2str(m)])
		end
		fseek(fid,y(m),'bof');
		temp = fscanf(fid,'%d',[1 4320]);
        if size(temp,2) ~= 4320
            numberMissing = 4320-size(temp,2);
            temp = [temp temp(1:numberMissing)];
        end
		if shift
			temp = [temp(2161:4320) temp(1:2160)];
		end
		mapS(new_m+1-m,:) = temp(colindx);
	end
	fclose(fid);
else
	mapS = [];
end

map = [mapS; mapN];
cellsize = 1/(sf*dcell);
maplegend = [cellsize maptop mapleft];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [map,maplegend] = newetopo5(scalefactor,latlim,lonlim)


filename = 'new_etopo5.bil';

if nargin < 1; scalefactor = 10; end
if nargin < 2; latlim = [-90 90]; end
if nargin < 3; lonlim = [-180 180]; end

latlim = latlim(:)';
lonlim = lonlim(:)';

lonlim = npi2pi(lonlim);

% check input arguments

if length(scalefactor) > 1; 		error('Scalefactor must be a scalar'); end
if ~isequal([1 2],size(latlim));	error('latlim must be a two element vector in units of degrees'); end 
if ~isequal([1 2],size(lonlim)); 	error('lonlim must be a two element vector in units of degrees'); end 


% Hardwired information about the file format
ncols = 4320;
nrows = 2160;
lato = 90;
lono = -180;
cellsize = dms2deg(0,5,0);
NODATA_value = -32768;

% other information about the file

precision = 'int16';
machineformat = 'ieee-be';

dlat = -cellsize;
dlon = cellsize;

% convert lat and lonlim to column and row indices

[clim,rlim] = yx2rc(lonlim(:),latlim(:),lono,lato,dlon,dlat);

% ensure matrix coordinates are within limits

rlim = [max([1,min(rlim)]) min([max(rlim),nrows])];
rlim = sort(flipud(rlim(:))');

readrows = rlim(1):scalefactor:rlim(2);
readcols = clim(1):scalefactor:clim(2);

readcols = mod(readcols,ncols); readcols(readcols == 0) = ncols;

% ensure that we don't try to read beyond data limits 
% if scalefactor = 1, we try to read an additional column
if size(readcols,2)>ncols; readcols = readcols(1:ncols); end

% extract the map matrix
map = readmtx(filename,nrows,ncols,precision,readrows,readcols,machineformat);
map = flipud(map);
map(map==NODATA_value) = NaN;

% Construct the map legend. 

[readlat,readlon] = rc2yx(readrows,readcols,lato,lono,dlat,dlon);
maplegend = [abs(1/(dlat*scalefactor)) max(readlat)+dlat/2 min(readlon)-dlon];
