function varargout = contourfm(varargin)
%CONTOURFM  Filled contour map.
%
%  CONTOURFM(lat,lon,map) produces a contour plot of map data projected
%  onto the current map axes.  The input latitude and longitude vectors
%  can be the size of map (as in a general matrix map), or can specify the 
%  corresponding row and column dimensions for the map.
%
%  CONTOURFM(map,maplegend) produces a contour plot of map data in a 
%  regular matrix map.
%
%  CONTOURFM(lat,lon,map,'LineSpec') uses any valid LineSpec string
%  to draw the contour lines.
%
%  CONTOURFM(lat,lon,map,'PropertyName',PropertyValue,...) uses the
%  line properties specified to draw the contours.
%
%  CONTOURFM(lat,lon,map,n,...) draws n contour levels, where n is a scalar.
%
%  CONTOURFM(lat,lon,map,v,...) draws contours at the levels specified
%  by the input vector v.
%
%  CONTOURFM(map,maplegend,...) takes any of the optional arguments 
%  described above.
%
%  c = CONTOURFM(...) returns a standard contour matrix, with the first
%  row representing longitude data and the second row represents
%  latitude data.
%
%  [c,h] = CONTOURFM(...) returns the contour matrix and the handles
%  to the contour lines drawn.
%
%  CONTOURFM, without any inputs, will activate a GUI to project contour
%  lines onto the current map axes.
%
%  See also CONTOURM, CONTOUR3M.

%  Copyright 1996-2003 The MathWorks, Inc.
%  Written by:  W. Stumpf
%  $Revision: 1.8.4.2 $ $Date: 2003/08/01 18:18:09 $

msg = nargoutchk(0,2,nargout);
if (~isempty(msg))
    eid = sprintf('%s:%s:tooManyOutputs', getcomp, mfilename);
    error(eid, '%s', msg)
end

if nargin == 0
    contor3mui;
    if nargout > 1
      varargout{nargout} = [];
    else
      varargout{1} = [];
    end
    return
else
    checknargin(2,inf,nargin,mfilename);
end

%  Test for a map axes
[mstruct,msg] = gcm;
if ~isempty(msg)
    eid = sprintf('%s:%s:invalidGCM', getcomp, mfilename);
    error(eid,'%s',eid,'%s',msg)
end

% construct the graticule if needed
nargin0 = nargin;
params = varargin;
if isequal(size(varargin{2}),[1 3]) % map, maplegend calling form
    map = varargin{1};
    maplegend = varargin{2};
    [lat,lon] = meshgrat(map,maplegend,size(map));
    params = {lat,lon,map,varargin{3:end}};
    nargin0 = nargin+1;
end

lat = params{1};
lon = params{2};
map = params{3};
if nargin0 > 3 & isnumeric(params{4}) & length(params{4})>1;
    v = params{4}; % contour levels
else
    v = [];
end

%  Adjust the input data to vectors if necessary
if any([ndims(lat) ndims(lon) ndims(map)] > 2)
    msg = 'Lat, lon and map inputs can not have pages';
    eid = sprintf('%s:%s:invalidParam', getcomp, mfilename);
    error(eid,'%s',msg);   
end

if length(lat) == 2 & length(lat) ~= size(map,1) & ...
    length(lon) == 2 & length(lon) ~= size(map,2)     %  Assume limits of map
    [lat,lon] = meshgrat(lat,lon,size(map));
    params{1} = lat;
    params{2} = lon;

elseif min(size(lat))==1 & length(lat) ~= size(map,1)
    msg = 'Length of lat input must match number of rows in map';
    eid = sprintf('%s:%s:invalidLatLength', getcomp, mfilename);
    error(eid,'%s',msg);   

elseif min(size(lat)) ~= 1 & ~isequal(size(lat),size(map))
    msg = 'Lat and Map inputs must be the same size';
    eid = sprintf('%s:%s:invalidLatSize', getcomp, mfilename);
    error(eid,'%s',msg);   

elseif min(size(lon))==1 & length(lon) ~= size(map,2)
    msg = 'Length of lon input must match number of columns in map';
    eid = sprintf('%s:%s:invalidLonLength', getcomp, mfilename);
    error(eid,'%s',msg);   

elseif min(size(lon))~=1 & ~isequal(size(lon),size(map))
    msg = 'Lon and Map inputs must be the same size';
    eid = sprintf('%s:%s:invalidLonSize', getcomp, mfilename);
    error(eid,'%s',msg);   
end


% initialize the map frame if neccesary. Do this to avoid odd
% display problems when frame is added.

hframe = handlem('Frame');
if isempty(hframe);
   hframe = framem;
   set(hframe,'Visible','off')
end

% Create the filled contours using MATLAB's CONTOURF.
% Call as CONTOURF(lon,lat,map,...). This gets lat and long in the 
% corret row of the contour matrix.

params{1} = lon;
params{2} = lat;

if ~isempty(findstr(version,'R14'))
   [c,h] = contourf('v6', params{:});
else
   [c,h] = contourf(params{:});
end

% CONTOURF spreads the patches out a bit, which can result in
% patches extending around the world a bit more than once. This can lead 
% to incorrect filling when projected, so trim the CONTOURF patches down to
% the original data limits
squashpatch(h,lat,lon)

% Compute the areas of the patches in unprojected coordinates.
% We'll need these below to color the frame properly
area0 = cartarea(h);

% Project the data
project(h)

% Tag it
tagm(h,'Cpatches')

% Hide seams in data, like through Africa in topo
set(h,'edgecolor','none') 


% Adding the frame messes up the color mapping/stacking. This
% is apparently a renderer bug in a particular branch of TMW code.
% Ensure that patches are stacked correctly by changing the 
% zdata after the projection is applied. This stacking order may 
% not be correct if the projection is changes. Stacking is based 
% on area in projected coordinates.

area1 = cartarea(h);
zdatam(h,h-max(h));

% Azimuthal projections may fail to fill properly for the same reason
% that antarctica may fail to fill properly in a north polar polar
% projection. The patch may transform to a ribbon along the edge of
% the map. Without an artificial cut out to the outside, the 
% inside and outside can be reversed.


% Adjust the frame. 
framez = get(hframe,'ZData');
newz = min( min(framez), min(min(h-max(h))-1) );
zdatam(hframe,newz)

% Assign the output arguments
if nargout >= 1; varargout{1} = c; end
if nargout == 2; varargout{2} = h; end

   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function area = cartarea(h)
%CARTAREA computes area of patches in projected coordinates

% code chunk from contourf.m

area = zeros(size(h)); % preallocate memory

for i=1:length(h)
    vertices = get(h(i),'Vertices') ;
    xp = vertices(:,1);
    yp = vertices(:,2);
      
    xp = [NaN; xp ; NaN]; 
    yp = [NaN; yp; NaN];
    [xp,yp] = singleNaN(xp,yp);
      
    segpos = find(isnan(xp) & isnan(yp));
    nseg = length(segpos)-1;

    for j=1:nseg
         % extract face vertices
         xseg = xp(segpos(j)+1:segpos(j+1)-1);
         yseg = yp(segpos(j)+1:segpos(j+1)-1);

         nl = length(xseg);
         % formula from contourf
         area(i) = area(i) + abs(sum( diff(xseg).*(yseg(1:nl-1)+yseg(2:nl))/2 )); 
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lat,lon] = singleNaN(lat,lon)

% SINGLENAN removes duplicate nans in lat-long vectors

if ~isempty(lat)
    nanloc = isnan(lat);   
    [r,c] = size(nanloc);
    nanloc = find(nanloc(1:r-1,:) & nanloc(2:r,:));
    lat(nanloc) = [];  
    lon(nanloc) = [];
end
%*************************************************************************
%*************************************************************************
%*************************************************************************
function squashpatch(h,lat,lon)
%SQUASHPATCH pushes edges of contourf patches back to within the original limits of data

[bottom,top,left,right] = deal( ...
    min(lat(:)), max(lat(:)), min(lon(:)), max(lon(:)) ...
    );
    

for i=1:length(h)
    
    vertices = get(h(i),'Vertices');
    patchlon = vertices(:,1);
    patchlat = vertices(:,2);
    
    %  Points off the left
    
    indx = find( patchlon < left );
    if ~isempty(indx);  patchlon(indx) = left;     end
    
    %  Points off the right
    
    indx = find( patchlon > right );
    if ~isempty(indx);   patchlon(indx) = right;   end
    
    %  Points off the bottom
    
    indx = find( patchlat < bottom );
    if ~isempty(indx);   patchlat(indx) = bottom;     end
    
    %  Points off the top
    
    indx = find( patchlat > top );
    if ~isempty(indx);   patchlat(indx) = top;      end
    
    
    vertices(:,1) = patchlon;
    vertices(:,2) = patchlat;
    set(h(i),'Vertices',vertices);
    
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
%         flag2d = get(h.mode2d,'Value');
      popvalu = get(h.legpopup,'Value');
        delete(h.fig)

%  Make the other property string into a single row vector.
%  Eliminate any padding 0s since they mess up a string

      str5 = str5';   str5 = str5(:)';   str5 = str5(find(str5));

%  Set the 2D or 3D function name

%         if flag2d;    fnname = 'contorm(';
%           else;      fnname = 'contor3m(';
%         end

   fnname = 'contourfm(';

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

h.fig = dialog('Name','Filled Contour Map Input',...
           'Units','Points',  'Position',PixelFactor*72*[2 1 3 4],...
         'Visible','off');
colordef(h.fig,'white');
figclr = get(h.fig,'Color');

% shift window if it comes up partly offscreen

shiftwin(h.fig)

%  2D/3D Radio Buttons

% callback = 'set(gco,''Value'',1);set(get(gco,''UserData''),''Value'',0);';
% 
% h.modelabel = uicontrol(h.fig,'Style','Text','String','Mode:', ...
%             'Units','Normalized','Position', [0.05  0.92  0.20  0.06], ...
%          'FontWeight','bold',  'FontSize',FontScaling*10, ...
%          'HorizontalAlignment', 'left',...
%          'ForegroundColor', 'black','BackgroundColor', figclr);
% h.mode2d = uicontrol(h.fig,'Style','Radio','String', '2D', ...
%             'Units','Normalized','Position', [0.30  .92  0.17  0.06], ...
%          'FontWeight','bold',  'FontSize',FontScaling*10, 'Value',flag2d,...
%          'HorizontalAlignment', 'left', ...
%          'ForegroundColor', 'black','BackgroundColor', figclr,...
%          'Callback',callback);
% h.mode3d = uicontrol(h.fig,'Style','Radio','String', '3D', ...
%             'Units','Normalized','Position', [0.50  .92  0.17  0.06], ...
%          'FontWeight','bold',  'FontSize',FontScaling*10, 'Value',~flag2d,...
%          'HorizontalAlignment', 'left', ...
%          'ForegroundColor', 'black','BackgroundColor', figclr,...
%          'Callback',callback);
% 
% set(h.mode2d,'UserData',h.mode3d);     %  Set the user data so that the radio callback
% set(h.mode3d,'UserData',h.mode2d);     %  functions to make buttons exclusive

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
         'CallBack','maphlp1(''initialize'',''contourfmui'')');

h.cancel = uicontrol(h.fig,'Style','Push','String', 'Cancel', ...
           'Units', 'Normalized','Position', [0.68  0.01  0.26  0.07], ...
         'FontWeight','bold',  'FontSize',FontScaling*10, ...
         'HorizontalAlignment', 'center', ...
         'ForegroundColor', 'black','BackgroundColor', figclr,...
         'CallBack','uiresume');


set(h.fig,'Visible','on','UserData',h)
