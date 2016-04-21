function hndl = grid2image(varargin)
%GRID2IMAGE Display a regular data grid as an image.
%
%  GRID2IMAGE(GRID,R) displays a regular data grid as an image.  GRID can
%  be M-by-N or M-by-N-by-3, and can contain double, uint8, or uint16 data.
%  The grid is georeferenced to latitude-longitude by R, a 1-by-3
%  referencing vector defined as [cells/angleunit north-latitude
%  west-longitude] or a 3-by-2 referencing matrix, defining a 2-dimensional
%  affine transformation from pixel coordinates to latitude-longitude.
%  The image is display in unprojected form, with longitude as X and
%  latitude as Y, producing considerable distortion away from the Equator.
%
%  GRID2IMAGE(GRID,R,'PropertyName',PropertyValue,...) applies the specified
%  image properties to the display.
%
%  h = GRID2IMAGE(...) returns the handle of the image object displayed.
%
%  See also IMAGE, MAPSHOW, MAPVIEW, PIX2LATLON.

%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.1.6.1 $  $Date: 2003/12/13 02:52:49 $

% Verify the input count
checknargin(2,inf,nargin,mfilename);

% Get the inputs
[grid,refvec,ax,xlbl,ylbl,props] = parseInputs(varargin{:});

% Compute the graticule
[lat,lon] = imgrat(grid,refvec);

% Display the map
h = image(lon,lat,grid,'CDataMapping','scaled','Parent',ax);

% Set the necessary properties of the axes
set(ax,'Ydir','Normal');

% Set properties if necessary
if ~isempty(props)
  set(h,props{:,1},props{:,2});
end

% Set labels if necessary
if ~isempty(xlbl)
  xlabel(xlbl);
end
if ~isempty(ylbl)
  ylabel(ylbl);
end

% Return the handle
if nargout == 1
  hndl = h;
end


%************************************************************************
function [grid,refvec,parent,xlabel,ylabel,props] = parseInputs(varargin)
checkinput(varargin{1},'numeric',{'real','nonempty'},'GRID2IMAGE','GRID',1);
grid = varargin{1};

props = [];
xlabel = '';
ylabel = '';
refvec = varargin{2};
if ~isequal(size(refvec),[1 3]) % GRID2IMAGE(GRID,R)
  % Convert to a referencing vector
  mapgate('checkrefmat',refvec, mfilename, 'R', 2);
  refvec = refmat2vec(refvec,size(grid));
end         
mapgate('checkrefvec',refvec, mfilename, 'R', 2);
xlabel = 'Longitude';
ylabel = 'Latitdue';

varargin(1:2) = [];

if nargin == 2
  parent = newplot;
end

if nargin > 2
  if rem(length(varargin),2)
    msg=sprintf('%s','The property/value inputs must always occur as pairs.');
    eid = sprintf('%s:%s:invalidPropPairs', getcomp, mfilename);
    error(eid, '%s', msg)
  end
  params = varargin(1:2:end);
  values = varargin(2:2:end);

  idx = strmatch('parent',lower(params));
  if isempty(idx)
    parent = gca;
  else
    parent = values{idx};
    params(idx) = [];
    values(idx) = [];
  end
  if ~isempty(params) && ~isempty(values)
    props = {params,values};
  end
end

if ismap(parent)
  msg=sprintf('%s','Image displays do not go in map axes.');
  eid = sprintf('%s:%s:invalidAxes', getcomp, mfilename);
  error(eid, '%s', msg)
end

if ndims(grid) > 3  
  eid = sprintf('%s:%s:invalidCData', getcomp, mfilename);
  msg = 'Indexed CData must be size M-by-N; TrueColor CData must be size M-by-N-by-3.';
  error(eid, msg);
end


%************************************************************************
function [lat,lon] = imgrat(map,refvec)

%  IMGRAT constructs a graticule for a image map object. These graticule
%  points correspond to the centers of each cell to be displayed using the
%  grid2image command.  The inputs map and refvec describe a regular matrix
%  map.   The outputs are vectors, where lat corresponds to the rows of map
%  and lon corresponds to the columns of map.

%  Get the limits of the map
[latlim,lonlim] = limitm(map(:,:,1),refvec);

%  Compute the latitude and longitude of the row/col data
%  Assume that each point is in the center of the specified
%  cell (hence the use of delta/2 below).  The center of the
%  cell is what the grid2image (image) command expects.
rows = 1:size(map,1);    
cols = 1:size(map,2);

delta = 1/refvec(1);
lat   = min(latlim) + (rows-1)*delta + delta/2;
lon   = min(lonlim) + (cols-1)*delta + delta/2;

