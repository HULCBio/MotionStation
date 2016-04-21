function I = ind2gray(varargin)
%IND2GRAY Convert indexed image to intensity image.
%   I = IND2GRAY(X,MAP) converts the image X with colormap MAP
%   to an intensity image I. IND2GRAY removes the hue and
%   saturation information while retaining the luminance.
%
%   Class Support
%   -------------
%   X can be uint8, uint16, or double. MAP is double. 
%   I has the same class as X.
%
%   Example
%   -------
%       load trees
%       I = ind2gray(X,map);
%       imview(X,map),imview(I);
%
%   See also GRAY2IND, IMVIEW, IMSHOW, RGB2NTSC.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.15.4.4 $  $Date: 2003/08/01 18:09:14 $

[a,cm] = parse_inputs(varargin{:});

%initialize output matrix
I = a;

% calculate gray colormap
graycm = rgb2gray(cm);
graycm = graycm(:,1); 

% do transformation
if isa(a,'double')
  % Make sure A is in the range from 1 to size(cm,1)
  a = max(1,min(a,length(graycm)));  
  I(:) = graycm(a);
else
  %convert graycm to appropriate class
  graycm = changeclass(class(a),graycm);
  
  % get vector size for class
  if isa(a,'uint8')
    vs = 256;
  else
    vs = 65536;
  end

  % lut is equal to the cropped graycm (if longer than the vs for class)
  % or the padded graycm (if smaller than the vs for class).
  len = length(graycm);
  lut = graycm(1:min(len,vs));
  lut(len:vs) = graycm(end);
  
  I(:) = uintlut(a,lut);
end

%-----------------
%Parse Inputs Function
%-----------------

function [ind,map] = parse_inputs(varargin)
  
checknargin(2,2,nargin,mfilename);

% For backward compatability, this function handles an indexed image that is
% logical. This usage will be removed in a future release.
checkinput(varargin{1},{'uint8', 'logical','double', 'uint16'},{'nonempty'}, ...
           mfilename,'X',1);
ind = varargin{1};
if islogical(ind)
  wid = sprintf('Images:%s:invalidType',mfilename);
  msg = ['X should be a double, uint8, or uint16 array.  Convert your image to ' ...
         'double using IM2DOUBLE(X,''INDEXED'').'];
  warning(wid,'%s',msg);
  ind = im2double(ind,'indexed');
end

% For backward compatability, this function handles colormaps that are not
% double. This usage will be removed in a future release.
checkinput(varargin{2},{'double','uint8','uint16'},{'nonempty','2d'}, ...
           mfilename,'MAP',2);
if ( size(varargin{2},2) ~=3 || size(varargin{2},1) < 1 )
  eid = sprintf('Images:%s:invalidSizeForColormap',mfilename);
  msg = 'MAP must be a m x 3 array.';
  error(eid,'%s',msg);
else
  map = varargin{2};
end
if ~isa(map,'double');
  wid = sprintf('Images:%s:notAValidColormap',mfilename);
  msg = ['MAP should be a double m x 3 array with values in the range [0,1].'...
         'Convert your map to double using IM2DOUBLE.'];
  warning(wid,'%s',msg);
  map = im2double(map);
end
