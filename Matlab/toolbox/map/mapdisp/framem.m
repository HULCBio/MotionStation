function hndl = framem(varargin)

%FRAMEM  Toggle and control the display of the map frame
%
%  FRAMEM toggles the display of the map frame.  The map frame
%  is drawn at the longitude and latitude limits specified
%  by the frame properties in the map axes.
%
%  FRAMEM ON turns the map frame on.  FRAMEM OFF turns it off.
%
%  FRAMEM RESET will redraw the frame with the currently
%  specified properties.  This differs from the ON and OFF
%  which simply sets the visible property of the current frame.
%
%  FRAMEM('LineSpec') uses any valid LineSpec string to define
%  the frame edge.
%
%  FRAMEM('MapAxesPropertyName',PropertyValue,...) uses the
%  specified Map Axes properties to draw the frame.
%
%  h = FRAMEM(...) returns the handle of the frame drawn.
%
%  See also AXESM, SETM

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.1 $    $Date: 2003/08/01 18:18:23 $

%  Initialize output if necessary

if nargout ~= 0;   hndl = [];   end

%  Test for map axes

[mstruct,msg] = gcm;
if ~isempty(msg);  error(msg);  end
h = handlem('Frame');


if nargin == 0
	if ~isempty(h)
	    if strcmp(get(h,'Visible'),'off')
	          showm('Frame');
			  mstruct.frame = 'on';  set(gca,'UserData',mstruct)
			  return
	    else
	          hidem('Frame');
			  mstruct.frame = 'off';  set(gca,'UserData',mstruct)
			  return
	    end
    end

elseif nargin == 1 & strcmp(lower(varargin{1}),'on')
    if ~isempty(h)                      %  Show existing frame.
 	      showm('Frame');                %  Else, draw new one
		  mstruct.frame = 'on';
		  set(gca,'UserData',mstruct)
		  return
    end

elseif nargin == 1 & strcmp(lower(varargin{1}),'off')
 	hidem('Frame');
    mstruct.frame = 'off';
    set(gca,'UserData',mstruct)
    return

elseif nargin == 1 & ~strcmp(lower(varargin{1}),'reset')
    [lstyle,lcolor,lmark,msg] = colstyle(varargin{1});
    if ~isempty(msg);   error(msg);   end

%  Build up a new property string vector for input to AXESM

    varargin(1) = [];
 	if ~isempty(lcolor)
	     varargin{length(varargin)+1} = 'FEdgeColor';
		 varargin{length(varargin)+1} = lcolor;
    end

%  If a valid line style is found, then display the new grid, via AXESM

    if ~isempty(varargin)
	    [h,msg] = axesm(mstruct,'Frame','reset',varargin{:});
  	    if ~isempty(msg);  error(msg);   end
	    return        %  AXESM  recursively calls FRAMEM to display the frame
	end

elseif rem(nargin,2) == 0
     [h,msg] = axesm(mstruct,'Frame','reset',varargin{:});
	 if ~isempty(msg);  error(msg);   end
	 return        %  AXESM  recursively calls FRAMEM to display the grid

elseif (nargin == 1 & ~strcmp(lower(varargin{1}),'reset') ) | ...
       (nargin > 1 & rem(nargin,2) ~= 0)
    error('Incorrect number of arguments')
end


%  Default operation is to draw the frame.  Action string = 'reset'

if ~isempty(h);    delete(h);   end       %  Clear existing frame

%  Retrieve frame data associated with the current map display

edgecolor  = mstruct.fedgecolor;   %  Frame style parameters
facecolor  = mstruct.ffacecolor;
linewidth  = mstruct.flinewidth;
fillpts    = mstruct.ffill;
origin     = mstruct.origin;

framelat  = mstruct.flatlimit;
framelon  = mstruct.flonlimit;
units     = mstruct.angleunits;

epsilon   = 1000*epsm('degrees');


if all(~isinf(framelat))           %  Then frame is not an azimuthal disk

        framelat = sort(angledim(framelat,units,'degrees'));   %  Convert input
        framelon = sort(angledim(framelon,units,'degrees'));   %  data to degrees


        framelat = framelat + [epsilon -epsilon];    %  Avoid clipping at edge of
        framelon = framelon + [epsilon -epsilon];    %  of map

		lats = linspace(min(framelat),max(framelat),fillpts)';       %  Fill vectors with
        lons = linspace(min(framelon),max(framelon),fillpts)';   %  frame limits

        latfrm = [lats;           framelat(2)*ones(size(lats));  %  Construct
	    	      flipud(lats);   framelat(1)*ones(size(lats))]; %  complete frame
        lonfrm = [framelon(1)*ones(size(lons));    lons;         %  vectors
		          framelon(2)*ones(size(lons));    flipud(lons);];


elseif  any(isinf(framelat))          %  Frame is an azimuthal disk

		if strcmp(mstruct.mapprojection,'vperspec') % vertical perspective requires special treatment
			P = mstruct.mapparallels/mstruct.geoid(1) + 1;
			% reset the frame
			trimlat = [-inf  min( [ acos(1/P)-5*epsm('radians')  max(framelat)  1.5533] ) ]; % 1.5533 rad = 89 degrees
			mstruct.flatlimit = rad2deg(trimlat);
			framelat  = mstruct.flatlimit;
		end
			
			
        framelat = angledim(max(framelat),units,'degrees');   %  Convert disk radius

        framelat = framelat - epsilon;      %  Avoid clipping at map edge

        az = [0 360];      %  Compute azimuthal points on frame

        [latfrm,lonfrm] = scircle1('gc',0,0,framelat,az,[],...
		                           'degrees',fillpts);   %  Compute frame vector
end

%  Reset the origin so that the frame is displayed relative to the
%  base projection (not a potentially skewed rotation)

mstruct.origin = [0 0 0];
set(gca,'UserData',mstruct);

%  Transform frame data to the map units

latfrm = angledim(latfrm,'degrees',units);
lonfrm = angledim(lonfrm,'degrees',units);

%  Display the frame as a patch below the minimum z altitude
%  This ensures that the patch is below everything which may
%  already be displayed on the map

framealt = min(get(gca,'zlim')) - 1;

h0 = patchm(latfrm,lonfrm,framealt,...
   'ButtonDownFcn','uimaptbx',...
   'Tag','Frame',...
   'FaceColor',facecolor,...
   'EdgeColor',edgecolor,...
   'LineWidth',linewidth);

% Restack the frame to the bottom to avoid blocking access to
% other object's buttondownfcns

restack('Frame','bot');
           
%  Reset the origin for subsequent plotting onto this map

mstruct.origin = origin;
set(gca,'UserData',mstruct);

%  Set the display flag to on

mstruct.frame = 'on';  set(gca,'UserData',mstruct)


%  Set the output argument if necessary

if nargout == 1;  hndl = h0;  end



