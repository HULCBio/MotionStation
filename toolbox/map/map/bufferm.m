function [latb,lonb] = bufferm(lat,lon,dist,direction,npts,outputformat)
%BUFFERM Compute buffer zones for vector data.
% 
%   [LATB, LONB] = BUFFERM(LAT, LON, DIST, DIRECTION) computes the buffer
%   zone around a polygon. A buffer zone for a closed polygon is defined as
%   the locus of points that are a certain distance in or out of the
%   polygon. A buffer zone for an open polygon is the locus of points a
%   certain distance out from the polygon. The polygon is specified as
%   vectors of latitude, LAT, and longitude, LON, in units of degrees.
%   DISTANCE is a scalar specified in degrees of arc along the surface.
%   DIRECTION is a string with values 'in' or 'out'. LATB and LONB are
%   returned as NaN-clipped vectors in units of degrees.
%
%   [LATB, LONB] = BUFFERM(LAT, LON, DIST, DIRECTION, NPTS) controls the
%   number of points used to construct circles about the vertices of the
%   polygon. A larger number of points produces smoother buffers, but
%   requires more time. If NPTS is omitted, 13 points per circle are used.
%
%   [LATB, LONB] = BUFFERM(LAT, LON, DIST, DIRECTION, NPTS, OUTPUTFORMAT)
%   controls the format of the returned buffer zones. OUTPUTFORMAT 'vector'
%   returns NaN-clipped vectors. OUTPUTFORMAT 'cutvector' returns
%   NaN-clipped vectors with cuts connecting holes to the exterior of the
%   polygon. OUTPUTFORMAT 'cell' returns cell arrays in which each element
%   of the cell array is a separate polygon. Each polygon may consist of
%   an outer contour followed by holes separated with NaNs.
%
%   Example
%   -------
%   [lat,lon]=extractm(worldlo('POpatch'),'italy');
%   [lat,lon]=reducem(lat,lon);
%   
%   [latb,lonb] = bufferm(lat,lon,1.5,'out');
%   
%   worldmap('lo','italy','lineonly')
%   hp = patchesm(latb,lonb,'y');             
%   zdatam(hp,-2);
%   set(hp(2),'facecolor','w');               
%   zdatam(hp(2),1); % hole
%   hp2=geoshow(updategeostruct(worldlo('POpatch'),'italy')); 
%   zdatam(hp2,-1);
%
%   See also GEOSHOW, POLYBOOL, UPDATEGEOSTRUCT.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.5.4.2 $    $Date: 2003/12/13 02:50:10 $

checknargin(3,6,nargin,mfilename);

if nargin < 4
    direction = 'out';
end

if nargin < 5
    npts = 13;
end

if nargin < 6
    outputformat = 'vector';
end

% Check for valid output format before time consuming buffer operation
switch direction
case 'in'
	boolflag = 'subtract';
case 'out'
	boolflag = 'union';
otherwise
    eid = sprintf('%s:%s:uknownDirectionFlag',getcomp,mfilename);
    error(eid,'%s','Direction must be either ''in'' or ''out''.');
end

switch outputformat
case {'vector','cutvector','cell'}
otherwise
    eid = sprintf('%s:%s:uknownFormatFlag',getcomp,mfilename);
    error(eid,'%s','Unrecognized ouput format flag.')
end

if ~isnumeric(dist) || numel(dist) > 1
    eid = sprintf('%s:%s:nonscalarDist',getcomp,mfilename);
    error(eid,'%s','Distance must be a scalar.')
end

if ~isnumeric(npts) || numel(npts) > 1
    eid = sprintf('%s:%s:nonscalarNpts',getcomp,mfilename);
    error(eid,'%s','Number of points must be a scalar.')
end

% Check inputs
if iscell(lat)
    [eid,msg] = checkcellvector(lat,lon,getcomp,mfilename);
    error(eid,'%s',msg);
else
    checklatlon(lat,lon,mfilename,'LAT','LON',1,2);
end

%  Input dimension tests

if ~iscell(lat)
   %  Ensure lat and lon are column vectors
   lat = lat(:);
   lon = lon(:);   
end


% Split NaN-separated faces into separate elements of cell arrays
if ~iscell(lat)
   [latcells,loncells]=polysplit(lat,lon);
else
   [latcells,loncells]=deal(lat,lon);
end

% Check inputs
[eid,msg] = checkcellvector(latcells,loncells,getcomp,mfilename);
error(eid,'%s',msg);


% carry out buffer operation on each face
latcellsout = {};  loncellsout = {};
for i=1:length(latcells)
   [latout,lonout]=bufferm1(latcells{i},loncells{i},dist,npts,boolflag);
	latcellsout = [latcellsout; latout];
	loncellsout = [loncellsout; lonout];
end
latcells = latcellsout;  loncells = loncellsout;


% combine separate faces
if length(latcells) > 1
   [latcells1,loncells1]=deal(latcells,loncells);
   latcells(2:end)=[]; loncells(2:end)=[];
   for i=2:length(latcells1)
      [latcells,loncells]=polybool('union',latcells,loncells,latcells1(i),loncells1(i),'cell');
   end
end

% Convert result to requested output format

switch outputformat
case 'vector'
   [latb,lonb]=polyjoin(latcells,loncells);
case 'cutvector'
   [latb,lonb]=polycut(latcells,loncells);
case 'cell'
   latb=latcells;
   lonb=loncells;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [latb,lonb] = bufferm1(lat,lon,dist,ncpts,boolflag)
% BUFFERM1 handles one face at a time

% parameters
plotflag = 0;
statstr = 'drawnow';	% pause or drawnow

% columnize vectors
lat = lat(:);  lon = lon(:);

% interpolate to remove long runs between points
[lat,lon]=interpm(lat,lon,10,'gc');
nseg = length(lat) - 1;

% straight line segment of left and right side of buffer
az1 = azimuth(lat(1:end-1),lon(1:end-1),lat(2:end),lon(2:end));
az2 = azimuth(lat(2:end),lon(2:end),lat(1:end-1),lon(1:end-1))+180;
az=(npi2pi(az1)+npi2pi(az2))/2;
rng = dist*ones(size(az1));
[latbl1,lonbl1] = reckon(lat(1:end-1),lon(1:end-1),rng,az-90);
[latbr1,lonbr1] = reckon(lat(1:end-1),lon(1:end-1),rng,az+90);
[latbl2,lonbl2] = reckon(lat(2:end),lon(2:end),rng,az-90);
[latbr2,lonbr2] = reckon(lat(2:end),lon(2:end),rng,az+90);

% display plot
if plotflag
	axesm mercator
	hp = plotm(lat,lon,'r-*','zdata',ones(size(lat)));
	hcell = patchpolym({lat},{lon},'y');
	feval(statstr)
end

% initialize current polygon
if lat(1)~=lat(end) || lon(1)~=lon(end)  || length(lat) < 3	% open polygon
	[latcirc,loncirc] = scircle1(lat(1),lon(1),dist,[],[],[],ncpts);
	latb = {latcirc};  lonb = {loncirc};
else													% closed polygon
	latb = {lat};  lonb = {lon};
end

% loop for number of line segments
for n=1:nseg

% show counter
	if plotflag && strcmp(statstr,'pause'),  disp(n),  end

% circle around current point
	[latcirc,loncirc] = scircle1(lat(n),lon(n),dist,[],[],[],ncpts);
	if plotflag
		hc = plotm(latcirc,loncirc,'g','zdata',2*ones(size(latcirc)));
		feval(statstr)
	end
   
% rectangle from current point to next point
   latrect = [latbl1(n) latbr1(n) latbr2(n) latbl2(n) latbl1(n)]';
   lonrect = [lonbl1(n) lonbr1(n) lonbr2(n) lonbl2(n) lonbl1(n)]';
   if plotflag
      hr = plotm(latrect,lonrect,'g','zdata',2*ones(size(latrect)));
      feval(statstr)
   end
   
% find union of circle and rectangle
	[latcr,loncr] = spuni(latcirc,loncirc,latrect,lonrect);

% find union of current polygon with circle+rectangle
	[lonb,latb] = feval(['cp' boolflag(1:3)],lonb,latb,loncr,latcr);
	if plotflag
		delete(hr)
		for m=1:length(hcell),  delete(hcell{m}),  end
		hcell = patchpolym(latb,lonb,'y');
		feval(statstr)
	end

end

% do circle around last point for open polygons
if lat(1)~=lat(end) || lon(1)~=lon(end)  	% open polygon
   
% circle around last point
	[latcirc,loncirc] = scircle1(lat(end),lon(end),dist,[],[],[],ncpts);
	if plotflag
		hc = plotm(latcirc,loncirc,'g','zdata',2*ones(size(latcirc)));
		feval(statstr)
	end

% find union of current polygon with circle
	[lonb,latb] = feval(['cp' boolflag(1:3)],lonb,latb,{loncirc},{latcirc});
	if plotflag
		delete(hc)
		for m=1:length(hcell),  delete(hcell{m}),  end
		hcell = patchpolym(latb,lonb,'y');
		feval(statstr)
	end
end

% display result
if plotflag
	for m=1:length(hcell), delete(hcell{m}), end
	patchpolym(latb,lonb,'g');
end

%-----------------------------------------------------------------

function [eid,msg] = checkcellvector(lat,lon,component,function_name)

eid = [];
msg = [];

if ~isa(lat,'cell') || ~isa(lon,'cell')
   eid = sprintf('%s:%s:expectedCellArrays',component,function_name);
   msg = 'Expected latitude and longitude to be cell arrays.';
   return
end

if ~isequal(size(lat),size(lon))
   eid = sprintf('%s:%s:inconsistentSizes',component,function_name);
   msg = 'Inconsistent dimensions on latitude and longitude input.';
   return
end

for k = 1:numel(lat)
   if ~isequal(size(lat{k}),size(lon{k}))
      eid = sprintf('%s:%s:inconsistentSizesInCell',component,function_name);
      msg = 'Inconsistent latitude and longitude dimensions within a cell.';
      return
   end
end
