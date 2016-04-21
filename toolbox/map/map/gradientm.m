function [aspect,slope,gradN,gradE] = gradientm(varargin)

%GRADIENTM Numerical gradient, slope and aspect of matrix maps
%
% [aspect,slope,gradN,gradE] = GRADIENTM(map,maplegend) computes the slope, 
% aspect and north and east components of the gradient for a regular matrix 
% map. If the map contains elevations in meters, the resulting aspect 
% and slope are in units of degrees clockwise from north and up from the 
% horizontal. The north and east gradient components are the change in the 
% map variable per meter of distance in the north and east directions. The 
% computation uses finite differences for the map variable on the default 
% earth ellipsoid.
%
% [aspect,slope,gradN,gradE] = GRADIENTM(lat,lon,map) does the computation 
% for a general matrix map.
%
% [aspect,slope,gradN,gradE] = GRADIENTM(map,maplegend,ellipsoid) and
% [aspect,slope,gradN,gradE] = GRADIENTM(lat,lon,map,ellipsoid) use the 
% provided ellipsoid definition. The ellipsoid vector is of the form
% [semimajor axes, eccentricity]. If the map contains elevations in the
% same units as ellipsoid(1), the slope and aspect are in units of degrees.
% This calling form is most useful for computations on bodies other than 
% the earth.
% 
% [aspect,slope,gradN,gradE] = GRADIENTM(lat,lon,map,ellipsoid,'units') 
% specifies the angle units of the latitude and longitude inputs. If omitted, 
% 'degrees' are assumed. For elevation maps in the same units as ellipsoid(1), 
% the resulting slope and aspect are in the specified units. The components 
% of the gradient are the change in the map variable per unit of ellipsoid(1).
%
% Example: Compute and display the slope for the 30 arc-second (10 km) Korea 
% elevation data. Slopes in the Sea of Japan are up to 8 degrees at this grid
% resolution. 
%
% load korea
% [aspect,slope,gradN,gradE] = gradientm(map,maplegend);
% worldmap(slope,maplegend);
% cmap = cool(10);
% demcmap('inc',slope,1,[],cmap)
% colorbar
%
% See also VIEWSHED

%  Written by Walter Stumpf.
%  Copyright 1996-2003 The MathWorks, Inc.
%  $Revision: 1.4.4.1 $    $Date: 2003/08/01 18:16:27 $

if nargin < 2 | nargin > 5; error('Incorrect number of input arguments.'); end

if nargin >= 3 & ...
    isequal(...
    size(varargin{1}),...
    size(varargin{2}),...
    size(varargin{3}) ...
    )   % lat,lon,map calling form
    
    [latgrat,longrat,map] = deal(varargin{1:3});
    varargin(1:3) = [];
    
    msg = inputcheck('gmm',latgrat,longrat,map); 
    if ~isempty(msg); error(msg); end

elseif isequal(size(varargin{2}),[1 3])  % map,maplegend calling form

    if nargin > 3; error('Incorrect number of input arguments'); end
    [map,maplegend] = deal(varargin{1:2});
    varargin(1:2) = [];
    
    msg = inputcheck('rmm',map,maplegend); 
    if ~isempty(msg); error(msg); end
    
else
    error(sprintf('Inputs must be a regular matrix map or general matrix map with \nall matrices of equal size'))
end


% Get and test the geoid input
geoid = almanac('earth','geoid','m');
if ~isempty(varargin)
    geoid = varargin{1};
    varargin(1) = [];
end
[geoid,msg] = geoidtst(geoid);
if ~isempty(msg);   error(msg);   end

% Get and test the units input
units = 'degrees';
if ~isempty(varargin)
    units = varargin{1}; 
end

% Create a graticule if none is provided
if exist('latgrat','var')
    % convert input graticule to degrees. 
    latgrat = angledim(latgrat,units,'degrees');
    longrat = angledim(longrat,units,'degrees');
else
    % If regular matrix map input, construct a graticule with a point 
    % for point correspondence to the map
    [lat1,lon1] = setltln(map,maplegend,1,1);
    [lat2,lon2] = setltln(map,maplegend,size(map,1),size(map,2));    
    [latgrat,longrat] = meshgrat([lat1 lat2],[lon1 lon2],size(map));
end


% Compute the projected positions of the points. Use the Platte Carree projection,
% which is equidistant. Compute the gradient on the pcarree projection, and then 
% correct for the convergence of the meridians below.

%  Construct the necessary map structure

mstruct = defaultm('pcarree');
mstruct.geoid        = geoid;
mstruct = defaultm(pcarree(mstruct));


% Project the graticule. This gets the positions into the same units as that
% of geoid(1), which allows the computation of slopes of elevation maps
% Later we'll adjust the gradient values by the amount that the meridians have 
% converged relative to the equator

[x,y] = mfwdtran(mstruct,latgrat,longrat);

% Compute the gradient for the cell spacing in the projected cylindrical 
% coordinate system.

[gradE,gradN] = mtxgradient(map,x,y);

% Adjust the longitude gradient for the convergence of the meridians
latvec = (latgrat(:,1))';
convfactor = departure(...
   zeros(size(latgrat)),...
   ones(size(latgrat)),...
   latgrat,geoid)...
   / departure(0,1,0,geoid);

convfactor(convfactor==0) = NaN; % avoid divide by zeros 
gradE = gradE ./ convfactor;

% Compute slope and aspect

[aspect,mag]    = cart2pol(gradE,gradN);
aspect(gradN==0 & gradE==0) = NaN;
slope           = atan(mag);

% convert to desired units
aspect  = zero22pi(-aspect-pi/2,'radians');
aspect  = angledim(aspect,'radians',units);
slope   = angledim(slope,'radians',units);    






%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [dfdx,dfdy] = mtxgradient(f,x,y)
%MTXGRADIENT gradient for matrix with variable cell spacing


[n,m] = size(x);
if n < 3 | m < 3; error('Matrix must be 4 by 4 or larger to compute gradient'); end

% Derivatives of function with respect to rows and columns
dfdc = zeros(size(x));
dfdr = zeros(size(y));

% Take forward differences on left and right edges
dfdr(1,:)   = (f(2,:)   - f(1,:)    ) ;
dfdr(end,:) = (f(end,:) - f(end-1,:)) ;

dfdc(:,1) = f(:,2) - f(:,1);
dfdc(:,end) = f(:,end) - f(:,end-1);

% Take centered differences on interior points
dfdr(2:end-1,:) = (f(3:end,:)-f(1:end-2,:)) / 2;
dfdc(:,2:end-1) = (f(:,3:end)-f(:,1:end-2)) / 2;

% Differences of x and y with respect to row and column numbers
dxdc = zeros(size(x));
dxdr = zeros(size(x));
dydc = zeros(size(y));
dydr = zeros(size(y));


[n,m] = size(f);
if n < 3 | m < 3; error('Matrix must be 4 by 4 or larger to compute gradient'); end

% Take forward differences on left and right edges
dxdr(1,:)   = x(2,:) -x(1,:);
dxdr(end,:) = x(end,:)-x(end-1,:);
dydr(1,:)   = y(2,:) -y(1,:);
dydr(end,:) = y(end,:)-y(end-1,:);

dxdc(:,1)   = x(:,2) - x(:,1);
dxdc(:,end) = x(:,end)-x(:,end-1);
dydc(:,1)   = y(:,2) - y(:,1);
dydc(:,end) = y(:,end)-y(:,end-1);

% Take centered differences on interior points
dydr(2:end-1,:) = (y(3:end,:)-y(1:end-2,:))/2;
dxdc(:,2:end-1) = (x(:,3:end)-x(:,1:end-2))/2;

dxdr(2:end-1,:) = (x(3:end,:)-x(1:end-2,:))/2;
dydc(:,2:end-1) = (y(:,3:end)-y(:,1:end-2))/2;


% Angles of graticule rows and columns

colang = atan2(dydc,dxdc);
rowang = atan2(dydr,dxdr);

% distances between elements along graticule rows and columns
rowdist = sqrt(dxdr.^2 + dydr.^2);
coldist = sqrt(dxdc.^2 + dydc.^2);

% conserve memory

clear dx* dy*

% derivatives in the x and y directions

dfdx =  dfdc ./ coldist .* cos(colang) + ...
        dfdr ./ rowdist .* cos(rowang);
dfdy =  dfdr ./ rowdist .* sin(rowang) + ...
        dfdc ./ coldist .* sin(colang);



