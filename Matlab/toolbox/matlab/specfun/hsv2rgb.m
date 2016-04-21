function [rout,g,b] = hsv2rgb(h,s,v)
%HSV2RGB Convert hue-saturation-value colors to red-green-blue.
%   M = HSV2RGB(H) converts an HSV color map to an RGB color map.
%   Each map is a matrix with any number of rows, exactly three columns,
%   and elements in the interval 0 to 1.  The columns of the input matrix,
%   H, represent hue, saturation and value, respectively.  The columns of
%   the resulting output matrix, M, represent intensity of red, blue and
%   green, respectively.
%
%   RGB = HSV2RGB(HSV) converts the HSV image HSV (3-D array) to the
%   equivalent RGB image RGB (3-D array).
%
%   As the hue varies from 0 to 1, the resulting color varies from
%   red, through yellow, green, cyan, blue and magenta, back to red.
%   When the saturation is 0, the colors are unsaturated; they are
%   simply shades of gray.  When the saturation is 1, the colors are
%   fully saturated; they contain no white component.  As the value
%   varies from 0 to 1, the brightness increases.
%
%   The colormap HSV is hsv2rgb([h s v]) where h is a linear ramp
%   from 0 to 1 and both s and v are all 1's.
%
%   See also RGB2HSV, COLORMAP, RGBPLOT.

%   Undocumented syntaxes:
%   [R,G,B] = HSV2RGB(H,S,V) converts the HSV image H,S,V to the
%   equivalent RGB image R,G,B.
%
%   RGB = HSV2RGB(H,S,V) converts the HSV image H,S,V to the 
%   equivalent RGB image stored in the 3-D array (RGB).
%
%   [R,G,B] = HSV2RGB(HSV) converts the HSV image HSV (3-D array) to
%   the equivalent RGB image R,G,B.
%

%   See Alvy Ray Smith, Color Gamut Transform Pairs, SIGGRAPH '78.
%   C. B. Moler, 8-17-86, 5-10-91, 2-2-92.
%   Copyright 1984-2003 The MathWorks, Inc. 
%   $Revision: 5.12.4.1 $  $Date: 2003/05/01 20:43:47 $

if ( (nargin ~= 1) && (nargin ~= 3) ),
  error('MATLAB:hsv2rgb:WrongInputNum', 'Wrong number of input arguments.');
end

threeD = (ndims(h)==3); % Determine if input includes a 3-D array

if threeD,
  s = h(:,:,2); v = h(:,:,3); h = h(:,:,1);
  siz = size(h);
  s = s(:); v = v(:); h = h(:);
elseif nargin==1, % HSV colormap
  s = h(:,2); v = h(:,3); h = h(:,1);
  siz = size(h);
else
  if ~isequal(size(h),size(s),size(v)),
    error('MATLAB:hsv2rgb:InputSizeMismatch', 'H,S,V must all be the same size.');
  end
  siz = size(h);
  h = h(:); s = s(:); v = v(:);
end

h = 6*h(:);
k = fix(h-6*eps);
f = h-k;
t = 1-s;
n = 1-s.*f;
p = 1-(s.*(1-f));
e = ones(size(h));
r = (k==0).*e + (k==1).*n + (k==2).*t + (k==3).*t + (k==4).*p + (k==5).*e;
g = (k==0).*p + (k==1).*e + (k==2).*e + (k==3).*n + (k==4).*t + (k==5).*t;
b = (k==0).*t + (k==1).*t + (k==2).*p + (k==3).*1 + (k==4).*1 + (k==5).*n;
f = v./max([r(:);g(:);b(:)]);

if nargout<=1,
  if (threeD || nargin==3),
    rout = zeros([siz,3]);
    rout(:,:,1) = reshape(f.*r,siz);
    rout(:,:,2) = reshape(f.*g,siz);
    rout(:,:,3) = reshape(f.*b,siz);
  else
    rout = [f.*r f.*g f.*b];
  end
else
  rout = reshape(f.*r,siz);
  g = reshape(f.*g,siz);
  b = reshape(f.*b,siz);
end
