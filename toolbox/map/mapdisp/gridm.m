function hndl = gridm(varargin)

%GRIDM  Toggle and control the display of the map grid
%
%  GRIDM toggles the display of the map grid.  The map grid
%  is drawn using the properties specified in the map axes.
%
%  GRIDM ON turns the map frame on.  GRIDM OFF turns it off.
%
%  GRIDM RESET will redraw the grid with the currently
%  specified properties.  This differs from the ON and OFF
%  which simply sets the visible property of the current grid.
%
%  GRIDM('LineSpec') uses any valid LineSpec string to define
%  the grid lines.
%
%  GRIDM('MapAxesPropertyName',PropertyValue,...) uses the
%  specified Map Axes properties to draw the grid.
%
%  h = GRIDM(...) returns the handles of the grid drawn.
%
%  See also AXESM, SETM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.9.4.1 $    $Date: 2003/08/01 18:18:28 $

%  Initialize output if necessary

if nargout ~= 0;   hndl = [];   end

%  Test for map axes

[mstruct,msg] = gcm;
if ~isempty(msg);  error(msg);  end
h = handlem('Grid');

if nargin == 0
	if ~isempty(h)
	    if ~isempty(strmatch('off',get(h,'Visible')))
	        showm('Grid');                   mstruct.grid = 'on';
			set(gca,'UserData',mstruct);    return
	    else
	        hidem('Grid');                   mstruct.grid = 'off';
			set(gca,'UserData',mstruct);    return
	    end
    end

elseif nargin == 1 & strcmp(lower(varargin{1}),'on')
    if ~isempty(h)                    %  Show existing grid.
 	      showm('Grid');               %  Else, draw new one
		  mstruct.grid = 'on';
		  set(gca,'UserData',mstruct)
		  return
    end

elseif nargin == 1 & strcmp(lower(varargin{1}),'off')
 	hidem('Grid');
    mstruct.grid = 'off';
    set(gca,'UserData',mstruct)
    return

elseif nargin == 1 & ~strcmp(lower(varargin{1}),'reset')
    [lstyle,lcolor,lmark,msg] = colstyle(varargin{1});
    if ~isempty(msg);   error(msg);   end

%  Build up a new property string vector for input to AXESM

    varargin(1) = [];
    if ~isempty(lcolor)
	     varargin{length(varargin)+1} = 'GColor';
		 varargin{length(varargin)+1} = lcolor;
    end
    if ~isempty(lstyle)
	     varargin{length(varargin)+1} = 'GLineStyle';
		 varargin{length(varargin)+1} = lstyle;
    end

%  If a valid line style is found, then display the new grid, via AXESM

    if ~isempty(varargin)
	    [h,msg] = axesm(mstruct,'Grid','reset',varargin{:});
  	    if ~isempty(msg);  error(msg);   end
	    return        %  AXESM  recursively calls GRIDM to display the grid
	end

elseif rem(nargin,2) == 0
     [h,msg] = axesm(mstruct,'Grid','reset',varargin{:});
	 if ~isempty(msg);  error(msg);   end
	 return        %  AXESM  recursively calls GRIDM to display the grid

elseif (nargin == 1 & ~strcmp(lower(varargin{1}),'reset') ) | ...
       (nargin > 1 & rem(nargin,2) ~= 0)
    error('Incorrect number of arguments')
end

%  Default operation is to draw the grid.  Action string = 'reset'

if ~isempty(h);    delete(h);   end       %  Clear existing grids

gridalt    = mstruct.galtitude;    %  Grid style parameters
color      = mstruct.gcolor;
linewidth  = mstruct.glinewidth;
linestyle  = mstruct.glinestyle;

%  Set grid to above top of z axis if altitude is set to inf.

if isinf(gridalt);   gridalt = max(get(gca,'Zlim'))+1;   end

hlat0 = NaN;     hlon0 = NaN;   %  Initialize grid handles

[latout,lonout] = latgrid(mstruct);    %  Compute latitude grid

if ~isempty(latout)                              %  Display latitude grid
     hlat0 = linem(latout,lonout,gridalt(ones(size(latout)),:),...
                  'ButtonDownFcn','uimaptbx',...
                  'Tag','Parallel',...
				  'Color',color,...
				  'LineWidth',linewidth,...
				  'LineStyle',linestyle,...
				  'Visible',mstruct.plinevisible);
end


[latout,lonout] = longrid(mstruct);    %  Compute longitude grid

if ~isempty(latout)                              %  Display longitude grid
    hlon0 = linem(latout,lonout,gridalt(ones(size(latout)),:),...
                  'ButtonDownFcn','uimaptbx',...
                  'Tag','Meridian',...
				  'Color',color,...
				  'LineWidth',linewidth,...
				  'LineStyle',linestyle,...
				  'Visible',mstruct.mlinevisible);
end

%  Set the display flag to on if either line is drawn

if isempty(hlat0) & isempty(hlon0);     mstruct.grid = 'off';
    else;                               mstruct.grid = 'on';
end
set(gca,'UserData',mstruct)

if nargout == 1                  %  Set handle return argument if necessary
    hndl = [hlat0;hlon0];
end

%**************************************************************************
%**************************************************************************
%**************************************************************************

function [latout,lonout] = latgrid(mstruct)

%LATGRID  Computation of latitude grid lines
%
%  Purpose
%
%  LATGRID will compute vectors of latitude grid lines for the
%  currently displayed map.  The latitude grid definition is
%  contained in the current map structure.
%
%  Synopsis
%
%       [lat,lon] = latgrid(mstruct)
%       mat = latgrid(mstruct)         %  where mat = [lat lon]
%
%       See also AXESM, LONGRID, GRIDM


%  Argument error tests

if nargin == 0
    limits = [];    exception = [];

elseif nargin == 1
    exception = [];
end


%  Retrieve grid definition parameters

latdelta   = mstruct.plinelocation;
limits     = mstruct.plinelimit;
exception  = mstruct.plineexception;
fillpts    = mstruct.plinefill;

maplat  = mstruct.maplatlimit;
maplon  = mstruct.maplonlimit;
units   = mstruct.angleunits;

%  Convert the input data into degrees.
%  DMS presents problems with arithmetic below

maplat    = angledim(maplat,units,'degrees');
maplon    = angledim(maplon,units,'degrees');
latdelta  = angledim(latdelta,units,'degrees');
limits    = angledim(limits,units,'degrees');
exception = angledim(exception,units,'degrees');
epsilon   = 100*epsm('degrees');

%  Skip grid if inf or NaN entered

if any(isinf(latdelta)) | any(isnan(latdelta))
     latout = [];  lonout = [];    return
end

%  Latitude locations for the whole world

latlim = [-90 90];

%  Compute the latitudes at which to draw grid lines

if length(latdelta) == 1
    latline  = [fliplr(0:latdelta:max(latlim)), ...
	            -latdelta:-latdelta:min(latlim) ];
else
	latline = latdelta;              %  Vector of points supplied
end

latline = latline(find(latline >= min(maplat)  &  latline <= max(maplat)));

%  Compute the longitude fill points for each latitude grid line

lonline = linspace(min(maplon)+epsilon,max(maplon)-epsilon,fillpts);

%  Use meshgrid to fill in the points on each grid line
%  Note that the longitude line has been NaN clipped.

[lonline,latline] = meshgrid([lonline NaN], latline);

%  Make the grid data into vectors

latline = latline';  latline = latline(:);
lonline = lonline';  lonline = lonline(:);

%  Process any grids which are restricted from the entire
%  map display

if ~isempty(limits)
    indxlow = find(lonline < min(limits));
    indxup  = find(lonline > max(limits));

    if ~isempty([indxlow; indxup])
        for i = 1:length(exception)      %  Exceptions to the limit process
		    exceptindx = find(abs(latline(indxlow) - exception(i)) <= 10*epsilon);
			indxlow(exceptindx) = [];
		    exceptindx = find(abs(latline(indxup) - exception(i)) <= 10*epsilon);
			indxup(exceptindx) = [];
		end
	end

    lonline(indxlow) = min(limits);
    lonline(indxup)  = max(limits);
end

%  Set return arguments if necessary

if nargout ~= 2
    latout = angledim([latline lonline],'degrees',units);
else
    latout = angledim(latline,'degrees',units);
	lonout = angledim(lonline,'degrees',units);;
end


%**************************************************************************
%**************************************************************************
%**************************************************************************

function [latout,lonout] = longrid(mstruct)

%LONGRID  Computation of longitude grid lines
%
%  Purpose
%
%  LONGRID will compute vectors of longitude grid lines for the
%  currently displayed map.    The latitude grid definition is
%  contained in the current map structure.
%
%  Synopsis
%
%       [lat,lon] = longrid(mstruct)
%       mat = longrid(mstruct)      %  where mat = [lat lon]
%
%       See also AXESM, LATGRID, GRIDM


%  Retrieve grid definition parameters

londelta   = mstruct.mlinelocation;
limits     = mstruct.mlinelimit;
exception  = mstruct.mlineexception;
fillpts    = mstruct.mlinefill;

maplat  = mstruct.maplatlimit;
maplon  = mstruct.maplonlimit;
units   = mstruct.angleunits;

%  Convert the input data into degrees.
%  DMS presents problems with arithmetic below

maplat    = angledim(maplat,units,'degrees');
maplon    = angledim(maplon,units,'degrees');
londelta  = angledim(londelta,units,'degrees');
limits    = angledim(limits,units,'degrees');
exception = angledim(exception,units,'degrees');
epsilon   = 100*epsm('degrees');

%  Skip grid if inf or NaN entered

if any(isinf(londelta)) | any(isnan(londelta))
     latout = [];  lonout = [];    return
end

%  Longitude locations for the whole world and then some
%  Will be truncated later.  Use more than the whole world
%  to ensure capturing the data range of the current map.

lonlim = [-360 360];

%  Compute the longitudes at which to draw grid lines

if length(londelta) == 1
    lonline = [fliplr(-londelta:-londelta:min(lonlim)), ...
	           0:londelta:max(lonlim) ];
else
	lonline = londelta;           %  Vector of points supplied
end

lonline = lonline(find(lonline >= min(maplon)  &  lonline <= max(maplon)));

%  Compute the latitude fill points for each latitude grid line
%  Adjust by delta so as to not loose grid lines at the edge of the map

latline = linspace(max(maplat)-epsilon,min(maplat)+epsilon,fillpts);

%  Use meshgrid to fill in the points on each grid line
%  Note that the latitude line has been NaN clipped.

[lonline,latline] = meshgrid(lonline, [latline NaN]);

%  Make the grid data into vectors

lonline = lonline(:);     latline = latline(:);

%  Process any grids which are restricted from the entire
%  map display

if ~isempty(limits)
    indxlow = find(latline < min(limits));
    indxup  = find(latline > max(limits));

    if ~isempty([indxlow; indxup])
        for i = 1:length(exception)      %  Exceptions to the limit process
		    exceptindx = find(abs(lonline(indxlow) - exception(i)) <= 10*epsilon);
			indxlow(exceptindx) = [];
		    exceptindx = find(abs(lonline(indxup) - exception(i)) <= 10*epsilon);
			indxup(exceptindx) = [];
		end
	end

    latline(indxlow) = min(limits);
    latline(indxup)  = max(limits);
end

%  Set return arguments if necessary

if nargout ~= 2
    latout = angledim([latline lonline],'degrees',units);
else
    latout = angledim(latline,'degrees',units);
    lonout = angledim(lonline,'degrees',units);;
end


