function H = imview(varargin)
%IMVIEW Display image in the image viewer.
%   IMVIEW(I) displays the intensity image I.
%
%   IMVIEW(RGB) displays the truecolor image RGB.
%
%   IMVIEW(X,MAP) displays the indexed image X with colormap MAP.
%
%   IMVIEW(I,RANGE), where RANGE is a two-element vector [LOW HIGH],
%   controls the black-to-white range in the displayed image.  The value
%   LOW (and any value less than LOW) displays as black, the value HIGH (and
%   any value greater than HIGH) displays as white, and values in between
%   display as intermediate shades of gray.  RANGE can also be empty
%   ([]), in which case IMVIEW displays the minimum value of I as black
%   and the maximum value of I as white.  In other words, IMVIEW(I,[]) is
%   equivalent to IMVIEW(I,[min(I(:)) max(I(:))]).
%
%   IMVIEW(FILENAME) displays the image contained in the file specified
%   by FILENAME.  The file must contain an image that can be read by
%   IMREAD.  If the file contains multiple images, the first one will be
%   displayed.
%
%   With no input arguments, IMVIEW displays a file chooser dialog so you
%   can select an image file interactively.
%
%   H = IMVIEW(...) returns a handle H to the tool. CLOSE(H) closes the
%   image viewer.
%
%   IMVIEW CLOSE ALL closes all image viewers.
%
%   IMVIEW(...,'InitialMagnification',INITIAL_MAG), where INITIAL_MAG 
%   can be either 100 or 'fit', controls the initial magnification used
%   to display the image. When INITIAL_MAG is set to 100, the image is 
%   displayed at 100% magnification. When it is set to 'fit', the entire 
%   image is scaled to fit in the viewer window.  By default, the 
%   initial magnification is set to the value returned by 
%   IPTGETPREF('ImviewInitialMagnification').
%
%   Class Support
%   -------------
%   The input image can be of class logical, uint8, uint16, int16, or double.
%
%   Examples
%   --------
%       imview('board.tif')
%       [X,map] = imread('trees.tif');
%       imview(X,map)
%       I = imread('cameraman.tif');
%       imview(I)
%
%       h = imview(I,[0 80]);
%       close(h)
%
%   Notes on Managing Multiple Image Viewer Windows
%   -----------------------------------------------
%   If you have multiple Image Viewer windows open and you want to close
%   all of them, there are two ways to do it:
%
%   1. Use the command: IMVIEW CLOSE ALL
%
%   2. Go to the Window menu on the MATLAB Desktop and choose "Close All." 
%      Note, this will close all windows listed in the Window menu, 
%      not just Image Viewer windows.
%  
%   You can also use the Window menu to navigate to a particular Image
%   Viewer that you have open.
%
%   Notes on Memory Usage
%   ---------------------
%   To increase the amount of memory available to IMVIEW, you must put a
%   file called 'java.opts' in your startup directory. By default, MATLAB
%   gives the Java Virtual Machine 64 MB.
%
%   The java.opts file should contain a line like this one which gives the
%   Java Virtual Machine 128 MB:
%
%       -Xmx128m
%
%   To avoid virtual memory "thrashing" set the -Xmx option to no more
%   than 66% real RAM.
%
%   On unix systems, create the java.opts file in a directory where you 
%   will start MATLAB. cd to that directory before starting MATLAB.
%
%   On Windows systems, create the java.opts file in a directory where
%   you wish to start MATLAB. Create a shortcut to MATLAB. Right click on
%   the shortcut, select Properties, change the startup directory to be
%   the one where you put your java.opts file. 
%
%   The MATLAB desktop and IMVIEW share Java Virtual Machine memory. If
%   you are having trouble viewing large images, consider running MATLAB
%   in -nodesktop mode which should allow you to use IMVIEW to view more
%   large images.     
%
%   See also IMREAD, IMSHOW, IPTGETPREF, IPTSETPREF.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 1.1.6.12 $ $Date: 2003/08/23 05:52:47 $

if (nargout > 0)
  H = []; % initialize to null, in case user aborts midstream
end

% Parse and Check Inputs
[filename, user_canceled, close_all, img, map, ...
 display_range, initial_mag, num_imview_specific_args] = ...
    ParseInputs(varargin{:});

% Call imshow on platforms with incomplete Java support.
if ~IsJavaAvailable
  
  if close_all
    return
  end
  
  wid = sprintf('Images:%s:imviewNotAvailableOnThisPlatform',mfilename);
  warning(wid,'%s\n%s',...
          'IMVIEW is not available on this platform.', ...
          'Calling IMSHOW instead.');
  
  try
    num_imshow_args = nargin - num_imview_specific_args;
    hh = figure;
    imshow(varargin{1:num_imshow_args});
    if (nargout > 0)
      % Only return handle if caller requested it.
      H = hh;
    end

  catch
    % in case of an error, close the figure
    close(hh)
    rethrow(lasterror);
  end
  
  return
end

% import Java classes used here
import com.mathworks.toolbox.images.ImageFrame;

if close_all
  ImageFrame.closeAll;
  return;
end

if user_canceled 
  return;
end

checkinput(img, {'uint8', 'uint16', 'int16', 'double', 'logical'}, ...
           {'real', 'nonsparse', 'nonempty'}, ...
           mfilename, 'I or X or RGB', 1);
if ~isempty(map)
  checkmap(map, mfilename, 'MAP', 2);
end

input_variable_name = '';
if nargin >= 1
  input_variable_name = inputname(1);
end
image_name = GetImageName(filename, input_variable_name);

image_type = GetImageType(img, map);

img = CheckForNaNs(img, image_type);

metadata = GetMetadata(filename);

[img_min img_max] = GetFiniteRange(img);

if strcmp(display_range, 'autoscale')
  display_range = [img_min img_max];
  
elseif isempty(display_range)
  display_range = GetDefaultDisplayRange(img, map, image_type);
end

all_integers = false;
if isa(img,'double') % only use all_integers flag for double images
  contains_only_integers = all(floor(img(:))==img(:));
  fits_in_uint16 = (img_max - img_min <= 65535);
  if fits_in_uint16 && contains_only_integers 
    all_integers = true;
  end
end

if ~strcmp(image_type, 'truecolor')
  [X,map,image_scale_range] = MakeIndexedDisplayImage(img,map,display_range,...
                                                    img_min,img_max,...
                                                    all_integers);
  java2d_image = im2java2d(X,map);
else
  image_scale_range = GetDefaultRange(class(img));
  java2d_image = im2java2d(img);
end

imview_image = MakeImviewImage(img, image_name, image_type, ...
                               display_range, image_scale_range, ...
                               metadata, img_min, img_max,...
                               all_integers, initial_mag);

% Create the Image Viewer
hh = ImageFrame(java2d_image, imview_image);

if (nargout > 0)
  % Only return handle if caller requested it.
  H = hh;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [img_min, img_max] = GetFiniteRange(img)


minmax = double([min(img(:)) max(img(:))]);

if isa(img,'double')
  if any(isinf(img(:)))
    % img contains infs
    img2 = img(isfinite(img));
    if ~isempty(img2)
      minmax = [min(img2(:)) max(img2(:))];
    else
      % img has no finite values
      wid = sprintf('Images:%s:allInfs',mfilename);
      warning(wid,'%s','Image contains no finite values.');
      minmax = [0 1];
    end
  end
end

img_min = minmax(1);
img_max = minmax(2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function image_name = GetImageName(filename, input_variable_name)

if isempty(filename)
  if isempty(input_variable_name)
    image_name = 'MATLAB expression';
  else
    image_name = input_variable_name;
  end
else
  [path,image_name] = fileparts(filename);  %#ok
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function image_type = GetImageType(img, map)

if ~isempty(map)
    if (ndims(img) ~= 2)
        eid = sprintf('Images:%s:indexedImageDim',mfilename);
        error(eid,'%s','Input image must be 2-D or M-by-N-by-3.');
    end
    image_type = 'indexed';
    
elseif islogical(img)
  if (ndims(img) ~= 2)
    eid = sprintf('Images:%s:binaryImageDim',mfilename);
    error(eid,'%s','Binary image matrix, BW, must be two dimensional.');
  end
  image_type = 'binary';
  
elseif (ndims(img) == 3) && (size(img,3) == 3)
  image_type = 'truecolor';
  
else
    if (ndims(img) ~= 2)
        eid = sprintf('Images:%s:intensityImageDim',mfilename);
        error(eid,'%s','Input image must be 2-D or M-by-N-by-3.');
    end
    image_type = 'intensity';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function img = CheckForNaNs(img, image_type)

idx = find(isnan(img));
if ~isempty(idx)
  if strcmp(image_type, 'indexed') && isa(img,'double')
    replace_value = 1;
    wid = sprintf('Images:%s:replacingNaNWithOne',mfilename);
    msg = 'IMVIEW is replacing all NaNs with ones.';
  else
    replace_value = 0;
    wid = sprintf('Images:%s:replacingNaNWithZero',mfilename);
    msg = 'IMVIEW is replacing all NaNs with zeros.';
  end
  warning(wid,'%s',msg);
  img(idx) = replace_value;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function metadata = GetMetadata(filename)

if ~isempty(filename)
  metadata = imfinfo(filename);
  metadata = metadata(1);  % In case file contains multiple images
else
  metadata = [];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function imviewImage = MakeImviewImage(img, image_name, image_type, ...
                                       display_range, image_scale_range, ...
                                       metadata, img_min, img_max, ...
                                       all_integers, initial_mag)

% Create a UDD object describing the image
imviewImage                = imviewpkg.image;
imviewImage.imagetype      = image_type;
imviewImage.name           = image_name;
imviewImage.classtype      = class(img);
imviewImage.width          = size(img,2);
imviewImage.height         = size(img,1);
imviewImage.displayblack   = display_range(1);
imviewImage.displaywhite   = display_range(2);
imviewImage.scalerangemin  = image_scale_range(1);
imviewImage.scalerangemax  = image_scale_range(2);
imviewImage.allintegers    = all_integers;
imviewImage.magnification  = initial_mag;

if ~strcmp(image_type, 'truecolor')
  imviewImage.minvalue     = img_min;
  imviewImage.maxvalue     = img_max;
end

setMetadata(imviewImage,metadata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [img,map,image_scale_range] = ...
    MakeIndexedDisplayImage(img,map,display_range,img_min,img_max,all_integers)

if ~isempty(map)
  % Indexed image input.

  image_scale_range = GetDefaultRange(class(img));
  if isa(img,'double')              
    if size(map,1)<=256
      MAX_MAP_LENGTH = 256;        
      img = uint8(img - 1);
    else
      MAX_MAP_LENGTH = 65536;
      img = uint16(img - 1);
    end      
    
    image_scale_range = [1 MAX_MAP_LENGTH];
    
  elseif isa(img,'uint8')
    MAX_MAP_LENGTH = 256;
    img = min(img, uint8(size(map,1) - 1));
    
  else % uint16
    MAX_MAP_LENGTH = 65536;
    img = min(img, uint16(size(map,1) - 1));
    
  end

  if size(map,1) > MAX_MAP_LENGTH
    eid = sprintf('Images:%s:mapTooLong',mfilename);
    error(eid,'%s','Colormap is too long.');
  end    
  
elseif islogical(img)
  img = uint8(img);
  map = gray(2);
  image_scale_range = GetDefaultRange('uint8');
  
else
  % Intensity image input

  image_scale_range = GetDefaultRange(class(img));

  if (img_max-img_min ~= 0)

      % Scale range
      slope = 1;
      intercept = 0;
      
      if isa(img,'double')
          image_scale_range = [img_min img_max];       
                    
          if ~all_integers
              slope = 65535/diff(image_scale_range);
          else
              % All values are integers that can be stored in uint16 with
              % translation but no scaling.
              image_scale_range = GetDefaultRange('uint16') + img_min;
          end
          intercept = -slope*img_min;
          img = imlincomb(slope,img,intercept,'uint16');
                    
      elseif isa(img,'int16')
          image_scale_range = GetDefaultRange('uint16') + img_min;
          intercept = -slope*img_min;
          img = imlincomb(slope,img,intercept,'uint16');
      
      end
  
      % Display range
      if isa(img,'uint8')
          TRANSFER_TYPE_MAX = 255;
      else % uint16 and double
          TRANSFER_TYPE_MAX = 65535;
      end

      transfer_display_range = round(slope*display_range + intercept);

      p = polyfit(transfer_display_range,[0 1], 1);
      map = polyval(p,0:TRANSFER_TYPE_MAX);
      map(map<0) = 0;
      map(map>1) = 1;
  
  else
      % degenerate: img has only one value
      img = repmat(uint8(0),size(img));
      map = img_min/diff(image_scale_range);
      map = min(1,max(0,map));  % clip so it's in [0 1] range
      image_scale_range = [img_min img_max];      
      
  end
  
  map = repmat(map',1,3);  
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function display_range = GetDefaultDisplayRange(img, map, image_type)

if strcmp(image_type, 'indexed')
  if isa(img,'double')
    display_range = [1 size(map,1)];
  else
    display_range = [1 size(map,1)] - 1;
  end
else
  display_range = GetDefaultRange(class(img));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function display_range = GetDefaultRange(key_class)

switch key_class
  case 'uint8'
    display_range = [0 255];
  
  case 'uint16'
    display_range = [0 65535];
  
  case 'int16'
    display_range = [-32768 32767];
    
  otherwise
    display_range = [0 1];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [filename, user_canceled, close_all, img, ...
          map, display_range, initial_mag, num_imview_specific_args] = ...
    ParseInputs(varargin)

% defaults
filename        = '';
user_canceled   = false;
close_all       = false;
img             = [];
map             = [];
display_range   = [];
num_imview_specific_args = 0;

if strcmp(iptgetpref('ImviewInitialMagnification'),'fit')
  initial_mag = 'fit';
else
  initial_mag = '100';
end

checknargin(0,4,nargin,mfilename);

% short circuit for IMVIEW CLOSE ALL
if nargin == 2 && ischar(varargin{1}) && ischar(varargin{2}) && ...
           strcmp(lower(varargin{1}),'close') && ...
           strcmp(lower(varargin{2}),'all')
  close_all = true;
  num_imview_specific_args = 2;
  return;
end

num_arg = nargin;

% IMVIEW(...,'InitialMagnification', INITIAL_MAG)
if (num_arg > 1) && ischar(varargin{num_arg-1}) && ...
      ~isempty(regexpi('InitialMagnification', ['^' varargin{num_arg-1}]))
  
  checkinput(varargin{num_arg}, {'char','double'},{}, mfilename,...
             'INITIAL_MAG', num_arg);
  
  if ischar(varargin{num_arg}) && ...
        ~isempty(regexpi('fit', ['^' varargin{num_arg}]))
    initial_mag = 'fit';
    
  elseif varargin{num_arg} == 100
    initial_mag = '100';
    
  else
    eid = sprintf('Images:%s:invalidInitialMagnification',mfilename);
    error(eid,'%s','''InitialMagnification'' must be either 100 or ''fit''.');
    
  end

  num_arg = num_arg - 2;
  num_imview_specific_args = 2;
  
end

% stop parsing at this point on platforms without proper Java support
if ~IsJavaAvailable
  return;
end

if num_arg > 2
  eid = sprintf('Images:%s:invalidParameterValuePair',mfilename);
  error(eid,'%s','Invalid parameter/value input to IMVIEW.');
end

switch num_arg
 case 0  
  %IMVIEW
  [filename,user_canceled] = GetFilename;
  if user_canceled
    return
  else
    [img,map] = GetImageFromFile(filename);
  end
  
 case 1
  % IMVIEW(I) or IMVIEW(FILENAME)
  if ischar(varargin{1})
    % IMVIEW(FILENAME)
    filename = varargin{1};
    [img,map] = GetImageFromFile(filename);
  else
    % IMVIEW(I) or IMVIEW(RGB)
    img = varargin{1};
  end
  
 case 2
  if ischar(varargin{1})
    eid = sprintf('Images:%s:stringPlusExtraArgs',mfilename);
    error(eid,'%s',['If the first input is FILENAME,',...
                    ' it must be the only input.']);
  end

  img = varargin{1};

  if (ndims(img) == 3) && (size(img,3) == 3)
      eid = sprintf('Images:%s:rangeWithRGB',mfilename);
      error(eid,'%s','RANGE input not allowed with truecolor images.');
  end
    
  if isempty(varargin{2})
    % IMVIEW(I,[])
    display_range = 'autoscale';
    
  elseif numel(varargin{2}) == 2
    % IMVIEW(I,[LOW HIGH])
    display_range = varargin{2};
    CheckDisplayRange(display_range);
    display_range = double(display_range);
    
  else
    % IMVIEW(X,MAP)
    map = varargin{2};
    
    if isa(img,'double') 
      img = round(img); % make sure indices are integers 
    end
    
  end
 
 otherwise
  eid = sprintf('Images:%s:internalError',mfilename);
  error(eid,'%s','Internal error in IMVIEW when parsing inputs.');  

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [filename,user_canceled] = GetFilename

filename       = '';          
user_canceled = false;      

persistent file_chooser;    % for IMVIEW

import com.mathworks.mwswing.MJFileChooser;
import com.mathworks.toolbox.images.ImformatsFileFilter;  

if ~isa(file_chooser,'MJFileChooser') % only initialize once
  file_chooser = MJFileChooser(pwd);
  file_chooser.setDialogTitle('Open Image');
  
  % Parse formats from IMFORMATS 
  formats = imformats;
  nformats = length(formats);
  desc = cell(nformats,1);
  [desc{:}] = deal(formats.description);
  ext = cell(nformats,1);
  [ext{:}] = deal(formats.ext);

  % Create a filter that includes all extensions
  ext_all = cell(0);
  for i = 1:nformats
    ext_i = ext{i};
    ext_all(end+1: end+numel(ext_i)) = ext_i(:);
  end
  ext{end+1,1} = ext_all;
  desc{end+1,1} = 'All image files'; 
  
  % Make a vector of String arrays
  extVector = java.util.Vector(nformats);
  for i = 1:nformats+1
    extVector.add(i-1,ext{i})
  end

  % Push formats into ImformatsFileFilter so instances of 
  % ImformatsFileFilter will be based on IMFORMATS.
  ImformatsFileFilter.initializeFormats(nformats,desc,extVector);

  % Create all_images_filter
  all_images_filter = ... 
      ImformatsFileFilter(ImformatsFileFilter.ACCEPT_ALL_IMFORMATS);
  file_chooser.addChoosableFileFilter(all_images_filter); 
  % Add one ChoosableFileFilter for each format in IMFORMATS
  for i = 1:nformats
    file_chooser.addChoosableFileFilter(ImformatsFileFilter(i-1))
  end

  % Put accept all files at end
  accept_all_filter = file_chooser.getAcceptAllFileFilter;
  file_chooser.removeChoosableFileFilter(accept_all_filter);
  file_chooser.addChoosableFileFilter(accept_all_filter);

  % Make default be all_images_filter
  file_chooser.setFileFilter(all_images_filter);

end

returnVal = file_chooser.showOpenDialog(com.mathworks.mwswing.MJFrame);    
if (returnVal == MJFileChooser.APPROVE_OPTION)
  filename = char(file_chooser.getSelectedFile.getPath);
else
  user_canceled = true;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function CheckDisplayRange(display_range)

checkinput(display_range, {'numeric'}, {'real' 'nonsparse' 'finite' 'vector'}, ...
           mfilename, 'RANGE', 2);

if display_range(2) <= display_range(1)
  eid = sprintf('Images:%s:badRangeValues', mfilename);
  error(eid,'%s','RANGE(2) must be greater than RANGE(1)');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [img,map] = GetImageFromFile(filename)

if ~exist(filename, 'file')
  eid = sprintf('Images:%s:fileDoesNotExist',mfilename);
  msg = sprintf('Cannot find the specified file: "%s"', filename);
  error(eid,'%s',msg);
end

try
  [img,map] = imread(filename);
catch
  eid = sprintf('Images:%s:couldNotReadFile',mfilename); 
  error(eid,'IMVIEW could not read this file using IMREAD: "%s"', filename);
end    

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function java_available = IsJavaAvailable

java_available = false;
ismac = strcmpi(computer,'mac'); % disable on Mac

if isempty(javachk('swing')) && ~ismac
  java_available = true;
end
  
