function [X,map] = rgb2ind(varargin)
%RGB2IND Convert RGB image to indexed image.
%   RGB2IND converts RGB images to indexed images using one of three
%   different methods: uniform quantization, minimum variance quantization,
%   and colormap approximation. RGB2IND dithers the image unless you specify
%   'nodither' for DITHER_OPTION.
%
%   [X,MAP] = RGB2IND(RGB,N) converts the RGB image to an indexed image X
%   using minimum variance quantization. MAP contains at most N colors.  N
%   must be <= 65536.
%
%   X = RGB2IND(RGB,MAP) converts the RGB image to an indexed image X with
%   colormap MAP by matching colors in RGB with the nearest color in the
%   colormap MAP.  SIZE(MAP,1) must be <= 65536.
%
%   [X,MAP] = RGB2IND(RGB,TOL) converts the RGB image to an indexed image X
%   using uniform quantization. MAP contains at most (FLOOR(1/TOL)+1)^3
%   colors. TOL must be between 0.0 and 1.0.
%
%   [...] = RGB2IND(...,DITHER_OPTION) enables or disables
%   dithering. DITHER_OPTION is a string that can have one of these values:
%
%       'dither'   dithers, if necessary, to achieve better color
%                  resolution at the expense of spatial
%                  resolution (default)
%
%       'nodither' maps each color in the original image to the
%                  closest color in the new map. No dithering is
%                  performed.
%
%   Class Support
%   -------------
%   The input image can be of class uint8, uint16, or double. The output
%   image is of class uint8 if the length of MAP is less than or equal to
%   256, or uint16 otherwise.
%
%   Example
%   -------
%       RGB = imread('peppers.png');
%       [X,map] = rgb2ind(RGB,128);
%       imview(X,map)
%
%   See also CMUNIQUE, DITHER, IMAPPROX, IND2RGB, RGB2GRAY.

% Grandfathered syntax
% --------------------
%   [X,MAP] = RGB2IND(RGB) converts the RGB image in the array
%   RGB to an indexed image X with colormap MAP using direct
%   translation. The resulting colormap may be very long, as it
%   has one entry for each pixel in RGB. Do not set DITHER_OPTION
%   if you use this method.
%

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.21.4.5 $  $Date: 2003/08/23 05:54:36 $

[RGB,m,dith] = parse_inputs(varargin{:});

so = size(RGB);

% Converts depending on what is m:
if isempty(m) % Convert RGB image to an indexed image.
    X = reshape(1:(so(1)*so(2)),so(1),so(2));
    if so(1)*so(2) <= 256
        X = uint8(X-1);
    elseif so(1)*so(2) <= 65536
        X = uint16(X-1);
    end
    map = im2double(reshape(RGB,so(1)*so(2),3));

elseif length(m)==1 % TOL or N is given
    RGB = im2uint8(RGB);

    if (m < 1) % tol is given. Use uniform quantization
        max_colors = 65536;
        max_N = floor(max_colors^(1/3)) - 1;
        N = round(1/m);
        if (N > max_N)
            N = max_N;
            wid = sprintf('Images:%s:tooManyColors',mfilename);
            warning(wid,'Too many colors; increasing tolerance to %g',1/N);
        end
        
        [x,y,z] = meshgrid((0:N)/N);
        map = [x(:),y(:),z(:)];

        if dith(1) == 'n'; 
            RGB = round(im2double(RGB)*N);
            X = RGB(:,:,3)*((N+1)^2)+RGB(:,:,1)*(N+1)+RGB(:,:,2)+1;
        else
            X = dither(RGB,map);
        end
        [X,map] = cmunique(X,map);

    else % N is given. Use variance minimization quantization
        [map,X] = cq(RGB,m);
        map = double(map) / 255;
        if (dith(1) == 'd') && (size(map,1) > 1)
            % Use standalone dither if map is an approximation.
            X = dither(RGB,map);
        end
    end

else % MAP is given
    RGB = im2uint8(RGB);

    map = m;
    if dith(1)=='n', % 'nodither'
        X = dither(RGB,map,5,4); % Use dither to do inverse colormap mapping.
    else
        X = dither(RGB,map);
    end
end

if isa(map, 'uint8'),    % Make sure that the colormap is doubles
    map = double(map)/255;
elseif isa(map, 'uint16')
    map = double(map)/65535;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [RGB,m,dith] = parse_inputs(varargin)
% Outputs:  RGB     image
%           m       colormap
%           dith    dithering option
% Defaults:
dith = 'dither';
m = [];

error(nargchk(1,5,nargin,'struct'));

eid_RGBSize = sprintf('Images:%s:rgbNotEqualSize',mfilename);
msg_RGBSize = 'R,G,B arrays must be of equal size.';

wid_obsoleteSyntaxUse3D = sprintf('Images:%s:obsoleteSyntaxUse3DArray', ...
                                  mfilename);
msg_obsoleteSyntaxUse3D = sprintf('%s %s %s',...
                                  'RGB2IND(R,G,B) is an obsolete syntax.',...
                                  'Use a three-dimensional array to ',...
                                  'represent RGB image.');

switch nargin
 case 1               % rgb2ind(RGB)
  RGB = varargin{1};
  wid = sprintf('Images:%s:obsoleteSyntaxNeedMoreArgs',mfilename);
  warning(wid,...
          '%s\n%s', 'RGB2IND(RGB) is an obsolete syntax.', ...
          'Specify number of colors, tolerance, or colormap.');
 case 2               % rgb2ind(RGB,x) where x = MAP | N | TOL
  RGB = varargin{1};
  m = varargin{2};
 case 3               % rgb2ind(R,G,B) OBSOLETE
  if isequal(size(varargin{1}),size(varargin{2}),size(varargin{3})),
    warning(wid_obsoleteSyntaxUse3D,'%s',msg_obsoleteSyntaxUse3D);
    RGB = cat(3,varargin{1},varargin{2},varargin{3});
  else                % rgb2ind(RGB,x,DITHER_OPTION)
    RGB = varargin{1};  %              where x = MAP | N | TOL
    m = varargin{2};
    dith = varargin{3};
  end
case 4               % rgb2ind(R,G,B,x) OBSOLETE
  warning(wid_obsoleteSyntaxUse3D,'%s',msg_obsoleteSyntaxUse3D);
  if isequal(size(varargin{1}),size(varargin{2}),size(varargin{3})),
    RGB = cat(3,varargin{1},varargin{2},varargin{3});
  else
    error(eid_RGBSize,'%s',msg_RGBSize);
  end
  m = varargin{4};
case 5               % rgb2ind(R,G,B,x,DITHER_OPTION) OBSOLETE
  warning(wid_obsoleteSyntaxUse3D,'%s',msg_obsoleteSyntaxUse3D);
  if isequal(size(varargin{1}),size(varargin{2}),size(varargin{3})),
    RGB = cat(3,varargin{1},varargin{2},varargin{3});
  else
    error(eid_RGBSize,'%s',msg_RGBSize);
  end
  m = varargin{4};
  dith = varargin{5}; 
otherwise
  eid = sprintf('Images:%s:invalidInputArgs',mfilename);
  error(eid,'%s','Invalid input arguments.');
end

% Check validity of the input parameters
if ndims(RGB)==3 && size(RGB,3) ~= 3 || ndims(RGB) > 3
  eid = sprintf('Images:%s:rgbNotMbyNby3',mfilename);
  error(eid,'%s','RGB image has to be M-by-N-by-3 array.');
end

% Check MAP
if any(m(:)<0)
  eid = sprintf('Images:%s:negativeValuesInMap',mfilename);    
  error(eid,'%s',...
        'Colormap, Number of colors, or Tolerance have to be non-negative.');

elseif size(m,1)==1 & m~=round(m) & m > 1
  eid = sprintf('Images:%s:numberOfColorsNegative',mfilename);    
  error(eid,'%s',...
        'Number of colors in the colormap has to be a non-negative integer.');

elseif (size(m,1) > 1 && size(m,2) > 1 && size(m,2) ~= 3) || ndims(m) ~= 2 
  eid = sprintf('Images:%s:invalidMapSize',mfilename);    
  error(eid,'%s %s',...
        'Input colormap has to be a 2D array with at least 2 rows',...
        'and exactly 3 columns.');

elseif size(m,1) > 1 && max(m(:)) > 1
  eid = sprintf('Images:%s:invalidMapIntensities',mfilename);    
  error(eid,'%s','All colormap intensities must be between 0 and 1.');
end

if ischar(dith),% dither option
  strings = {'dither','nodither'};
  idx = strmatch(lower(dith),strings);
  if isempty(idx),
    eid = sprintf('Images:%s:unknownDitherOption',mfilename);    
    error(eid,'%s',sprintf('Unknown dither option: %s',dith));
  elseif length(idx)>1,
    eid = sprintf('Images:%s:ambiguousDitherOption',mfilename);    
    error(eid,'%s',sprintf('Ambiguous dither option: %s',dith));
  else
    dith = strings{idx};
  end  
else
  eid = sprintf('Images:%s:ditherOptionNotString',mfilename);        
  error(eid,'%s',sprintf('Dither option has to be a string.'));  
end
