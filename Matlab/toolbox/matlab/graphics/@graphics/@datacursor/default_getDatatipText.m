function [str] = default_getDatatipText(hThis,hgObject,hDataCursor)
% Determine default datatip text labels for hg primitives

%   Copyright 1984-2004 The MathWorks, Inc. 

str = [];

if isempty(hDataCursor.Position)
  return;
end

if isa(hgObject,'hg.patch') | ...
   isa(hgObject,'hg.line') | ...
   isa(hgObject,'hg.surface')
   str = local_Geometry_getDatatipText(hgObject,hDataCursor);
elseif isa(hgObject,'hg.image')
   str = local_Image_getDatatipText(hgObject,hDataCursor);
elseif isa(hgObject,'hg.rectangle') | ...
     isa(hgObject,'hg.text') | ...
     isa(hgObject, 'hg.axes') | ...
     isa(hgObject, 'hg.group')
    % do nothing
else
    % do nothing
end

%-----------------------------------------------%
function [str] = local_Geometry_getDatatipText(hgObject,hDataCursor)
% Determine datatip string that appears for a patch, surface, or line

DEFAULT_DIGITS = 4;  % Display 4 digits of x,y position
str = [];
pos = hDataCursor.Position;
hAxes = ancestor(hgObject,'hg.axes');

if isempty(pos) 
  return;
end

if length(pos) == 1
  str = sprintf('%s',num2str(p(1)),5);
elseif is2D(hAxes) | length(pos)==2
   x = num2str(pos(1),DEFAULT_DIGITS);
   y = num2str(pos(2),DEFAULT_DIGITS);
   str = sprintf('X: %s\nY: %s',x,y);
elseif length(pos)==3
   x = num2str(pos(1),DEFAULT_DIGITS);
   y = num2str(pos(2),DEFAULT_DIGITS);
   z = num2str(pos(3),DEFAULT_DIGITS);
   str = sprintf('X: %s\nY: %s\nZ: %s',x,y,z);
end

%-----------------------------------------------%
function [str] = local_Image_getDatatipText(hImage,hDataCursor)
% Determine string for image datatip
% The string will vary depending on the image type, see comments below

DEFAULT_DIGITS = 4;  % Display 4 digits of x,y position

% Get required information
str = [];
ind = get(hDataCursor,'DataIndex');
pos = get(hDataCursor,'Position');
cdata = get(hImage,'cdata');
xdata = get(hImage, 'XData');
ydata = get(hImage, 'YData');

cdatamapping = get(hImage, 'CDataMapping');
hAxes = ancestor(hImage,'axes');
hFigure = ancestor(hAxes,'figure');
fig_colormap = get(hFigure,'Colormap');

if isempty(ind)
  return;
end

row_index = ind(1); 
column_index = ind(2);

% Datacursor code should ensure that the data index is within cdata bounds
if row_index > size(cdata,2) || column_index > size(cdata,1)
   return; 
end

% Convert numeric x,y to string representation
x_str = num2str(pos(1),DEFAULT_DIGITS);
y_str = num2str(pos(2),DEFAULT_DIGITS);
    
% If it's an RGB Image, display RGB information
if ((ndims(cdata) == 3) && (size(cdata,3) == 3))
    pixel = cdata(column_index,row_index,:);
    pixel_str = local_pixel_to_string(pixel);
    str = sprintf('X: %s Y: %s\nRGB: %s, %s, %s', ...
                       x_str,y_str,pixel_str{1},pixel_str{2},pixel_str{3});
    
% If it's an image using the figure's colormap    
else 
     raw_cdata_value = cdata(column_index,row_index);
     
     % Non-double types are 0 based 
     if isa(raw_cdata_value,'double')
         cdata_value = raw_cdata_value;
     elseif isa(raw_cdata_value,'logical')
         cdata_value = raw_cdata_value;
     else
         cdata_value = double(raw_cdata_value) + 1;
     end  

    index_str = num2str(raw_cdata_value,DEFAULT_DIGITS);
        
    % If it's a direct indexed image
    if (strcmpi(cdatamapping,'direct')) 
        % Handle Graphics renderer truncates, so do the same here 
        colormap_index = floor(cdata_value);
        pixel = local_get_colormap_value(fig_colormap,colormap_index);
        pixel_str = local_pixel_to_string(pixel);
        str = sprintf('X: %s Y: %s\nIndex: %s\nRGB: %s, %s, %s', ...
                       x_str,y_str,index_str,pixel_str{1},pixel_str{2},pixel_str{3});
    
   % else it's a scaled indexed image               
    else 
        clim = get(hAxes, 'CLim');
        cdata_min = double(min(cdata(:)));
        cdata_max = double(max(cdata(:)));
        diff = cdata_max-cdata_min;
        cdata_value = double(cdata_value);
        
        % Avoid divide by zero
        if diff~=0
             colormap_index = (((cdata_value-cdata_min)/diff)*length(fig_colormap))+1;
             % Handle Graphics renderer truncates, so do the same here 
             colormap_index = floor(colormap_index);
        else
             colormap_index = 1;
        end

        pixel = local_get_colormap_value(fig_colormap,colormap_index);
        pixel_str = local_pixel_to_string(pixel);
        str = sprintf('X: %s Y: %s\nIndex: %s\nRGB: %s, %s, %s', ...
                       x_str,y_str,index_str,pixel_str{1},pixel_str{2},pixel_str{3});

     end
end

%-----------------------------------------------%
function [pixel_str] = local_pixel_to_string(pixel)

RGB_DIGITS = 3;  % Display 3 digits of RGB 
pixel_str{1} = num2str(pixel(1),RGB_DIGITS);
pixel_str{2} = num2str(pixel(2),RGB_DIGITS);
pixel_str{3} = num2str(pixel(3),RGB_DIGITS);
        
%-----------------------------------------------%
function [pixel] = local_get_colormap_value(fig_colormap,idx)

% Get pixel R,G,B

if (idx<=0)
   pixel = fig_colormap(1,:);
elseif (idx<=size(fig_colormap,1) & idx>0)
   pixel = fig_colormap(idx,:);
else
   pixel = fig_colormap(end,:);
end