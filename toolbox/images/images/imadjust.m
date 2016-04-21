function out = imadjust(varargin)
%IMADJUST Adjust image intensity values or colormap.
%   J = IMADJUST(I) maps the values in intensity image I to new values in J 
%   such that 1% of data is saturated at low and high intensities of I. This
%   increases the contrast of the output image J.
%
%   J = IMADJUST(I,[LOW_IN; HIGH_IN],[LOW_OUT; HIGH_OUT]) maps the
%   values in intensity image I to new values in J such that values between
%   LOW_IN and HIGH_IN map to values between LOW_OUT and HIGH_OUT. Values
%   below LOW_IN and above HIGH_IN are clipped; that is, values below LOW_IN
%   map to LOW_OUT, and those above HIGH_IN map to HIGH_OUT. You can use an
%   empty matrix ([]) for [LOW_IN; HIGH_IN] or for [LOW_OUT; HIGH_OUT] to
%   specify the default of [0 1]. If you omit the argument, [LOW_OUT;
%   HIGH_OUT] defaults to [0 1].
%
%   J = IMADJUST(I,[LOW_IN; HIGH_IN],[LOW_OUT; HIGH_OUT],GAMMA) maps the values
%   of I to new values in J as described in the previous syntax. GAMMA
%   specifies the shape of the curve describing the relationship between the
%   values in I and J. If GAMMA is less than 1, the mapping is weighted toward
%   higher (brighter) output values. If GAMMA is greater than 1, the mapping is
%   weighted toward lower (darker) output values. If you omit the argument,
%   GAMMA defaults to 1 (linear mapping).
%
%   NEWMAP = IMADJUST(MAP,[LOW_IN; HIGH_IN],[LOW_OUT; HIGH_OUT],GAMMA)
%   transforms the colormap associated with an indexed image. If LOW_IN,
%   HIGH_IN, LOW_OUT, HIGH_OUT, and GAMMA are scalars, then the same mapping
%   applies to red, green and blue components. Unique mappings for each
%   color component are possible when: 
%   LOW_IN and HIGH_IN are both 1-by-3 vectors,
%   LOW_OUT and HIGH_OUT are both 1-by-3 vectors, OR
%   GAMMA is a 1-by-3 vector.
%   The rescaled colormap, NEWMAP, is the same size as MAP.
%
%   RGB2 = IMADJUST(RGB1,...) performs the adjustment on each image plane
%   (red, green, and blue) of the RGB image RGB1. As with the colormap
%   adjustment, you can apply unique mappings to each plane.
%
%   Note that IMADJUST(I) is equivalent to IMADJUST(I,STRETCHLIM(I)).
%
%   Note that if HIGH_OUT < LOW_OUT, the output image is reversed, as in a
%   photographic negative.
%
%   Class Support
%   -------------
%   For syntaxes that include an input image (rather than a colormap), the
%   input image can be of class uint8, uint16, or double. The output image
%   has the same class as the input image. For syntaxes that include a
%   colormap, the input and output colormaps are of class double.
%
%   Examples
%   --------
%       I = imread('pout.tif');
%       J = imadjust(I);
%       imview(I), imview(J)
%
%       K = imadjust(I,[0.3 0.7],[]);
%       imview(K)
%
%       RGB1 = imread('football.jpg');
%       RGB2 = imadjust(RGB1,[.2 .3 0; .6 .7 1],[]);
%       imview(RGB1), imview(RGB2)
%
%   See also BRIGHTEN, HISTEQ, STRETCHLIM.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.26.4.4 $  $Date: 2003/05/03 17:50:41 $

%   Input-output specs
%   ------------------ 
%   I,J          real, full matrix, 2-D
%                uint8, uint16, double
%   
%   RGB1,RGB2    real, full matrix
%                M-by-N-by-3
%                uint8, uint16, double
%
%   MAP,NEWMAP   real, full matrix
%                M-by-3
%                double with values in the range [0,1].
%
%   [LOW_IN; HIGH_IN]    double, real, full matrix
%                        For I, size can only be 2 elements. 
%                        For RGB or MAP, size can be 2 elements OR
%                        2-by-3 matrix.
%                        LOW_IN < HIGH_IN
%
%   [LOW_OUT; HIGH_OUT]  Same size restrictions as [LOW_IN; HIGH_IN]
%                        LOW_OUT can be less than HIGH_OUT
%
%   LOW_IN, HIGH_IN, LOW_OUT, HIGH_OUT all must be in the range [0,1];
% 
%   GAMMA         real, double, nonnegative
%                 scalar for I
%                 scalar or 1-by-3 vector for RGB and MAP



%Parse inputs and initialize variables
[img,grayFlag,rgbFlag,low_in,high_in,low_out,high_out,gamma] = ...
    ParseInputs(varargin{:});

if ( isa(img,'uint8') || ( isa(img,'uint16') && numel(img) > 65536 ) )
  out = AdjustWithLUT(img,grayFlag,rgbFlag,low_in,high_in,low_out,high_out, ...
                      gamma);
else
  out = AdjustGeneric(img,grayFlag,rgbFlag,low_in,high_in,low_out,high_out, ...
                      gamma);
end


%------------------------------------
function out=AdjustWithLUT(img,grayFlag,rgbFlag,low_in,high_in,low_out, ...
                           high_out,gamma)

%initialize
out = img;
grayFlag = true;
rgbFlag = false;

for p=1:size(img,3)
  if isa(img,'uint8')
    lut = linspace(0,1,256);
    lut = AdjustGeneric(lut,grayFlag,rgbFlag,low_in(p),high_in(p),low_out(p), ...
                        high_out(p),gamma(p));
    lut = im2uint8(lut);
  else
    %uint16
    lut = linspace(0,1,65536);
    lut = AdjustGeneric(lut,grayFlag,rgbFlag,low_in(p),high_in(p),low_out(p), ...
                        high_out(p),gamma(p));
    lut = im2uint16(lut);
  end
  out(:,:,p) = uintlut(img(:,:,p),lut);
end

%---------------------------------------------
function out = AdjustGeneric(img,grayFlag,rgbFlag,low_in,high_in,low_out, ...
                             high_out,gamma)

%Promote image data to double if it is uint8 or uint16
classin = class(img);
classChanged = false;
if ~isa(img,'double')
  classChanged = true;
  img = im2double(img);
end

%Initialize output
out = zeros(size(img));

if ~rgbFlag
  % Transform colormap or Grayscale intensity image (v1 functionality)
  if grayFlag 
    n = 1; 
  else 
    n = size(img,1); 
  end
    
  % Make sure img is in the range [low_in,high_in]
  img(:) = max(low_in(ones(n,1),:),min(high_in(ones(n,1),:),img));
  
  % The transformation
  d = ones(n,1);
  out = ( (img-low_in(d,:))./(high_in(d,:)-low_in(d,:)) ).^(gamma(d,:));
  out(:) = out.*(high_out(d,:)-low_out(d,:)) + low_out(d,:);
else 
  % Loop over image planes and perform transformation
  for p=1:3,
    % Make sure img is in the range [low_in,high_in]
    img(:,:,p) =  max(low_in(p),min(high_in(p),img(:,:,p)));
    
    % The transformation
    out(:,:,p) = ...
        ( (img(:,:,p)-low_in(p))./(high_in(p)-low_in(p)) ).^(gamma(p));
    out(:,:,p) = out(:,:,p).*(high_out(p)-low_out(p)) + low_out(p);
  end
end

if classChanged
  out = changeclass(classin,out);
end
    
%--------------------------------------------------------------------
% Subfunction ParseInputs
function [img,grayFlag,rgbFlag,low_in,high_in,low_out,high_out,gamma] = ...
    ParseInputs(varargin)

checknargin(1,4,nargin,mfilename);

% Default values
img = [];
lowhigh_in  = [0; 1];
lowhigh_out = [0; 1];
gamma = 1;

img = varargin{1};
[rgbFlag, grayFlag] = getImType(img);

switch nargin
  case 1
    % IMADJUST(I)
    % IMADJUST(RGB)

    if grayFlag
      lowhigh_in = stretchlim(img);
    else
      msg = 'IMADJUST(I) is only supported for grayscale images.';
      eid = sprintf('Images:%s:oneArgOnlyGrayscale',mfilename);
      error(eid,msg);
    end
    
  case 2
    % IMADJUST(I,[LOW_IN HIGH_IN])
    % IMADJUST(MAP,[LOW_IN HIGH_IN]) 

    if ~isempty(varargin{2})
        lowhigh_in = varargin{2};
    end

  case 3
    % IMADJUST(I,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT])
    % IMADJUST(MAP,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT]) 

    if ~isempty(varargin{2})
        lowhigh_in = varargin{2};
    end

    if ~isempty(varargin{3})
        lowhigh_out = varargin{3};
    end

  case 4
    % IMADJUST(I,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT],GAMMA)
    % IMADJUST(MAP,[LOW_IN HIGH_IN],[LOW_OUT HIGH_OUT],GAMMA) 

    if ~isempty(varargin{2})
        lowhigh_in = varargin{2};
    end

    if ~isempty(varargin{3})
        lowhigh_out = varargin{3};
    end
    
    if ~isempty(varargin{4})
        gamma = varargin{4};
    end
    
end

[low_in high_in]   = range_split(lowhigh_in, grayFlag,2,'[LOW_IN; HIGH_IN]');
[low_out high_out] = range_split(lowhigh_out,grayFlag,3,'[LOW_OUT; HIGH_OUT]');

check_lowhigh(low_in,high_in,low_out,high_out)
gamma = check_gamma(gamma,grayFlag);


%--------------------------------------------------------------------
function [rgbFlag, grayFlag] = getImType(img)

if (ndims(img)==3 && size(img,3)==3)
  % RGB Intensity Image
  checkinput(img, {'double' 'uint8' 'uint16'}, '', mfilename, 'RGB1', 1);
  rgbFlag = true;
  grayFlag = false;  
elseif size(img,2)~=3
  % Grayscale Intensity Image
  checkinput(img, {'double' 'uint8' 'uint16'}, '2d', mfilename, 'I', 1);
  grayFlag = true;
  rgbFlag = false;  
else
  % Colormap
  checkmap(img,mfilename,'MAP',1);
  grayFlag = false;
  rgbFlag = false;  
end


%--------------------------------------------------------------------
function [range_min, range_max] = range_split(range,grayFlag,...
                                              argument_position,...
                                              variable_name)

msg1 = sprintf('Function %s expected its %s input argument, %s',...
               mfilename,...
               num2ordinal(argument_position),...
               variable_name);

if grayFlag
  % GRAY
  
  if numel(range) ~= 2
    msg2 = 'to be a two-element vector.';
    eid = sprintf('Images:%s:InputMustBe2ElVec',mfilename);
    error(eid, '%s\n%s', msg1, msg2);
  end
  
  range_min = range(1);
  range_max = range(2);
  
else
  % RGB
  % MAP
  
  if (numel(range) ~= 2) & ~isequal(size(range),[2 3])
    msg2 = 'to be a two-element vector or a 2-by-3 matrix.';
    eid = sprintf('Images:%s:InputMustBe2ElVecOr2by3Matrix',mfilename);
    error(eid, '%s\n%s', msg1, msg2);
  end
  
  if min(size(range))==1,
    % Create triples for RGB image or Colormap
    range_min = range(1)*ones(1,3);
    range_max = range(2)*ones(1,3);
  else
    range_min = range(1,:);
    range_max = range(2,:);
  end

end


%--------------------------------------------------------------------
function check_lowhigh(low_in,high_in,low_out,high_out)

if any(low_in>=high_in)
    msg = sprintf('%s: LOW_IN must be less than HIGH_IN.',...
                   upper(mfilename));
    eid = sprintf('Images:%s:lowMustBeSmallerThanHigh',mfilename);
    error(eid,msg);
end

if min(low_in)<0 | max(low_in)>1 | min(high_in)<0 | max(high_in)>1 | ...
        min(low_out)<0 | max(low_out)>1 | min(high_out)<0  | max(high_out)>1
    msg = sprintf('%s: %s %s',...
                  upper(mfilename),...
                  'LOW_IN, HIGH_IN, LOW_OUT and HIGH_OUT',...
                  'must be in the range [0.0, 1.0].');
    eid = sprintf('Images:%s:parametersAreOutOfRange',mfilename);
    error(eid,msg);
end

%--------------------------------------------------------------------
function gamma = check_gamma(gamma,grayFlag)

if grayFlag
  checkinput(gamma,'double',{'scalar', 'nonnegative'},...
             mfilename, 'GAMMA', 4)

else

  checkinput(gamma,'double',{'nonnegative','2d'},...
             mfilename, 'GAMMA', 4)

  if numel(gamma) == 1, 
    gamma = gamma*ones(1,3); 
  end

end
