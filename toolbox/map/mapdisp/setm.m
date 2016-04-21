function setm(varargin)

%SETM  Modify the properties of a displayed map
%
%  SETM(h,'MapAxesPropertyName',PropertyValue,...), where h is a
%  valid map axes handle, sets the map properties specified in
%  the input list.  The map properties must be recognized by AXESM.
%
%  SETM(h,'MapPosition',position), where h is a valid projected
%  map text object, uses a two or three element position vector
%  specifying [latitude, longitude, altitude].  For two element
%  vectors, altitude = 0 is assumed.
%
%  SETM(h,'Graticule',lat,lon,alt), where h is a valid projected
%  surface object, uses lat and lon matrices of same size to specify
%  the graticule vertices.  The input alt can be either a scalar
%  to specify the altitude plane, a matrix of the same size as lat and
%  lon, or an empty matrix.  If omitted, alt = 0 is assumed.
%
%  For projected surface objects displayed using MESHM:
%  SETM(h,'MeshGrat',gsize,alt), where h is a valid surface object
%  displayed using MESHM, uses the two element vector gsize to
%  specify the graticule size (see MESHM).  The last input alt can
%  be either a scalar to specify the altitude plane, a matrix of the
%  size(gsize), or an empty matrix.  If omitted, alt = 0 is assumed.
%
%  See also  GETM, AXESM, SET, GET

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  E. Byrns, E. Brown
%  $Revision: 1.13.4.1 $  $Date: 2003/08/01 18:22:43 $


if nargin == 0;  error('Incorrect number of arguments');   end

%  Determine the object type

if isstr(varargin{1})
   varargin{1} = handlem(varargin{1});
end

if max(size(varargin{1})) ~= 1 | ~ishandle(varargin{1})
      error('Valid object handle required')
end

switch get(varargin{1},'Type')

   case 'axes'
           if length(varargin) == 1
                           DisplayAxesProperties;  return
                   elseif length(varargin) == 2 & isstr(varargin{2})
                           DisplayAxesProperties(varargin{2});  return
                   else
                           msg = setmaxes(varargin{:});
                   end

   case 'surface'
           if length(varargin) == 1
                           DisplaySurfProperties;  return
                   elseif length(varargin) == 2 & isstr(varargin{2})
                           DisplaySurfProperties(varargin{2});  return
                   else
                           msg = setmsurf(varargin{:});
                   end

   case 'text'
           if length(varargin) == 1
                           DisplayTextProperties;  return
                   elseif length(varargin) == 2 & isstr(varargin{2})
                           DisplayTextProperties(varargin{2});  return
                   else
                           msg = setmtext(varargin{:});
                   end
	otherwise
		tagstr = get(varargin{1},'Tag');
		if strmatch('scaleruler',tagstr); tagstr = 'scaleruler'; end % strip trailing numbers
		switch tagstr
		case 'scaleruler' % scaleruler
			if length(varargin) == 1
				DisplayScaleProperties;  return
	        elseif length(varargin) == 2 & isstr(varargin{2})
	            DisplayScaleProperties(varargin{2});  return
	        else
	            msg = setmscale(varargin{:});
			end
		otherwise		   
       		error('Object type not supported by SETM.  Use SET');
		end
end

if ~isempty(msg);   error(msg);   end


%**************************************************************************
%**************************************************************************
%**************************************************************************


function msg = setmaxes(varargin)

%SETMAXES  Processes the SETM operations for an axes object
%
%  Note that error conditions are returned in the output argument msg.
%  Processing of the property list for errors is accomplished by
%  the call to AXESM.


msg = [];        %  Initialize output

if nargin < 2 | (nargin == 2 & ~isstruct(varargin{2}))
     msg = 'Incorrect number of arguments';   return
end

%  Ensure that the input object is a map axes

if ~ismap(varargin{1})
    msg = 'Axis handle must refer to a map';     return
end

%  Get the current projection data

[oldstruct,msg] = gcm(varargin{1});
if ~isempty(msg);   return;   end

% Delete the mdistort lines and text. If they were present, recompute after 
% reprojecting

mdistortparam = mdistort('off');

% Delete the parallelui lines. If they were present, restore after 
% reprojecting

hpar = findobj(gca,'Tag','paralleluiline');
onparui = 0;
if ~isempty(hpar)
	onparui = 1;
	hpar = findobj(gca,'Tag','paralleluiline');
	delete(hpar)
end

%  Eliminate the frame, grid, meridian and parallel labels from the map.
%  AXESM will redisplay them if their status is currently on.

delete(handlem('frame',varargin{1}));
delete(handlem('grid',varargin{1}));
delete(handlem('plabel',varargin{1}));
delete(handlem('mlabel',varargin{1}));

%  Get the children of the current map axes.  Must be done
%  when after the deletions above but before those objects
%  are restored in the axesm call.

children = get(varargin{1},'Children');

%  Make the map axes current.  This control of the current figure
%  and current axes properties avoids activating the figure window
%  during the reprojection of the map.  This behavior mirrors SET.

oldaxes = get(get(0,'CurrentFigure'),'CurrentAxes');
set(0,'CurrentFigure',get(varargin{1},'Parent'))
set(get(varargin{1},'Parent'),'CurrentAxes',varargin{1})

%  Get the axes properties which axesm changes to defaults

properties.nextplot   = get(varargin{1},'NextPlot');
properties.dataaspect = get(varargin{1},'DataAspectRatio');
properties.dataaspmode= get(varargin{1},'DataAspectRatioMode');
properties.boxvar     = get(varargin{1},'Box');
properties.buttondwn  = get(varargin{1},'ButtonDownFcn');
properties.visible    = get(varargin{1},'Visible');

%  Process the map properties.  Reset the axes after this process

if isstruct(varargin{2})      %  Special operation from axesmui
	 [h,msg] = axesm(varargin{2});
else
    varargin{1} = oldstruct;   [h,msg] = axesm(varargin{:});
end


if ~isempty(msg)   %  Restore deleted objects if necessary (oldstruct still in axes)
   gridm(oldstruct.grid);              framem(oldstruct.frame);
   plabel(oldstruct.parallellabel);    mlabel(oldstruct.meridianlabel);
end

%  Reset the current figure and axes

set(0,'CurrentFigure',get(oldaxes,'Parent'))
set(get(oldaxes,'Parent'),'CurrentAxes',oldaxes)

%  Exit if there has been an error condition

if ~isempty(msg);    return;    end

%  Restore the axes properties which a successful call to
%  axesm will have changed to the default map settings.
%  The user may have changed these properties, especially the
%  DataAspectRatio for 3D plots.

set(h,'NextPlot',            properties.nextplot);
set(h,'DataAspectRatio',     properties.dataaspect);
set(h,'DataAspectRatioMode', properties.dataaspmode);
set(h,'Box',                 properties.boxvar);
set(h,'ButtonDownFcn',       properties.buttondwn);
set(h,'Visible',             properties.visible);

%  Get the new map structure

newstruct = gcm(h);

% Determine if objects need to be reprojected

reproQ=1;
mstructdiff = fielddiff(oldstruct,newstruct);
if ~isstruct(mstructdiff) &  mstructdiff == 0
	reproQ = 0;
elseif ~isstruct(mstructdiff) & mstructdiff == 1 	% structure fields different. 
													% Not properly updated for new fields?
	reproQ = 1;
elseif ~isequal(1,mstructdiff)
	reproQ = reprojectQ(mstructdiff);
end

%  Reproject each child of the map axes

if reproQ

	for i = 1:length(children)
	
	   object = get(children(i),'Type');
	   olduserdata = get(children(i),'UserData');
	
	   if ismapped(children(i))    %  Make sure each object is projected
	
			% get the geographic coordinates, and reproject
			switch object
			case 'patch'
	
				FVCD = get(children(i),'FaceVertexCData');
	
				if length(FVCD) > 1 % completely general patch made mapped by PROJECT. CLIPDATA and SETFACES aren't set up to handle this
	
		   			%  Note:  CART2GRN returns a scalar ALT variable if the object is a patch
					vertices = get(children(i),'Vertices');
					x = vertices(:,1);
					y = vertices(:,2);
					alt = vertices(:,3);
					oldz = alt;
					savepts = getm(children(i));
					[lat,lon,alt] = minvtran(oldstruct,x,y,alt,'surface',savepts);
					lat = angledim(lat,oldstruct.angleunits,newstruct.angleunits);
					lon = angledim(lon,oldstruct.angleunits,newstruct.angleunits);
					[x,y,z,savepts] = mfwdtran(newstruct,lat,lon,alt,'surface');  %  New projection
	
				else 				% patch created using a mapping toolbox command
			
					[lat,lon,alt] = cart2grn(children(i),oldstruct);  %  Greenwich data
					lat = angledim(lat,oldstruct.angleunits,newstruct.angleunits);
					lon = angledim(lon,oldstruct.angleunits,newstruct.angleunits);
            [x,y,z,savepts] = mfwdtran(newstruct,lat,lon,alt,object);  %  New projection
            oldz = alt;   
	
				end
			otherwise
				[lat,lon,alt] = cart2grn(children(i),oldstruct);  %  Greenwich data
				lat = angledim(lat,oldstruct.angleunits,newstruct.angleunits);
				lon = angledim(lon,oldstruct.angleunits,newstruct.angleunits);
				[x,y,z,savepts] = mfwdtran(newstruct,lat,lon,alt,object);  %  New projection
			end
	
			switch object
			case 'text'
	           set(children(i),'Position', [x y z],'UserData',savepts);
	
			case 'light'
		       if isempty(x) | isempty(y) | isempty(z)
			          delete(children(i))      %  Remove trimmed lights
			   else
			          set(children(i),'Position',[x y z])
			   end
	
			case 'patch'   %  Patch objects are a little complicated. See similar code in project
				if length(lat) == 1		% point data; undo closure of patch
					x = x(1); y = y(1); z = z(1);
					set(children(i),'Vertices',[x y z],'UserData',savepts);
				else
					if isempty(FVCD) | length(FVCD) == 1 % standard mapping toolbox patches
			    		faces = setfaces(x,y);	%  Determine the vertices of the faces for this map
						set(children(i),'Faces',faces,'Vertices',[x y z],'UserData',savepts);
					elseif  length(FVCD)+2 == length(x) % general patches, not clipped. SETFACES won't handle this either
						set(children(i),'Vertices',[x(1:end-2) y(1:end-2) oldz],'UserData',savepts);
					else   % general patches, clipped. Can't clip them yet, so try to do as much right as possible
							% Currently can trim down, but not untrim
						[x,y,z,savepts] = mfwdtran(lat,lon,oldz,'surface');
						set(children(i),'Vertices',[x y z],'UserData',savepts);
					end	
				end
			
			otherwise
			   if strcmp(object,'surface')                         %  Keep the
			         userdata = get(children(i),'UserData');       %  maplegend
		             mfields = char(fieldnames(userdata));         %  property
	                 indx = strmatch('maplegend',mfields,'exact'); % if available
	                 if length(indx) == 1
					        savepts.maplegend = userdata.maplegend;
					 end
			   end
	
	           set(children(i),'Xdata',x,'Ydata',y,'Zdata',z,'UserData',savepts);
	       end
	   end
   end
   
   % Also handle interactive tracks, lines and sectors, which do not 
   % have the signature of projected objects
   scircleg reproject
   sectorg reproject
   trackg reproject
   
   % Move the frame to the bottom of the stacking order to avoid blocking access to
   % other object's buttondownfcns
   restack('Frame','bot')
   
end % if reproQ

% reset the frame. This is required for the vertical perspective projection,
% which may change the range of the frame from the center of the projection.

hframe = findobj(gca,'Type','patch','Tag','Frame');
if ~isempty(hframe)
	vis = get(hframe,'Visible');
	hframe = framem('reset');
	set(hframe,'Visible',vis)
end

% Restack the Frame to the bottom, so that buttondownfcns on 
% objects are still accessible.

restack('Frame','bottom')

% Restore the mdistort lines and text if they were present before.
% These will now be recomputed for the current projection.

if ~isempty(mdistortparam)
	mdistort(mdistortparam)
end

% Restore the parallelui lines if they were present before.

if onparui
	parallelui on
end

% Update scale ruler, if present

[h,msg] = handlem('scaleruler');
if ~isempty(h);
	h = min(h);
	setm(h,'lat',[],'long',[],'xloc',[],'yloc',[])
end

%**************************************************************************
%**************************************************************************
%**************************************************************************


function msg = setmtext(varargin)

%SETMTEXT  Processes the SETM operations for a text object
%
%  Note that error conditions are returned in the output argument msg.
%  Only one property is recognized for text objects.  The MapPosition
%  property is a vector of [lat, lon, alt].  The third element, alt, is
%  optional.


msg = [];        %  Initialize output

if nargin == 1
    disp(strvcat(' ','MapPosition      [2 or 3 element vector]'))
    return
elseif nargin ~= 3
    msg = 'Incorrect number of arguments';   return
end

%  Make sure that the text object is projected

if ~ismapped(varargin{1})
    msg = 'Text object not projected.  Use SET';   return
end

%  Make sure that the valid property is supplied

indx = findstr(lower(varargin{2}),'mapposition');
if isempty(indx) | indx ~= 1
    msg = 'Unrecognized property for Map Text';   return
end

%  Test the input position vector.  Set the alt value if necessary

position = varargin{3};   position = position(:);   %  Ensure vector
if length(position) ~= 2 & length(position) ~= 3
    msg = 'Position vector must be either 2 or 3 elements';   return
end

%  Get the position data

lat = position(1);  lon = position(2);
if length(position) == 2;   alt = 0;
    else;          alt = position(3);
end

%  Project the new position and then
%  set the position property of the text object

[x,y,z,savepts] = mfwdtran(lat,lon,alt,'text');
set(varargin{1},'Position', [x y z],'UserData',savepts);


%**************************************************************************
%**************************************************************************
%**************************************************************************


function msg = setmsurf(varargin)

%SETMSURF  Processes the SETM operations for a surface object
%
%  Note that error conditions are returned in the output argument msg.
%  Only two properties are recognized for surface objects.
%           'Graticule'   requires a lat, lon and alt matrix input
%           'MeshGrat'    requires an npts vector input and the surface
%                         object must be displayed using meshm, which
%                         retains the maplegend data.  An alt input
%                         can also be supplied.


msg = [];        %  Initialize output

if nargin == 1
    disp(strvcat(' ','Regular Surface Maps',...
	     'MeshGrat       [2 element vector of graticule size] '))
    disp(strvcat(' ','General Surface Maps','Graticule      [lat,lon matrices] '))
    return

elseif nargin < 3 | nargin > 5
    msg = 'Incorrect number of arguments';   return

elseif nargin == 3
    hndl = varargin{1};
    property = 'meshgrat';
	npts     = varargin{3};
	alt      = [];
    indx = strmatch(lower(varargin{2}),property);
    if length(indx) ~= 1
          msg = 'Unrecognized property for Surface Maps';   return
    end

elseif nargin == 4
    hndl = varargin{1};
    validprop = strvcat('meshgrat','graticule');
    indx = strmatch(lower(varargin{2}),validprop);

    if length(indx) ~= 1
          msg = 'Unrecognized property for Surface Maps';   return
    else
	      property = deblank(validprop(indx,:));
	end

    switch property
	    case 'meshgrat',      npts = varargin{3};    alt = varargin{4};
		case 'graticule',     lat  = varargin{3};    lon = varargin{4};
		                      alt  = [];
	end

elseif nargin == 5
    hndl = varargin{1};
    property = 'graticule';
    lat = varargin{3};      lon = varargin{4};   alt = varargin{5};

    indx = strmatch(lower(varargin{2}),property);
    if length(indx) ~= 1
          msg = 'Unrecognized property for Surface Maps';   return
    end

end


%  Make sure that the surface object is projected

if ~ismapped(varargin{1})
    msg = 'Surface object not projected.  Use SET';   return
end

%  Test for a valid maplegend field in the userdata structure
%  Need to hold onto maplegend, to reset the user data properties

maplegend = [];
userdata = get(hndl,'UserData');
mfields = char(fieldnames(userdata));
indx = strmatch('maplegend',mfields,'exact');
if length(indx) == 1;  maplegend = userdata.maplegend;  end


switch property
%*************************************************************
case 'meshgrat'     %  New graticules for a regular matrix map
%*************************************************************

%  Test for a valid maplegend in existance

    if isempty(maplegend)
        msg = 'MESHGRAT property requires maps displayed using MESHM';
		return
    end

%  Test the npts vector

    npts = npts(:);
	if ~isempty(npts) & length(npts) ~= 2
	    msg = 'Two element npts vector must be supplied';  return
	end

%  Get the map and compute the new graticule

    map = get(hndl,'Cdata');
    [lat,lon] = meshgrat(map,userdata.maplegend,npts);

%*********************************************
case 'graticule'     %  General map graticules
%*********************************************

%  Test that the lat and lon graticule matrices are the same size

    if ndims(lat) > 2 | ndims(lon) > 2
         msg = 'Pages not allowed for map graticules';   return
    elseif any(size(lat) ~= size(lon))
         msg = 'Inconsistent graticule matrices';   return
    end
end

%  Test the altitude input

if isempty(alt)
     alt = zeros(size(lat));
elseif max(size(alt)) == 1
     alt = alt(ones(size(lat)));
elseif ndims(alt) > 2 | any(size(lat) ~= size(alt))
     msg = 'Inconsistent graticule and altitude matrices';  return
end

%  Project the new graticule and then
%  set the x and y data properties of the surface object

[x,y,z,savepts] = mfwdtran(lat,lon,alt,'surface');

if ~isempty(maplegend)                        %  Restore the maplegend
    savepts.maplegend = maplegend;            %  property if necessary
end

if isequal(size(x),size(get(hndl,'Cdata')))
     set(hndl,'Xdata',x,'Ydata',y,'Zdata',z,'UserData',savepts,...
	           'FaceColor','flat');
else
     set(hndl,'Xdata',x,'Ydata',y,'Zdata',z,'UserData',savepts,...
	           'FaceColor','texturemap');
end




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function DisplayAxesProperties(PropString)

%  Display the text properties recognized by setm.


%  Define the Map Properties as a 2 column cell array

MapProperties = {
'AngleUnits',     '[ {degrees} | radians | dms | dm ]',
'Aspect',         '[ {normal} | transverse ]',
'FalseEasting'    '',
'FalseNorthing'   '',
'FixedOrient',    'FixedOrient is a read-only property',
'Geoid',          '',
'MapLatLimit',    '',
'MapLonLimit',    '',
'MapParallels',   '',
'MapProjection',  '',
'NParallels',     'NParallels is a read-only property',
'Origin',         '',
'ScaleFactor',    '',
'TrimLat',        'TrimLat is a read-only property',
'TrimLon',        'TrimLon is a read-only property',
'Zone',           '',
'Frame',          '[ on | {off} ]',
'FEdgeColor',     '',
'FFaceColor',     '',
'FFill',          '',
'FLatLimit',      '',
'FLineWidth',     '',
'FLonLimit',      '',
'Grid',           '[ on | {off} ]',
'GAltitude',      '',
'GColor',         '',
'GLineStyle',     '[ - | -- | -. | {:} ]',
'GLineWidth',     '',
'MLineException', '',
'MLineFill',      '',
'MLineLimit',     '',
'MLineLocation',  '',
'MLineVisible',   '[ {on} | off ]',
'PLineException', '',
'PLineFill',      '',
'PLineLimit',     '',
'PLineLocation',  '',
'PLineVisible',   '[ {on} | off ]',
'FontAngle',      '[ {normal} | italic | oblique ]',
'FontColor',      '',
'FontName',       '',
'FontSize',       '',
'FontUnits',      '[ inches | centimeters | normalized | {points} | pixels ]'
'FontWeight',     '[ {normal} | bold ]'
'LabelFormat',    '[ {compass} | signed | none ]'
'LabelRotation',  '[ on | {off} ]',
'LabelUnits',     '[ {degrees} | radians | dms | dm ]',
'MeridianLabel',  '[ on | {off} ]',
'MLabelLocation', '',
'MLabelParallel', '',
'MLabelRound',    '',
'ParallelLabel',  '[ on | {off} ]',
'PLabelLocation', '',
'PLabelMeridian', '',
'PLabelRound',    ''
};


if nargin == 0;    PropString = 'all';   end

%  Display either all the properties, or the inputted property

if strcmp(PropString,'all')
        for i = 1:size(MapProperties,1)
               fprintf('%-25s   %-40s\n',MapProperties{i,1},MapProperties{i,2})
       end
else
       indx = strmatch(lower(PropString),lower(strvcat(MapProperties{:,1})));
       if isempty(indx)
            fprintf('%s\n',['Unrecognized Property String:  ',PropString])
       elseif length(indx) > 1
            fprintf('%s\n','Non-unique Property String.  Supply more characters.')
       elseif isempty(MapProperties{indx,2})
            fprintf('%s\n',...
              ['An axes''s "',MapProperties{indx,1},'" property does not have a fixed set of property values.'])
       else
               fprintf('%-25s   %-40s\n',MapProperties{indx,1},MapProperties{indx,2})
       end

end


%**************************************************************************
%**************************************************************************
%**************************************************************************


function DisplayTextProperties(PropString)

%  Display the text properties recognized by setm.


%  Define the Text Properties as a 2 column cell array

MapProperties = {
'MapPosition',     ''
};


if nargin == 0;    PropString = 'all';   end

%  Display either all the properties, or the inputted property

if strcmp(PropString,'all')
        for i = 1:size(MapProperties,1)
               fprintf('%-25s   %-40s\n',MapProperties{i,1},MapProperties{i,2})
       end
else
       indx = strmatch(lower(PropString),lower(strvcat(MapProperties{:,1})));
       if isempty(indx)
            fprintf('%s\n',['Unrecognized Property String:  ',PropString])
       elseif length(indx) > 1
            fprintf('%s\n','Non-unique Property String.  Supply more characters.')
       elseif isempty(MapProperties{indx,2})
            fprintf('%s\n',...
              ['A text''s "',MapProperties{indx,1},'" property does not have a fixed set of property values.'])
       else
               fprintf('%-25s   %-40s\n',MapProperties{indx,1},MapProperties{indx,2})
       end

end


%**************************************************************************
%**************************************************************************
%**************************************************************************


function DisplaySurfProperties(PropString)

%  Display the surface properties recognized by setm.


%  Define the Surface Propertiess as a 2 column cell array

MapProperties = {
'Graticule',     ''
'MeshGrat',     ''
};


if nargin == 0;    PropString = 'all';   end

%  Display either all the properties, or the inputted property

if strcmp(PropString,'all')
        for i = 1:size(MapProperties,1)
               fprintf('%-25s   %-40s\n',MapProperties{i,1},MapProperties{i,2})
       end
else
       indx = strmatch(lower(PropString),lower(strvcat(MapProperties{:,1})));
       if isempty(indx)
            fprintf('%s\n',['Unrecognized Property String:  ',PropString])
       elseif length(indx) > 1
            fprintf('%s\n','Non-unique Property String.  Supply more characters.')
       elseif isempty(MapProperties{indx,2})
            fprintf('%s\n',...
              ['A surface''s "',MapProperties{indx,1},'" property does not have a fixed set of property values.'])
       else
               fprintf('%-25s   %-40s\n',MapProperties{indx,1},MapProperties{indx,2})
       end

end


%**************************************************************************
%**************************************************************************
%**************************************************************************

%**************************************************************************
%**************************************************************************
%**************************************************************************


function DisplayScaleProperties(PropString)

%  Display the scale ruler properties recognized by setm.


%  Define the Surface Propertiess as a 2 column cell array

MapProperties = {
    'Azimuth',				'',
    'Children',				'Children is a read-only property',
    'Color',				'',
    'FontAngle',			'[ {normal} | italic | oblique ]',
    'FontName',				'',
    'FontSize',				'',
    'FontUnits',			'[ inches | centimeters | normalized | {points} | pixels ]',
    'FontWeight',			'[ light | {normal} | demi | bold ]',
    'Label',				'',
    'Lat',					'',
    'LineWidth',			'',
    'Long',					'',
    'MajorTick',			'',
   	'MajorTickLabel',		'',
    'MajorTickLength',		'',
    'MinorTick',			'',
    'MinorTickLabel',		'',
    'MinorTickLength',		'',
    'Radius',				'',
    'RulerStyle',			'{ruler} | lines | patches ',
    'TickDir',				'[{up} | down]',
    'TickMode',				'[{auto} | manual]',
    'Units',				'[ (valid distance unit strings) ]',
    'XLoc',					'',
    'YLoc',					'', 
    'ZLoc',					'' 
};


if nargin == 0;    PropString = 'all';   end

%  Display either all the properties, or the inputted property

if strcmp(PropString,'all')
        for i = 1:size(MapProperties,1)
               fprintf('%-25s   %-40s\n',MapProperties{i,1},MapProperties{i,2})
       end
else
       indx = strmatch(lower(PropString),lower(strvcat(MapProperties{:,1})));
       if isempty(indx)
            fprintf('%s\n',['Unrecognized Property String:  ',PropString])
       elseif length(indx) > 1
            fprintf('%s\n','Non-unique Property String.  Supply more characters.')
       elseif isempty(MapProperties{indx,2})
            fprintf('%s\n',...
              ['A scale ruler''s "',MapProperties{indx,1},'" property does not have a fixed set of property values.'])
       else
               fprintf('%-25s   %-40s\n',MapProperties{indx,1},MapProperties{indx,2})
       end

end


%**************************************************************************
%**************************************************************************
%**************************************************************************


function msg = setmscale(varargin)

%SETMSCALE  Processes the SETM operations for a scale ruler object
%
%  Note that error conditions are returned in the output argument msg.


msg = [];        %  Initialize output

if mod(nargin,2) == 0
    msg = 'Incorrect number of arguments';   return
end

% Handles of first element of scale ruler

hndl = varargin{1};

% Get the properties structure

s = get(min(hndl),'Userdata');

% Handles of all elements of scale ruler

childtag = s.Children; % Handles of all elements of scale ruler
hchild = findall(gca,'tag',childtag);

%  Define the Surface Propertiess as a 2 column cell array

MapProperties = {
    'Azimuth'
    'Children'
    'Color'
    'FontAngle'
    'FontName'
    'FontSize'
    'FontUnits'
    'FontWeight'
    'Label'
    'Lat'
    'LineWidth'
    'Long'
    'MajorTick'
   	'MajorTickLabel'
    'MajorTickLength'
    'MinorTick'
   	'MinorTickLabel'
    'MinorTickLength'
    'Radius'
    'RulerStyle'
    'TickDir'
    'TickMode'
    'Units'
    'XLoc'
    'YLoc'
    'ZLoc'
};

% Work through property value pairs

for i=1:(nargin-1)/2

%  Make sure that the valid property is supplied

	indx = strmatch(lower(varargin{2}),lower(MapProperties));
	if isempty(indx)
	    msg = 'Unrecognized property for Scaleruler';   return
	elseif length(indx) > 1;
		indx = strmatch(lower(varargin{2}),lower(MapProperties),'exact');
		if length(indx) > 1
			msg = 'Non-unique property string. Supply more characters.'; return
		end
	end
%  Handle special cases

	switch MapProperties{indx}
% 	case 'RulerStyle'
% 		indx = strmatch
	case {'MajorTick','MinorTick'}
		s.TickMode = 'manual';
		s.MajorTickLabel = [];
		s.MinorTickLabel = [];
	case 'Children'
		error('Attempt to modify read-only scaleruler property: ''Children''.')
	end

	% not much error checking yet. This may require cases for each property

% Set the value

	s = setfield(s,MapProperties{indx},varargin{3});

% Clear out the pair and move on to the next

	if length(varargin) >= 5
		varargin = {varargin{1},varargin{4:end}};
	end

end

% fill in defaults for empty fields

s = scaleruler(s,'defaults');

% delete existing scale ruler and redraw with current settings

delete([hndl; hchild(:)]);
h = scaleruler(s,'plot');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function reproQ = reprojectQ(sdiff)

%REPROJECTQ determine if projected objects need to be reprojected

objects = 0; frame = 0; grid = 0; mlabel = 0; plabel = 0; 

% properties which affect projected objects

objectprops = { 
    'mapprojection'
    'zone'
    'angleunits'
    'aspect'
    'geoid'
    'maplatlimit'
    'maplonlimit'
    'flatlimit'
    'flonlimit'
    'mapparallels'
    'origin'
    'falsenorthing'
    'falseeasting'
    'scalefactor'
    'trimlat'
    'trimlon'
	};

reproQ = 0;
for i=1:length(objectprops)
	reproQ = reproQ | getfield(sdiff,objectprops{i});
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sdiff = fielddiff(s1,s2)

% FIELDDIFF compares contents of two structures, puts 1 in the fields that are different
sdiff = 0;
if ~isequal(s1,s2) 
	fields1 = sort(fieldnames(s1));
	fields2 = sort(fieldnames(s2));
	
	if isequal(fields1,fields2)
		
		for i=1:length(fields1)
			
			sdiff = ...
				setfield(sdiff,fields1{i}, ...
								~isequal( ...
									getfield(s1,fields1{i}), ...
									getfield(s2,fields1{i}) ...
									) );
		end
	else
		sdiff = 1;
	end						

end

