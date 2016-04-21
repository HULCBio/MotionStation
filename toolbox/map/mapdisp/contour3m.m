function varargout = contour3m(varargin)
%CONTOUR3M Project a 3D contour plot of data onto the current map axes.
%
%  CONTOUR3M(lat,lon,map) produces a 3D contour plot of map data projected
%  onto the current map axes.  The input latitude and longitude vectors
%  can be the size of map (as in a general matrix map), or can specify the 
%  corresponding row and column dimensions for the map.
%
%  CONTOUR3M(map,maplegend) produces a contour plot of map data in a 
%  regular matrix map.
%
%  CONTOUR3M(lat,lon,map,'LineSpec') uses any valid LineSpec string
%  to draw the contour lines.
%
%  CONTOUR3M(lat,lon,map,'PropertyName',PropertyValue,...) uses the
%  line properties specified to draw the contours.
%
%  CONTOUR3M(lat,lon,map,n,...) draws n contour levels, where n is a scalar.
%
%  CONTOUR3M(lat,lon,map,v,...) draws contours at the levels specified
%  by the input vector v.
%
%  CONTOUR3M(map,maplegend,...) takes any of the optional arguments 
%  described above.
%
%  c = CONTOUR3M(...) returns a standard contour matrix, with the first
%  row representing longitude data and the second row represents
%  latitude data.
%
%  [c,h] = CONTOUR3M(...) returns the contour matrix and the handles
%  to the contour lines drawn.
%
%  lines onto the current map axes.
%
%  See also CONTOURM, CONTOUR, PLOT

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%  $Revision: 1.3.4.1 $    $Date: 2003/08/01 18:18:07 $

if nargin == 0
    contor3mui;   
    switch nargout
      case {0,1}
         varargout{1} = [];
      case 2
         varargout{1} = [];
         varargout{2} = [];
      case 3
         varargout{1} = [];
         varargout{2} = [];
         varargout{3} = [];
    end
    return;
end

% Check input arguments
checknargin(2,inf,nargin,mfilename);
msg = [];  

if all(size(varargin{2}) == [1 3]) % is a maplegend
	map = varargin{1};
   maplegend = varargin{2};
	[lat,lon] = meshgrat(map,maplegend,size(map));
	v   = [];
   varargin(1:2) = [];
else
	lat = varargin{1};    
   lon = varargin{2};
   map = varargin{3};
	v   = [];
   varargin(1:3) = [];	
end

if ~isempty(varargin) & ~ischar(varargin{1})
   v = varargin{1};
   varargin(1) = [];
end
		
%  Adjust the input data to vectors if necessary
if any([ndims(lat) ndims(lon) ndims(map)] > 2)
    msg = 'Lat, lon and map inputs can not have pages';
	if nargout ~= 3;  
      eid = sprintf('%s:%s:invalidInputs', getcomp, mfilename);
      error(eid,'%s',msg);   end
	return
end

if length(lat) == 2 & length(lat) ~= size(map,1)    %  Assume limits of map
    lat = linspace(min(lat),max(lat),size(map,1));
elseif min(size(lat))==1 & length(lat) ~= size(map,1)
    msg = 'Length of lat input must match number of rows in map';
	if nargout ~= 3;  
      eid = sprintf('%s:%s:invalidParams', getcomp, mfilename);
      error(eid,'%s',msg);   
   end
	return
elseif min(size(lat)) ~= 1 & ~isequal(size(lat),size(map))
    msg = 'Lat and Map inputs must be the same size';
	if nargout ~= 3;  
      eid = sprintf('%s:%s:invalidLATandLONInputs', getcomp, mfilename);
      error(eid,'%s',msg);   
   end
	return
end

if length(lon) == 2 & length(lon) ~= size(map,2)    %  Assume limits of map
    lon = linspace(min(lon),max(lon),size(map,2));
elseif min(size(lon))==1 & length(lon) ~= size(map,2)
    msg = 'Length of lon input must match number of columns in map';
	if nargout ~= 3;  
      eid = sprintf('%s:%s:invalidLengths', getcomp, mfilename);
      error(eid,'%s',msg);   
   end
	return
elseif min(size(lon))~=1 & ~isequal(size(lon),size(map))
    msg = 'Lon and Map inputs must be the same size';
	if nargout ~= 3;  
      eid = sprintf('%s:%s:invalidLonAndMapInputs', getcomp, mfilename);
      error(eid,'%s',msg);   
   end
	return
end

%  Save the current color order for the axes

colortab = get(gca,'ColorOrder');
[mc,nc] = size(colortab);


%  Compute the contour levels.  Note that the contour data
%  is returned in the unprojected lat/lon coordinate system.
%  This allows contours to be computed independent of a
%  specific projection.  The downside is that contour can't
%  be used.  It must be replicated somewhat by this function.
%  However, using contour on transformed lat and lon vectors
%  will not produce properly clipped results.  So, this is
%  the required approach to the contouring of map data.

if isempty(v)
    c = contours(lon,lat,map);
else
    c = contours(lon,lat,map,v);
end

%  Erase existing map if NextPlot property is replace

nextmap;

%  Project and plot each contour line

startpt = 1;        h = [];
linecount = 1;      color_h = [];


%  Parse contour matrix

while (startpt < size(c,2))
       z_level = c(1,startpt);
       npoints = c(2,startpt);
	   nextpt   = startpt + npoints + 1;

	   while (nextpt < size(c,2))      %  NaN clip same contour levels
			if (z_level == c(1, nextpt))
				npoints = npoints + c(2,nextpt) + 1;
				c(2,startpt) = npoints;
				c(1,nextpt) = nan;
				c(2,nextpt) = nan;
			else
				break;
			end
			nextpt = startpt+npoints+1;
		end

%  Construct vectors for plotting

        londata = c(1,startpt+1:startpt+npoints);
        latdata = c(2,startpt+1:startpt+npoints);
        zdata = z_level(ones(1,npoints));

% Contours function may return points interpolated across the branch cut.
% Detect two sequential points separated in distance by more than the 
% maximum grid spacing. Remove the interior points of that set of segments

		maxdiff = 3*max(abs(diff(sort(lon(:)))));
		
		units = getm(gca,'AngleUnits');
		legdists = distance(latdata(1:end-1),londata(1:end-1),latdata(2:end),londata(2:end),units);
		ibigsteps = find( legdists > maxdiff );
		
		if any(diff(ibigsteps)) 
			iremove = ibigsteps(find(diff(ibigsteps) == 1)) + 1;
			latdata(iremove) = [];
			londata(iremove) = [];
			zdata(iremove) = [];
		end

%  Add the contour level to the current map

        set(gca,'ColorOrder',colortab(linecount,:))
        if ~isempty(varargin)
		     cu = linem(latdata,londata,zdata,varargin{:},...
			             'Tag',num2str(z_level));
        else
		     cu = linem(latdata,londata,zdata,'Tag',num2str(z_level));
		end

%  Save handles and level data to align colors later

		h = [h; cu(:)];
        color_h = [color_h ; z_level];
        startpt = nextpt;

        linecount = linecount+1;    %  Set the color table line counter
		if linecount > size(colortab,1);    linecount = 1;    end
end

%  Restore the color order to the current axes

set(gca,'ColorOrder',colortab)

%  Determine if it is necessary to apply default colors to the contours

needcolors = 0;
if ~isempty(h)
	firstclr   = get(h(1),'Color');
    if length(h)>1
		for i = 2:length(h)
              currentclr = get(h(i),'Color');
			  if any(firstclr ~= currentclr)
			       needcolors = 1;   break
			  end
		end
	end
end

%  Set linecolors - all LEVEL lines should be same color
%  provided that the user has not already made all lines the
%  same color

if needcolors

% first find number of unique contour levels

    [zlev, ind] = sort(color_h);
    h = h(ind);     % handles are now sorted by level
    ncon = length(find(diff(zlev))) + 1;    % number of unique levels

    if ncon > mc    % more contour levels than colors, so cycle colors
                    % build list of colors with cycling
          ncomp = round(ncon/mc); % number of complete cycles
          remains = ncon - ncomp*mc;
          one_cycle = (1:mc)';
          index = one_cycle(:,ones(1,ncomp));
          index = [index(:); (1:remains)'];
          colortab = colortab(index,:);
    end

    j = 1;    zl = min(zlev);
    for i = 1:length(h)
         if zl < zlev(i)
              j = j + 1;     zl = zlev(i);
         end

         set(h(i),'color',colortab(j,:));
    end

end

%  Set the output arguments
switch nargout
  case {0,1}
     varargout{1} = c;
  case 2
     varargout{1} = c;
     varargout{2} = h;
  case 3
     varargout{1} = c;
     varargout{2} = h;
     varargout{3} = msg;
end



%*************************************************************************
%*************************************************************************
%*************************************************************************

function contor3mui

%  CONTOR3MUI creates the dialog box to allow the user to enter in
%  the variable names for a surfacem command.  It is called when
%  CONTOR3M is executed with no input arguments.


%  Define map for current axes if necessary.  Note that if the
%  user cancels this operation, the display dialog is aborted.

%  Create axes if none found

if isempty(get(get(0,'CurrentFigure'),'CurrentAxes'))
    Btn = questdlg('Create Map Axes in Current Figure?','No Map Axes',...
	                'Yes','No','Yes');
    if strcmp(Btn,'No');    return;   end
	 axes;
end

%  Create map definition if necessary

if ~ismap
     cancelflag = axesm;
     if cancelflag;   clma purge;  return;   end
end

%  Initialize the entries of the dialog box

str1 = 'lat';     str2 = 'long';    str3 = 'map';
str4 = '';        str5 = '';        popvalu = 1;   flag2d = 1;

while 1      %  Loop until no error break or cancel break

    lasterr('')     %  Reset the last error function

%  Display the variable prompt dialog box

	h = Contor3mUIBox(str1,str2,str3,str4,str5,flag2d,popvalu);  uiwait(h.fig)

   if ~ishandle(h.fig);   return;   end

%  If the accept button is pushed, build up the command string and
%  evaluate it in the base workspace.  Delete the modal dialog box
%  before evaluating the command so that the proper axes are used.
%  The proper axes were current before the modal dialog was created.

    if get(h.fig,'CurrentObject') == h.apply
        str1 = get(h.latedit,'String');    %  Get the dialog entries
		str2 = get(h.lonedit,'String');
        str3 = get(h.mapedit,'String');
        str4 = get(h.lvledit,'String');
		str5 = get(h.propedit,'String');
        flag2d = get(h.mode2d,'Value');
		popvalu = get(h.legpopup,'Value');
        delete(h.fig)

%  Make the other property string into a single row vector.
%  Eliminate any padding 0s since they mess up a string

		str5 = str5';   str5 = str5(:)';   str5 = str5(find(str5));

%  Set the 2D or 3D function name

        if flag2d
           fnname = 'contourm(';
	     else
           fnname = 'contour3m(';
        end

%  Set the plot string prefix and suffix based upon the legend option requested

    switch popvalu
	   case 1,     prefix = '';   suffix = '';
	   case 2,     prefix = 'clear ans;[ans.c,ans.h]=';
	               suffix = 'clabelm(ans.c);clear ans';
	   case 3,     prefix = 'clear ans;[ans.c,ans.h]=';
	               suffix = 'clabelm(ans.c,ans.h);clear ans';
	   case 4,     prefix = 'clear ans;[ans.c,ans.h]=';
	               suffix = 'clabelm(ans.c,''manual'');clear ans';
	   case 5,     prefix = 'clear ans;[ans.c,ans.h]=';
	               suffix = 'clabelm(ans.c,ans.h,''manual'');clear ans';
	   case 6,     prefix = 'clear ans;[ans.c,ans.h]=';
	               suffix = 'clegendm(ans.c,ans.h,-1);clear ans';
	end

%  Construct the appropriate plotting string and assemble the callback string

        if isempty(str4) & isempty(str5)
            plotstr = [fnname,str1,',',str2,',',str3,');'];
        elseif isempty(str4) & ~isempty(str5)
            plotstr = [fnname,str1,',',str2,',',str3,',',str5,');'];
        elseif ~isempty(str4) & isempty(str5)
            plotstr = [fnname,str1,',',str2,',',str3,',',str4,');'];
        elseif ~isempty(str4) & ~isempty(str5)
            plotstr = [fnname,str1,',',str2,',',str3,',',str4,',',str5,');'];
        end

	    evalin('base',[prefix plotstr suffix],...
		        'uiwait(errordlg(lasterr,''Map Projection Error'',''modal''))')
		if isempty(lasterr);   break;   end  %  Break loop with no errors
   else
        delete(h.fig)     %  Close the modal dialog box
		break             %  Exit the loop
   end
end


%*************************************************************************
%*************************************************************************
%*************************************************************************

function h = Contor3mUIBox(lat0,lon0,map0,alt0,prop0,flag2d,popvalu)

%  CONTOR3MUIBOX creates the dialog box and places the appropriate
%  objects for the CONTOR3MUI function.


%  Compute the Pixel and Font Scaling Factors so
%  GUI figure windows and fonts look OK across all platforms

PixelFactor = guifactm('pixels');
FontScaling =  guifactm('fonts');

%  Create the dialog box.  Make visible when all objects are drawn

h.fig = dialog('Name','Contour Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 4],...
		   'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  2D/3D Radio Buttons

callback = 'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0);';

h.modelabel = uicontrol(h.fig,'Style','Text','String','Mode:', ...
            'Units','Normalized','Position', [0.05  0.92  0.20  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);
h.mode2d = uicontrol(h.fig,'Style','Radio','String', '2D', ...
            'Units','Normalized','Position', [0.30  .92  0.17  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, 'Value',flag2d,...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Callback',callback);
h.mode3d = uicontrol(h.fig,'Style','Radio','String', '3D', ...
            'Units','Normalized','Position', [0.50  .92  0.17  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, 'Value',~flag2d,...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Callback',callback);

set(h.mode2d,'UserData',h.mode3d);     %  Set the user data so that the radio callback
set(h.mode3d,'UserData',h.mode2d);     %  functions to make buttons exclusive

%  Map Limit Button

h.limitm = uicontrol(h.fig,'Style','Push','String', 'MLimit', ...
	        'Units', 'Normalized','Position', [0.74  0.92  0.24  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'center', 'Interruptible','on',...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
         'CallBack','limitm;');

%  Latitude Text and Edit Box

h.latlabel = uicontrol(h.fig,'Style','Text','String','Latitude variable:', ...
            'Units','Normalized','Position', [0.05  0.853  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left',...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latedit = uicontrol(h.fig,'Style','Edit','String', lat0, ...
            'Units','Normalized','Position', [0.05  .78  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.latlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .78  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.latedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Longitude Text and Edit Box

h.lonlabel = uicontrol(h.fig,'Style','Text','String','Longitude variable:', ...
            'Units','Normalized','Position', [0.05  0.713  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonedit = uicontrol(h.fig,'Style','Edit','String', lon0, ...
            'Units','Normalized','Position', [0.05  .64  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lonlist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .64  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lonedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Map Text and Edit Box

h.maplabel = uicontrol(h.fig,'Style','Text','String','Map variable:', ...
            'Units','Normalized','Position', [0.05  0.573  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.mapedit = uicontrol(h.fig,'Style','Edit','String', map0, ...
            'Units','Normalized','Position', [0.05  .50  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.maplist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .50  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.mapedit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Levels Text and Edit Box

h.lvllabel = uicontrol(h.fig,'Style','Text','String','Level variable (optional):', ...
            'Units','Normalized','Position', [0.05  0.433  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lvledit = uicontrol(h.fig,'Style','Edit','String', alt0, ...
            'Units','Normalized','Position', [0.05  .36  0.70  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.lvllist = uicontrol(h.fig,'Style','Push','String', 'List', ...
            'Units','Normalized','Position', [0.77  .36  0.18  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*9, ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'Interruptible','on', 'UserData',h.lvledit,...
			'CallBack','varpick(who,get(gco,''UserData''))');

%  Legend Text and Popup Menu

h.leglabel = uicontrol(h.fig,'Style','Text','String','Legend:', ...
            'Units','Normalized','Position', [0.05  0.29  0.25  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.legpopup = uicontrol(h.fig,'Style','Popup',...
            'String', ['None|Label Above|Label Inline|Label Above Manual|',...
			           'Label Inline Manual|Plot Legend'], ...
            'Units','Normalized','Position', [0.35  .28  0.60  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Value',popvalu,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Other Properties Text and Edit Box

h.proplabel = uicontrol(h.fig,'Style','Text','String','Other Properties:', ...
            'Units','Normalized','Position', [0.05  0.214  0.90  0.06], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', ...
			'ForegroundColor', 'black','BackgroundColor', figclr);

h.propedit = uicontrol(h.fig,'Style','Edit','String', prop0, ...
            'Units','Normalized','Position', [0.05  .10  0.90  0.11], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'left', 'Max',2,...
			'ForegroundColor', 'black','BackgroundColor', figclr);

%  Buttons to exit the modal dialog

h.apply = uicontrol(h.fig,'Style','Push','String', 'Apply', ...
	        'Units', 'Normalized','Position', [0.06  0.01  0.26  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'center',...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','uiresume');

h.help = uicontrol(h.fig,'Style','Push','String', 'Help', ...
	        'Units', 'Normalized','Position', [0.37  0.01  0.26  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10,...
			'HorizontalAlignment', 'center', 'Interruptible','on',...
			'ForegroundColor', 'black', 'BackgroundColor', figclr,...
			'CallBack','maphlp1(''initialize'',''contor3mui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
	        'Units', 'Normalized','Position', [0.68  0.01  0.26  0.07], ...
			'FontWeight','bold',  'FontSize',FontScaling*10, ...
			'HorizontalAlignment', 'center', ...
			'ForegroundColor', 'black','BackgroundColor', figclr,...
			'CallBack','uiresume');

set(h.fig,'Visible','on','UserData',h);
