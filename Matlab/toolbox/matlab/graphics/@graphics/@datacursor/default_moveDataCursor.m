function default_moveDataCursor(hThis,hgObject,hDataCursor,dir)
% Specifies datamarker position behavior when user selects arrows 
% keys (up,down,left,right).

% Copyright 2002-2003 The MathWorks, Inc.

% Bail out if invalid index
currind = hDataCursor.DataIndex;
if isempty(currind)
  return;
end

if isa(hgObject,'hg.surface')
   local_Surface_moveDatamarker(hThis,hgObject,hDataCursor,dir);  
elseif isa(hgObject,'hg.patch')
   local_Patch_moveDatamarker(hThis,hgObject,hDataCursor,dir);
elseif isa(hgObject,'hg.line')
   local_Line_moveDatamarker(hThis,hgObject,hDataCursor,dir); 
elseif isa(hgObject,'hg.image')
   local_Image_moveDatamarker(hThis,hgObject,hDataCursor,dir);
elseif isa(hgObject,'hg.rectangle') | ...
     isa(hgObject,'hg.text') | ...
     isa(hgObject, 'hg.axes') | ...
     isa(hgObject, 'hg.group')
    % do nothing
else
    % do nothing
end

%-----------------------------------------------%
function local_Line_moveDatamarker(hThis,hLine,hDataCursor,dir)

currind = hDataCursor.DataIndex;
hAxes = ancestor(hLine,'hg.axes');

xdata = get(hLine,'xdata');
ydata = get(hLine,'ydata');
len = length(xdata);
currind = hDataCursor.DataIndex;
if strcmp(dir,'up') | strcmp(dir,'right')
   if currind < len
      currind = currind + 1;
   end
else
   if currind > 1
      currind = currind - 1;
   end
end
  
% Updata vertex position
hDataCursor.DataIndex = currind;
if is2D(hAxes)
   hDataCursor.Position = [xdata(currind),ydata(currind)];
else
   zdata = get(hLine,'zdata');
   hDataCursor.Position = [xdata(currind),ydata(currind),zdata(currind)];
end

%-----------------------------------------------%
function local_Surface_moveDatamarker(hThis,hSurface,hDataCursor,dir)

currind = hDataCursor.DataIndex;
hAxes = ancestor(hSurface,'hg.axes');

fv = surf2patch(hSurface);
width = size(get(hSurface,'zdata'),2);
len = length(fv.vertices);
newind = currind;
if strcmpi(dir,'up') 
   if currind < len
      newind = currind + 1;
   end
elseif strcmpi(dir,'right')
   newind = currind + width; 
   if newind > len
       newind = mod(currind,width);
   end
elseif strcmpi(dir,'left')
   newind = currind - width;  
   if newind < 0
       newind = len - mod(currind,width);
   end
elseif strcmpi(dir,'down')
   if currind > 1
      newind = currind - 1;
   end
end

% Updata vertex position
if newind > 0
   hDataCursor.DataIndex = newind;
   pos = fv.vertices(newind,:);
   if is2D(hAxes)
      hDataCursor.Position = [pos(1),pos(2)];
   else
      hDataCursor.Position = [pos(1),pos(2),pos(3)];
   end
end

%-----------------------------------------------%
function local_Patch_moveDatamarker(hThis,hPatch,hDataCursor,dir)

ind = hDataCursor.DataIndex;
hAxes = ancestor(hPatch,'hg.axes');

verts = get(hPatch,'Vertices');
len = length(verts);
if strcmp(dir,'up') | strcmp(dir,'right')
   if ind < len
      ind = ind + 1;
   end
else
   if ind > 1
      ind = ind - 1;
   end
end

% Updata vertex position
pos = verts(ind,:);
if is2D(hAxes) | length(pos) < 3
   pos = [pos(1),pos(2)];
else
   pos = [pos(1),pos(2),pos(3)];
end
hDataCursor.Position = pos;
hDataCursor.DataIndex = ind;


%-----------------------------------------------%
function local_Image_moveDatamarker(hThis,hImage,hDataCursor,dir)

hAxes = ancestor(hImage,'hg.axes');
currind = hDataCursor.DataIndex;
if isempty(currind)
  return;
end

row_ind = currind(1);
col_ind = currind(2);
cdata = get(hImage,'cdata');
width = size(cdata,1);
height = size(cdata,2);

% Flip direction if the y-axis is reversed
if strcmpi(get(hAxes,'ydir'),'reverse')
   if strcmp(dir,'up')
       dir = 'down';
   elseif strcmp(dir,'down')
       dir = 'up';
   end
end

% Flip direction if the x-axis is reversed
if strcmpi(get(hAxes,'xdir'),'reverse')
   if strcmp(dir,'left')
       dir = 'right';
   elseif strcmp(dir,'right')
       dir = 'left';
   end
end

if strcmp(dir,'right') 
   if row_ind < height
      row_ind = row_ind + 1;
   end
elseif strcmp(dir,'left')
   if row_ind > 1
     row_ind = row_ind - 1;
   end
elseif strcmp(dir,'up')
   if col_ind < width
      col_ind = col_ind + 1;
   end
elseif strcmp(dir,'down')
   if col_ind > 1
      col_ind = col_ind - 1;
   end
end

viout = [row_ind,col_ind];

% Get image dimensions
xdata = get(hImage,'xdata');
ydata = get(hImage,'ydata');
cdata = get(hImage,'cdata');

% Determine vout based on viout
if size(cdata,2) > 1
   width_x = (xdata(end)-xdata(1)) / (size(cdata,2)-1);
else
   width_x = xdata(end) - xdata(1);   
end
if size(cdata,1) > 1
   width_y = (ydata(end)-ydata(1)) / (size(cdata,1)-1);
else
   width_y = ydata(end) - ydata(1);   
end
vout(1) = width_x*(viout(1)-1)+xdata(1);
vout(2) = width_y*(viout(2)-1)+ydata(1);

hDataCursor.Position = vout;
hDataCursor.DataIndex = viout;

