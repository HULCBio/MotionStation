function hndl = plabel(varargin)
%PLABEL Display parallel labels on a map axes.
%
%   PLABEL toggles the display of the parallel labels on the map axes.
%   These labels are drawn using the properties specified in the map axes.
%
%   PLABEL ON turns the parallel labels on. PLABEL OFF turns them off.
%
%   PLABEL RESET will redraw the parallel labels with the currently
%   specified properties.  This differs from the ON and OFF which simply
%   sets the visible property of the current labels.
%
%   PLABEL(meridian) places the parallel labels at the specified meridian.
%   The input meridian is used to set the PLabelMeridian property in the
%   map axes.
%
%   PLABEL('MapAxesPropertyName',PropertyValue,...) uses the specified Map
%   Axes properties to draw the parallel labels.
%
%   H = PLABEL(...) returns the handles of the labels drawn.
%
%   See also MLABEL, AXESM, SETM, SET.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.2 $    $Date: 2003/08/23 05:55:15 $

%  Initialize output if necessary

if nargout ~= 0;   hndl = [];   end

[mstruct,msg] = gcm;
if ~isempty(msg);  error(msg);  end
h = handlem('PLabel');
string = [];

if nargin == 0
	if ~isempty(h)
	    if ~isempty(strmatch('off',get(h,'Visible')))
	          showm('PLabel');
			  mstruct.parallellabel = 'on';  set(gca,'UserData',mstruct)
			  return
	    else
	          hidem('PLabel');
			  mstruct.parallellabel = 'off';  set(gca,'UserData',mstruct)
			  return
	    end
    end

elseif nargin == 1 & strcmp(lower(varargin{1}),'on')
    if ~isempty(h)                      %  Show existing parallel labels.
 	      showm('PLabel');               %  Else, draw new one
		  mstruct.parallellabel = 'on';
		  set(gca,'UserData',mstruct)
		  return
    end

elseif nargin == 1 & strcmp(lower(varargin{1}),'off')
 	hidem('PLabel');
    mstruct.parallellabel = 'off';
    set(gca,'UserData',mstruct)
    return

elseif nargin == 1 & ~strcmp(lower(varargin{1}),'reset')
    % AXESM recursively calls PLABEL to display the labels
    [h,msg] = axesm(mstruct,'ParallelLabel','reset','PLabelMeridian',varargin{1});
    error(msg)
    if nargout == 1
        hndl = handlem('PLabel');
    end
    return

elseif rem(nargin,2) == 0
    % AXESM recursively calls PLABEL to display the labels
    [h,msg] = axesm(mstruct,'ParallelLabel','reset',varargin{:});
    error(msg)
    if nargout == 1
        hndl = handlem('PLabel');
    end
    return

elseif (nargin == 1 & ~strcmp(lower(varargin{1}),'reset') ) | ...
       (nargin > 1 & rem(nargin,2) ~= 0)
    error('Incorrect number of arguments')
end


%  Default operation is to label the map.  Action string = 'reset'

if ~isempty(h);    delete(h);   end       %  Clear existing labels

%  Get the font definition properties

fontangle  = mstruct.fontangle;
fontname   = mstruct.fontname;
fontsize   = mstruct.fontsize;
fontunits  = mstruct.fontunits;
fontweight = mstruct.fontweight;
fontcolor  = mstruct.fontcolor;
labelunits = mstruct.labelunits;

%  Convert the format into a string recognized by angl2str

switch mstruct.labelformat
    case 'compass',   format = 'ns';
	case 'signed',    format = 'pm';
	otherwise,        format = 'none';
end

%  Get the parallel label properties

pposit  = mstruct.plabellocation;
pplace  = mstruct.plabelmeridian;
pround  = mstruct.plabelround;

%  Get the necessary current map data

maplat  = mstruct.maplatlimit;
origin  = mstruct.origin;
units   = mstruct.angleunits;
frmlon  = mstruct.flonlimit;
gridalt = mstruct.galtitude;

%  Set grid to above top of z axis if altitude is set to inf.

if isinf(gridalt);   gridalt = max(get(gca,'Zlim'))+1;   end

%  Convert the input data into degrees.
%  DMS presents problems with arithmetic below

maplat  = angledim(maplat,units,'degrees');
origin  = angledim(origin,units,'degrees');
frmlon  = angledim(frmlon,units,'degrees');
pposit  = angledim(pposit,units,'degrees');
pplace  = angledim(pplace,units,'degrees');
epsilon = 500*epsm('degrees');

%  Skip labeling if inf or NaN entered

if any(isinf(pposit)) | any(isnan(pposit));   return;   end

%  Latitude locations for the whole world

latlim = [-90 90];

%  Compute the latitudes at which to place labels

if length(pposit) == 1
    latline = [fliplr(-pposit:-pposit:min(latlim)), 0:pposit:max(latlim) ];
else
	latline = pposit;            %  Vector of points supplied
end

latline = latline(find(latline >= min(maplat)  &  latline <= max(maplat)));

%  Compute the latitude placement points

lonline = pplace(ones(size(latline)));

%  Set appropriate horizontal justification

if pplace == min(frmlon) + origin(2)
     justify = 'right';
     if  min(frmlon) == -180
	     lonline = lonline + epsilon;   %  Slightly inside the frame
     else
         lonline = lonline - epsilon;   %  Slightly outside the frame
     end

elseif pplace == max(frmlon) + origin(2)
     justify = 'left';
     if max(frmlon) == 180
         lonline = lonline - epsilon;   %  Slightly inside the frame
	 else
         lonline = lonline + epsilon;   %  Slightly outside the frame
     end
else
     justify = 'center';
end

%  Compute the label string matrix

labelstr = angledim(latline,'degrees',labelunits);
labelstr = angl2str(labelstr,format,labelunits,pround);

%  Transform the location data back into the map units

latline = angledim(latline,'degrees',units);
lonline = angledim(lonline,'degrees',units);

%  Display the latitude labels on the map

gridalt = gridalt(ones(size(latline)));

if ~isempty(latline) &~isempty(lonline)

	[hndl0,msg] = textm(latline,lonline,gridalt,labelstr,...
               'Color',fontcolor,...
               'FontAngle',fontangle,...
               'FontName',fontname,...
               'FontSize',fontsize,...
               'FontUnits',fontunits,...
               'FontWeight',fontweight,...
               'HorizontalAlignment',justify,...
               'Interpreter','tex',...
		       'VerticalAlignment','middle',...
		       'Tag','PLabel',...
			   'Clipping','off');
	
	%  Error out if necessary
	
	if ~isempty(msg);   error(msg);   end
	
	%  Align text to graticule
	
	switch mstruct.labelrotation
	case 'on'
		rotatetext(hndl0)
	end

else

	hndl0 = [];
	msg = [];

end

%  Set the display flag to on

mstruct.parallellabel = 'on';  set(gca,'UserData',mstruct)

%  Set handle return argument if necessary

if nargout == 1
    hndl = hndl0;
end
