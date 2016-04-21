function [latgrat,longrat,mat] = satbath(varargin)
%SATBATH Read global 2-minute (4 km) topography from satellite bathymetry.
%   
%  [latgrat,longrat,map] = SATBATH reads the global topography file for the
%  entire world, returning every 50th point.  The result is returned as a 
%  general matrix map.
% 
%  [latgrat,longrat,map] = SATBATH(scalefactor) returns the data for the 
%  entire world, subsampled by the integer scalefactor.  A scalefactor of
%  10  returns every 10th point.  The matrix at full resolution has 6336 by
%  10800  points.
% 
%  [latgrat,longrat,map] = SATBATH(scalefactor,latlim,lonlim) returns data 
%  for the specified region.  The returned data will extend slightly beyond
%  the requested area.  If omitted, the entire area covered by the data
%  file  is returned.  The limits are ascending two element vectors in
%  units of  degrees.
% 
%  [latgrat,longrat,map] = SATBATH(scalefactor,latlim,lonlim,gsize)
%  controls  the size of the graticule matrices.  Gsize is a two-element
%  vector  containing the number of rows and columns desired.  If omitted,
%  a  graticule the size of the map is returned.
%
%  The data is available over the Internet via anonymous FTP from
%  <ftp://topex.ucsd.edu/pub/global_topo_2min/>.
%
%  Download the latest version of file topo_x.2.img, where x is the version
%  number, and rename it 'topo_6.w.img' for compatibility with the satbath
%  function. This function reads the binary files as-is. You should not use
%  byte swapping software on these files.
% 
%  Some documentation is also available from 
%  <http://topex.ucsd.edu/marine_topo/mar_topo.html> and 
%  <http://www.ngdc.noaa.gov/mgg/announcements/announce_predict.html>.
% 
%  See also TBASE, GTOPO30, EGM96GEOID.

% [nrows,ncols] = satbath('size',scalefactor,latlim,lonlim) returns the size of the
% matrix without extracting the data.

% Copyright 1996-2003 The MathWorks, Inc.
% $Revision: 1.1.6.1 $  $Date: 2003/08/01 18:23:53 $

% calling form to compute size of matrix without extracting data
request = 'data';
nargi= nargin;
if nargin >= 1 & isstr(varargin{1})
   request = varargin{1};
   varargin(1) = [];
   nargi = nargin-1;
end

switch request
case{'data','size'}
otherwise
   error('Valid requests are ''data'' and ''size''')
end

if nargi < 1;	scalefactor = 50;  else; scalefactor = varargin{1};    end
if nargi < 2; 	latlim = [-72 72]; else; latlim = varargin{2};         end % degrees
if nargi < 3; 	lonlim = [0 360];  else; lonlim = varargin{3};		     end % degrees
if nargi < 4;	gsize = [];        else; gsize = varargin{4};				  end

% get lonlim into the correct range

latlim = latlim(:)';
lonlim = lonlim(:)';

if ~isequal(lonlim,[0 360])
	lonlim = zero22pi(lonlim);
	if lonlim(2) < lonlim(1);
		lonlim(2) = lonlim(2) + 360;
	end
end


% the size of the matrix

nrows = 6336;
ncols = 10800;

% map lat and long limits to projected coordinates

[rlim,clim] = ll2rc(latlim,lonlim);

% trim latitudes to the limits of the map

rlim = [max([1,min(rlim)]) min([max(rlim),nrows])];


% extract the map matrix

readrows = rlim(1):scalefactor:rlim(2);
readcols = clim(1):scalefactor:clim(2);

% Bail if all we wanted was the size
switch request
case 'size'
   [latgrat,longrat] = deal(length(readrows),length(readcols));
   return
end


% construct a graticule of row and column indices

if nargi < 4 											% size(grat) = size(mat)
	[rIndGrat,cIndGrat] = meshgrat(readrows,readcols);
else  													% texture map the data to a smaller graticule
	[rIndGrat,cIndGrat] = meshgrat([min(readrows) max(readrows)],[min(readcols) max(readcols)],gsize);
end

% wrap data that extends beyond the right edge of the map

readcols = mod(readcols,ncols); 
readcols(readcols == 0) = ncols;

% Check for requests straddling the edge of the data

indx = find(diff(readcols) < 1);

% read the data
if isempty(indx) % no straddle

	mat = readmtx('topo_6.2.img',nrows,ncols,'integer*2',readrows,readcols,'ieee-be');

else
    
	mat1 = readmtx('topo_6.2.img',nrows,ncols,'integer*2',readrows,readcols(1:indx(1)),'ieee-be');
	mat2 = readmtx('topo_6.2.img',nrows,ncols,'integer*2',readrows,readcols(indx(1)+1:end),'ieee-be');
	mat = [mat1 mat2];
    
end

% map row and column graticule to lat and long

[latgrat,longrat] = rc2ll(rIndGrat,cIndGrat);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [i,j] = ll2rc(lat,lon)
%LL2RC converts lat-long to row-column for the global satellite bathymetry

% a translated excerpt of Davis Sandwell's copyrighted code in
% ftp://topex.ucsd.edu/pub/global_topo_2min/src_img_sun/img2xyt.f


d2r =.0174533;

ncols=10800;
nrows=6336;
lat1=-72.006;
lon1=0.;
dlon=2/60.;

arg1=log(tan(d2r*(45.+lat1/2)));
arg2=log(tan(d2r*(45.+lat/2)));
i=ceil(nrows+1-(arg2-arg1)/(dlon*d2r));
j=floor((lon-lon1)/dlon+1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [lat,lon] = rc2ll(i,j)
%RC2ll converts lat-long to row-column for the global satellite bathymetry

% a translated excerpt of Davis Sandwell's copyrighted code in
% ftp://topex.ucsd.edu/pub/global_topo_2min/src_img_sun/img2xyt.f


d2r =.0174533;
ncols=10800;
nrows=6336;
lat1=-72.006;
lon1=0.;
dlon=2/60.;

arg1=d2r*dlon*(nrows-i+.5);
arg2=log(tan(d2r*(45.+lat1/2.)));
term=exp(arg1+arg2);
lat=2.*atan(term)/d2r-90.;

lon=lon1+dlon*(j-.5);
