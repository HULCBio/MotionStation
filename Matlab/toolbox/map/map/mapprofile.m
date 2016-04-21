function [zout,rng,lat,lon] = mapprofile(varargin)

%MAPPROFILE values between waypoints on a regular matrix map
%
% MAPPROFILE plots a profile of values between waypoints on 
% a displayed regular matrix map. MAPPROFILE uses the current
% object if it is a regular matrix map, or the first regular 
% matrix map found on the current axes. The map's zdata is 
% used for the profile. The color data is used in the absence 
% of data in z. The result is displayed in a new figure.
%
% [z,rng,lat,lon] = MAPPROFILE returns the values of the profile
% without displaying them. The output z contains interpolated 
% values from map along great circles between the waypoints. 
% Rng is a vector of associated distances from the first waypoint 
% in units of degrees of arc along the surface. Lat and lon are 
% the corresponding latitudes and longitudes. 
%
% [z,rng,lat,lon] = MAPPROFILE(map,maplegend,lat,lon) uses the
% provided regular matrix map and waypoint vectors. No displayed 
% map is required. Sets of waypoints may be separated by NaNs 
% into line sequences. The output ranges are measured from the first 
% waypoint within a sequence.
%
% [z,rng,lat,lon] = MAPPROFILE(map,maplegend,lat,lon,rngunits)
% specifies the units of the output ranges along the profile. 
% Valid range units inputs are any distance string recognized by
% DISTDIM. Surface distances are computed using the default 
% radius of the earth. If omitted, 'degrees' are assumed.
%
% [z,rng,lat,lon] = MAPPROFILE(map,maplegend,lat,lon,ellipsoid) 
% uses the provided ellipsoid definition in computing the range
% along the profile. The ellipsoid vector is of the form
% [semimajor axes, eccentricity].  The output range is reported in
% the same distance units as the semimajor axes of the ellipsoid
% vector. If omitted, the range vector is for a sphere.
%
% [z,rng,lat,lon] = MAPPROFILE(map,maplegend,lat,lon,rngunits,...
% 'trackmethod','interpmethod') and
% [z,rng,lat,lon] = MAPPROFILE(map,maplegend,lat,lon,ellipsoid,...
% 'trackmethod','interpmethod') control the interpolation methods
% used. Valid trackmethods are 'gc' for great circle tracks 
% between waypoints, and 'rh' for rhumb lines. Valid interpmethods
% for interpolation within the matrix are 'bilinear' for linear 
% interpolation, 'bicubic' for cubic interpolation, and 'nearest' 
% for nearest neighbor interpolation. If omitted, 'gc' and 'bilinear'
% are assumed.
%
% See also LTLN2VAL, LOS2

%  Copyright 1996-2003 The MathWorks, Inc.


% Defaults for optional arguments
source = 'Map';
rngunits = 'deg'; 
trackmethod = 'gc';
interpmethod = 'bilinear';

% other inputs

if length(varargin) > 7; error('Incorrect number of input arguments'); end


if length(varargin) == 0 % get from figure
   
   [map,maplegend,source] = getrmm;
   [lat,lon] = inputm;
   
elseif length(varargin) == 4
   [map,maplegend,lat,lon] = deal(varargin{1:4});
elseif length(varargin) == 5
   [map,maplegend,lat,lon,rngunits] = deal(varargin{1:5});
elseif length(varargin) == 6
   [map,maplegend,lat,lon,rngunits,trackmethod] = deal(varargin{1:6});
elseif length(varargin) == 7
   [map,maplegend,lat,lon,rngunits,trackmethod,interpmethod] = deal(varargin{1:7});
else
   error('Incorrect number of input arguments')
end

% check if geoid was provided
if isnumeric(rngunits)
   geoid = rngunits;
   [geoid,msg] = geoidtst(geoid);
   if ~isempty(msg); error(msg); end
end

% check inputs

msg = inputcheck('vector',lat,lon);    if ~isempty(msg); error(msg); end
msg = inputcheck('rmm',map,maplegend); if ~isempty(msg); error(msg); end

% check trackmethod
switch trackmethod
case {'gc','rh'}
   % OK
otherwise
   error('Recognized method strings are ''gc'' and ''rh''') 
end

%  Try to ensure vectors don't begin or end with NaNs
if isnan(lat(1)) | isnan(lon(1))
	lat = lat(2:end);
	lon = lon(2:end);
end
if isnan(lat(end)) | isnan(lon(end))
	lat = lat(1:end-1);
	lon = lon(1:end-1);
end

% interpolate points to less than the elevation grid spacing

npts = length(lat);
[lat,lon] = interpm(lat,lon,0.9/maplegend(1),trackmethod);

% Ensure that longitudes wrap to be over the map
lon = eastof(lon,maplegend(3));

% extract the elevation profile

indx = find(~isnan(lat));
z = NaN*ones(size(lat));

z(indx) = ltln2val(map,maplegend,lat(indx),lon(indx),interpmethod); % 

% determine distances along the track, starting from zero at the beginning of each segment.

[latcells,loncells] = polysplit(lat,lon);

rng = [];
for i=1:length(latcells)

    leglat = latcells{i};
    leglon = loncells{i};
    
    if isstr(rngunits)
        legdist = distance(leglat(1:end-1),leglon(1:end-1),leglat(2:end),leglon(2:end));
    else % geoid provided
        legdist = distance(leglat(1:end-1),leglon(1:end-1),leglat(2:end),leglon(2:end),geoid);
    end
    
    legrng = cumsum(legdist); legrng = [0; legrng];
    if i==1;
        rng = [rng; legrng];
    else
        rng = [rng; NaN;legrng];
    end

end
    
% Convert ranges to desired distance units. If geoid provided, output is in 
% units of geoid(1).

if isstr(rngunits);
    rng = distdim(rng,'deg',rngunits);
end

%if no output arguments, plot results
if nargout == 0;   
   outputplot(nargin,npts,lat,lon,rng,z,rngunits)
else
   zout = z;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [map,maplegend,source] = getrmm

hfig = get(0,'CurrentFigure');
msg = 'This calling form requires a map axes with a displayed regular matrix map';
if isempty(hfig); error(msg); end

haxes = get(hfig,'CurrentAxes');
if isempty(haxes); error(msg); end
if ~ismap(haxes); error(msg); end

mobjstruct = get(gco,'UserData');
if isfield(mobjstruct,'maplegend');
   hobj = gco;
else
   hobj = findall(haxes,'type','surface');
   if isempty(hobj); error(msg); end
   
   for i=length(hobj):-1:1
      mobjstruct = get(hobj(i),'UserData');
      if ~isfield(mobjstruct,'maplegend');
         hobj(i) = [];
      end
   end
   
   if isempty(hobj); error(msg); end
   if length(hobj) > 1; 
      warning('More than one Regular Matrix Map in axes. Using the first one');
      hobj = hobj(1); 
   end
   
end

mobjstruct = get(hobj,'UserData');
maplegend = mobjstruct.maplegend;

mats = get(hobj,{'XData','Ydata','ZData','CData'});
[xdata,ydata,zdata,cdata] = deal(mats{:});

mstruct = get(haxes,'UserData');

if ~isequal(max(zdata(:)),min(zdata(:)));
   map = zdata;
   source = 'ZData';
else
   map = cdata;
   source = 'CData';
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function outputplot(nin,npts,lat,lon,rng,z,rngunits)

% displays output in a new figure

if npts > 2 % plot on a map
   
   if nin == 0;
      
      % Display results on a partial copy of the original map (line data only)
      hax = gca;
      hline = handlem('allline');
      mstruct = getm(hax);
      figure
      axesm miller
      set(gca,'UserData',mstruct)
      copyobj(hline,gca);
      
   else
      
      % Display results on a new map
      latlim = [min(lat(:)) max(lat(:))];
      lonlim = [min(lon(:)) max(lon(:))];
      latlim = mean(latlim)+1.5*diff(latlim)*[-1 1];
      lonlim = mean(lonlim)+1.5*diff(lonlim)*[-1 1];
      figure
      worldmap(latlim,lonlim)
      
   end
   
   % plot additional elements on a map axes
   
   framem on; gridm on; mlabel on; plabel on
   
   zdatam('frame',0)
   zdatam('alltext',0)
   zdatam('allline',0)
   zdatam('grid',0)     
   
   plot3m(lat,lon,z)
   plotm(lat,lon,':')
   stem3m(lat(:),lon(:),z(:))
   
   tightmap
   box off
   
   view(3)
   set(gca,'DataAspectRatio', [ 1 1 5*diff(zlim)/max(diff(xlim),diff(ylim))])
   
   
   
else   
   
   % 2-d plot
   figure
   plot(rng,z)
   if isstr(rngunits);
      xlabel(['Range [' rngunits ']' ])
   end
   ylabel 'Value'
   
end

