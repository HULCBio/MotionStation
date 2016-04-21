function hndl = mlabel(varargin)
%MLABEL Display meridian labels a map axes.
%
%   MLABEL toggles the display of the meridian labels on the
%   map axes.  These labels are drawn using the properties
%   specified in the map axes.
%
%   MLABEL ON turns the meridian labels on.
%   MLABEL OFF turns them off.
%
%   MLABEL RESET will redraw the meridian labels with the currently
%   specified properties.  This differs from the ON and OFF option
%   which simply sets the visible property of the current labels.
%
%   MLABEL(parallel) places the meridian labels at the specified
%   parallel.  The input parallel is used to set the MLabelParallel
%   property in the map axes.
%
%   MLABEL('MapAxesPropertyName',PropertyValue,...) uses the
%   specified Map Axes properties to draw the meridian labels.
%
%   H = MLABEL(...) returns the handles of the labels drawn.
%
%   See also AXESM, MLABELZERO22PI, PLABEL, SET, SETM.

%   Copyright 1996-2003 The MathWorks, Inc.
%   Written by:  E. Byrns, E. Brown
%   $Revision: 1.10.4.2 $    $Date: 2003/08/23 05:55:14 $

%  Initialize output if necessary

if nargout ~= 0;   hndl = [];   end

[mstruct,msg] = gcm;
if ~isempty(msg);  error(msg);  end
h = handlem('MLabel');
string = [];

if nargin == 0
	if ~isempty(h)
	    if ~isempty(strmatch('off',get(h,'Visible')))
	          showm('MLabel');
			  mstruct.meridianlabel = 'on';  set(gca,'UserData',mstruct)
			  return
	    else
	          hidem('MLabel');
			  mstruct.meridianlabel = 'off';  set(gca,'UserData',mstruct)
			  return
	    end
    end

elseif nargin == 1 & strcmp(lower(varargin{1}),'on')
    if ~isempty(h)                      %  Show existing meridian labels.
 	      showm('MLabel');               %  Else, draw new one
		  mstruct.meridianlabel = 'on';
		  set(gca,'UserData',mstruct)
		  return
    end

elseif nargin == 1 & strcmp(lower(varargin{1}),'off')
 	hidem('MLabel');
    mstruct.meridianlabel = 'off';
    set(gca,'UserData',mstruct)
    return

elseif nargin == 1 & ~strcmp(lower(varargin{1}),'reset')
    % AXESM  recursively calls MLABEL to display the labels
    [h,msg] = axesm(mstruct,'MeridianLabel','reset','MLabelParallel',varargin{1});
    error(msg)
    if nargout == 1
        hndl = handlem('MLabel');
    end
	return        

elseif rem(nargin,2) == 0
    %  AXESM  recursively calls MLABEL to display the labels
    [h,msg] = axesm(mstruct,'MeridianLabel','reset',varargin{:});
    error(msg)
    if nargout == 1
        hndl = handlem('MLabel');
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
    case 'compass',   format = 'ew';
	case 'signed',    format = 'pm';
	otherwise,        format = 'none';
end

%  Get the meridian label properties

mposit  = mstruct.mlabellocation;
mplace  = mstruct.mlabelparallel;
mround  = mstruct.mlabelround;

%  Get the necessary current map data

maplon  = mstruct.maplonlimit;
units   = mstruct.angleunits;
frmlat  = mstruct.flatlimit;
gridalt = mstruct.galtitude;

%  Set grid to above top of z axis if altitude is set to inf.

if isinf(gridalt);   gridalt = max(get(gca,'Zlim'))+1;   end

%  Convert the input data into degrees.
%  DMS presents problems with arithmetic below

maplon  = angledim(maplon,units,'degrees');
frmlat  = angledim(frmlat,units,'degrees');
mposit  = angledim(mposit,units,'degrees');
mplace  = angledim(mplace,units,'degrees');
epsilon = 500*epsm('degrees');

%  Skip labeling if inf or NaN entered

if any(isinf(mposit)) | any(isnan(mposit));   return;   end

%  Longitude locations for the whole world and then some
%  Will be truncated later.  Use more than the whole world
%  to ensure capturing the data range of the current map.

lonlim = [-360 360];

%  Compute the longitudes at which to place labels

if length(mposit) == 1
	lonline = [fliplr(-mposit:-mposit:min(lonlim)), 0:mposit:max(lonlim) ];
else
	lonline = mposit;            %  Vector of points supplied
end

lonline = lonline(find(lonline >= min(maplon)  &  lonline <= max(maplon)));

%  Compute the latitude placement points and set vertical justification

latline = mplace(ones(size(lonline)));
if mplace == min(frmlat)
     justify = 'top';
	 if min(frmlat) == -90
	       latline = latline + epsilon;   %  Slightly above south pole
        else
		   latline = latline - epsilon;   %  Slightly below bottom of map
      end
elseif mplace == max(frmlat)
     justify = 'bottom';
	 if max(frmlat) == 90
	       latline = latline - epsilon;   %  Slightly below north pole
        else
		   latline = latline + epsilon;   %  Slightly above top of map
     end
else
     justify = 'middle';
end

%  Compute the label string matrix

labelstr = npi2pi(lonline,'degrees','exact');
labelstr = angledim(labelstr,'degrees',labelunits);
labelstr = angl2str(labelstr,format,labelunits,mround);

%  Transform the location data back into the map units

latline = angledim(latline,'degrees',units);   %  Avoid a reset of -180 to
lonline = npi2pi(lonline,'degrees','inward');  % +180 which can yield a
lonline = angledim(lonline,'degrees',units);   %  double label at +180 spot

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
               'HorizontalAlignment','center',...
               'Interpreter','tex',...
		       'VerticalAlignment',justify,...
		       'Tag','MLabel',...
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

mstruct.meridianlabel = 'on';  set(gca,'UserData',mstruct)

%  Set handle return argument if necessary

if nargout == 1
    hndl = hndl0;
end

