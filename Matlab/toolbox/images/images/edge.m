function [eout,thresh] = edge(varargin)
%EDGE Find edges in intensity image.
%   EDGE takes an intensity or a binary image I as its input, and returns a 
%   binary image BW of the same size as I, with 1's where the function 
%   finds edges in I and 0's elsewhere.
%
%   EDGE supports six different edge-finding methods:
%
%      The Sobel method finds edges using the Sobel approximation to the
%      derivative. It returns edges at those points where the gradient of
%      I is maximum.
%
%      The Prewitt method finds edges using the Prewitt approximation to
%      the derivative. It returns edges at those points where the gradient
%      of I is maximum.
%
%      The Roberts method finds edges using the Roberts approximation to
%      the derivative. It returns edges at those points where the gradient
%      of I is maximum.
%
%      The Laplacian of Gaussian method finds edges by looking for zero
%      crossings after filtering I with a Laplacian of Gaussian filter.
%
%      The zero-cross method finds edges by looking for zero crossings
%      after filtering I with a filter you specify.
%
%      The Canny method finds edges by looking for local maxima of the
%      gradient of I. The gradient is calculated using the derivative of a
%      Gaussian filter. The method uses two thresholds, to detect strong
%      and weak edges, and includes the weak edges in the output only if
%      they are connected to strong edges. This method is therefore less
%      likely than the others to be "fooled" by noise, and more likely to
%      detect true weak edges.
%
%   The parameters you can supply differ depending on the method you
%   specify. If you do not specify a method, EDGE uses the Sobel method.
%
%   Sobel Method
%   ------------
%   BW = EDGE(I,'sobel') specifies the Sobel method.
%
%   BW = EDGE(I,'sobel',THRESH) specifies the sensitivity threshold for 
%   the Sobel method. EDGE ignores all edges that are not stronger than 
%   THRESH.  If you do not specify THRESH, or if THRESH is empty ([]), 
%   EDGE chooses the value automatically.
%
%   BW = EDGE(I,'sobel',THRESH,DIRECTION) specifies directionality for the
%   Sobel method. DIRECTION is a string specifying whether to look for
%   'horizontal' or 'vertical' edges, or 'both' (the default).
%
%   [BW,thresh] = EDGE(I,'sobel',...) returns the threshold value.
%
%   Prewitt Method
%   --------------
%   BW = EDGE(I,'prewitt') specifies the Prewitt method.
%
%   BW = EDGE(I,'prewitt',THRESH) specifies the sensitivity threshold for
%   the Prewitt method. EDGE ignores all edges that are not stronger than
%   THRESH. If you do not specify THRESH, or if THRESH is empty ([]),
%   EDGE chooses the value automatically.
%
%   BW = EDGE(I,'prewitt',THRESH,DIRECTION) specifies directionality for
%   the Prewitt method. DIRECTION is a string specifying whether to look
%   for 'horizontal' or 'vertical' edges, or 'both' (the default).
%
%   [BW,thresh] = EDGE(I,'prewitt',...) returns the threshold value.
%
%   Roberts Method
%   --------------
%   BW = EDGE(I,'roberts') specifies the Roberts method.
%
%   BW = EDGE(I,'roberts',THRESH) specifies the sensitivity threshold for
%   the Roberts method. EDGE ignores all edges that are not stronger than
%   THRESH. If you do not specify THRESH, or if THRESH is empty ([]),
%   EDGE chooses the value automatically.
%
%   [BW,thresh] = EDGE(I,'roberts',...) returns the threshold value.
%
%   Laplacian of Gaussian Method
%   ----------------------------
%   BW = EDGE(I,'log') specifies the Laplacian of Gaussian method.
%
%   BW = EDGE(I,'log',THRESH) specifies the sensitivity threshold for the
%   Laplacian of Gaussian method. EDGE ignores all edges that are not
%   stronger than THRESH. If you do not specify THRESH, or if THRESH is 
%   empty ([]), EDGE chooses the value automatically.
%
%   BW = EDGE(I,'log',THRESH,SIGMA) specifies the Laplacian of Gaussian
%   method, using SIGMA as the standard deviation of the LoG filter. The
%   default SIGMA is 2; the size of the filter is N-by-N, where
%   N=CEIL(SIGMA*3)*2+1. 
%
%   [BW,thresh] = EDGE(I,'log',...) returns the threshold value.
%
%   Zero-cross Method
%   -----------------
%   BW = EDGE(I,'zerocross',THRESH,H) specifies the zero-cross method,
%   using the specified filter H. If THRESH is empty ([]), EDGE chooses 
%   the sensitivity threshold automatically.
%
%   [BW,THRESH] = EDGE(I,'zerocross',...) returns the threshold value.
%
%   Canny Method
%   ----------------------------
%   BW = EDGE(I,'canny') specifies the Canny method.
%
%   BW = EDGE(I,'canny',THRESH) specifies sensitivity thresholds for the
%   Canny method. THRESH is a two-element vector in which the first element
%   is the low threshold, and the second element is the high threshold. If
%   you specify a scalar for THRESH, this value is used for the high
%   threshold and 0.4*THRESH is used for the low threshold. If you do not
%   specify THRESH, or if THRESH is empty ([]), EDGE chooses low and high 
%   values automatically.
%
%   BW = EDGE(I,'canny',THRESH,SIGMA) specifies the Canny method, using
%   SIGMA as the standard deviation of the Gaussian filter. The default
%   SIGMA is 1; the size of the filter is chosen automatically, based
%   on SIGMA. 
%
%   [BW,thresh] = EDGE(I,'canny',...) returns the threshold values as a
%   two-element vector.
%
%   Class Support
%   -------------
%   I can be of class uint8, uint16, or double. BW is of class logical.
%
%   Remarks
%   -------
%   For the 'log' and 'zerocross' methods, if you specify a
%   threshold of 0, the output image has closed contours, because
%   it includes all of the zero crossings in the input image.
%
%   Example
%   -------
%   Find the edges of the circuit.tif image using the Prewitt and Canny
%   methods:
%
%       I = imread('circuit.tif');
%       BW1 = edge(I,'prewitt');
%       BW2 = edge(I,'canny');
%       imview(BW1)
%       imview(BW2)
%
%   See also FSPECIAL.

%   OBSOLETE syntax
%   --------------------
%   BW = EDGE(... ,K) allows the specification of a directionality
%   factor, K.  This only works for the 'sobel', 'prewitt', and
%   'roberts' methods.   K must be a 1-by-2 vector, K = [kx ky].
%   For Sobel and Prewitt, K=[1 0] looks for vertical edges,
%   K=[0 1] looks for horizontal edges, and K=[1 1], the default,
%   looks for non-directional edges.   For the Roberts edge detector,
%   K=[1 0] looks for 135 degree diagonal edges, K=[0 1] looks
%   for 45 degree diagonal edges, and K=[1 1], the default, looks
%   for non-directional edges.
%
%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.26.4.5 $  $Date: 2003/08/01 18:08:50 $

[a,method,thresh,sigma,H,kx,ky] = parse_inputs(varargin{:});

% Transform to a double precision intensity image if necessary
if ~isa(a, 'double') 
  a = im2double(a);
end

m = size(a,1);
n = size(a,2);
rr = 2:m-1; cc=2:n-1;

% The output edge map:
e = repmat(false, m, n);

if strcmp(method,'canny')
  % Magic numbers
  GaussianDieOff = .0001;  
  PercentOfPixelsNotEdges = .7; % Used for selecting thresholds
  ThresholdRatio = .4;          % Low thresh is this fraction of the high.
  
  % Design the filters - a gaussian and its derivative
  
  pw = 1:30; % possible widths
  ssq = sigma*sigma;
  width = max(find(exp(-(pw.*pw)/(2*sigma*sigma))>GaussianDieOff));
  if isempty(width)
    width = 1;  % the user entered a really small sigma
  end

  t = (-width:width);
  gau = exp(-(t.*t)/(2*ssq))/(2*pi*ssq);     % the gaussian 1D filter

  % Find the directional derivative of 2D Gaussian (along X-axis)
  % Since the result is symmetric along X, we can get the derivative along
  % Y-axis simply by transposing the result for X direction.
  [x,y]=meshgrid(-width:width,-width:width);
  dgau2D=-x.*exp(-(x.*x+y.*y)/(2*ssq))/(pi*ssq);
  
  % Convolve the filters with the image in each direction
  % The canny edge detector first requires convolution with
  % 2D gaussian, and then with the derivitave of a gaussian.
  % Since gaussian filter is separable, for smoothing, we can use 
  % two 1D convolutions in order to achieve the effect of convolving
  % with 2D Gaussian.  We convolve along rows and then columns.

  %smooth the image out
  aSmooth=imfilter(a,gau,'conv','replicate');   % run the filter accross rows
  aSmooth=imfilter(aSmooth,gau','conv','replicate'); % and then accross columns
  
  %apply directional derivatives
  ax = imfilter(aSmooth, dgau2D, 'conv','replicate');
  ay = imfilter(aSmooth, dgau2D', 'conv','replicate');

  mag = sqrt((ax.*ax) + (ay.*ay));
  magmax = max(mag(:));
  if magmax>0
    mag = mag / magmax;   % normalize
  end
  
  % Select the thresholds
  if isempty(thresh) 
    [counts,x]=imhist(mag, 64);
    highThresh = min(find(cumsum(counts) > PercentOfPixelsNotEdges*m*n)) / 64;
    lowThresh = ThresholdRatio*highThresh;
    thresh = [lowThresh highThresh];
  elseif length(thresh)==1
    highThresh = thresh;
    if thresh>=1
      eid = sprintf('Images:%s:thresholdMustBeLessThanOne', mfilename);
      msg = 'The threshold must be less than 1.'; 
      error(eid,'%s',msg);
    end
    lowThresh = ThresholdRatio*thresh;
    thresh = [lowThresh highThresh];
  elseif length(thresh)==2
    lowThresh = thresh(1);
    highThresh = thresh(2);
    if (lowThresh >= highThresh) | (highThresh >= 1)
      eid = sprintf('Images:%s:thresholdOutOfRange', mfilename);
      msg = 'Thresh must be [low high], where low < high < 1.'; 
      error(eid,'%s',msg);
    end
  end
  
  % The next step is to do the non-maximum supression.  
  % We will accrue indices which specify ON pixels in strong edgemap
  % The array e will become the weak edge map.
  idxStrong = [];  
  for dir = 1:4
    idxLocalMax = cannyFindLocalMaxima(dir,ax,ay,mag);
    idxWeak = idxLocalMax(mag(idxLocalMax) > lowThresh);
    e(idxWeak)=1;
    idxStrong = [idxStrong; idxWeak(mag(idxWeak) > highThresh)];
  end
  
  rstrong = rem(idxStrong-1, m)+1;
  cstrong = floor((idxStrong-1)/m)+1;
  e = bwselect(e, cstrong, rstrong, 8);
  e = bwmorph(e, 'thin', 1);  % Thin double (or triple) pixel wide contours
  
elseif any(strcmp(method, {'log','marr-hildreth','zerocross'}))
  % We don't use image blocks here
  if isempty(H),
    fsize = ceil(sigma*3) * 2 + 1;  % choose an odd fsize > 6*sigma;
    op = fspecial('log',fsize,sigma); 
  else 
    op = H; 
  end
  
  op = op - sum(op(:))/prod(size(op)); % make the op to sum to zero
  b = filter2(op,a);
  
  if isempty(thresh)
    thresh = .75*mean2(abs(b(rr,cc)));
  end
  
  % Look for the zero crossings:  +-, -+ and their transposes 
  % We arbitrarily choose the edge to be the negative point
  [rx,cx] = find( b(rr,cc) < 0 & b(rr,cc+1) > 0 ...
                  & abs( b(rr,cc)-b(rr,cc+1) ) > thresh );   % [- +]
  e((rx+1) + cx*m) = 1;
  [rx,cx] = find( b(rr,cc-1) > 0 & b(rr,cc) < 0 ...
                  & abs( b(rr,cc-1)-b(rr,cc) ) > thresh );   % [+ -]
  e((rx+1) + cx*m) = 1;
  [rx,cx] = find( b(rr,cc) < 0 & b(rr+1,cc) > 0 ...
                  & abs( b(rr,cc)-b(rr+1,cc) ) > thresh);   % [- +]'
  e((rx+1) + cx*m) = 1;
  [rx,cx] = find( b(rr-1,cc) > 0 & b(rr,cc) < 0 ...
                  & abs( b(rr-1,cc)-b(rr,cc) ) > thresh);   % [+ -]'
  e((rx+1) + cx*m) = 1;
  
  % Most likely this covers all of the cases.   Just check to see if there
  % are any points where the LoG was precisely zero:
  [rz,cz] = find( b(rr,cc)==0 );
  if ~isempty(rz)
    % Look for the zero crossings: +0-, -0+ and their transposes
    % The edge lies on the Zero point
    zero = (rz+1) + cz*m;   % Linear index for zero points
    zz = find(b(zero-1) < 0 & b(zero+1) > 0 ...
              & abs( b(zero-1)-b(zero+1) ) > 2*thresh);     % [- 0 +]'
    e(zero(zz)) = 1;
    zz = find(b(zero-1) > 0 & b(zero+1) < 0 ...
              & abs( b(zero-1)-b(zero+1) ) > 2*thresh);     % [+ 0 -]'
    e(zero(zz)) = 1;
    zz = find(b(zero-m) < 0 & b(zero+m) > 0 ...
              & abs( b(zero-m)-b(zero+m) ) > 2*thresh);     % [- 0 +]
    e(zero(zz)) = 1;
    zz = find(b(zero-m) > 0 & b(zero+m) < 0 ...
              & abs( b(zero-m)-b(zero+m) ) > 2*thresh);     % [+ 0 -]
    e(zero(zz)) = 1;
  end

else  % one of the easy methods (roberts,sobel,prewitt)
  
  % Determine edges in blocks for easy methods 
  nr = length(rr); nc = length(cc);
  
  blk = bestblk([nr nc]);
  nblks = floor([nr nc]./blk); nrem = [nr nc] - nblks.*blk;
  mblocks = nblks(1); nblocks = nblks(2);
  mb = blk(1); nb = blk(2);
  
  if strcmp(method,'sobel')
    op = [-1 -2 -1;0 0 0;1 2 1]/8; % Sobel approximation to derivative
    x_mask = op'; % gradient in the X direction
    y_mask = op; 
    
    scale = 4; % for calculating the automatic threshold
    offset = [0 0 0 0]; % offsets used in the computation of the threshold
    
  elseif strcmp(method,'prewitt')
    op = [-1 -1 -1;0 0 0;1 1 1]/6; % Prewitt approximation to derivative
    x_mask = op';
    y_mask = op; 

    scale = 4;
    offset = [0 0 0 0];    
    
  elseif strcmp(method, 'roberts')
    op = [1 0;0 -1]/sqrt(2); % Roberts approximation to diagonal derivative
    x_mask = op;
    y_mask = rot90(op); 
    
    scale = 6;
    offset = [-1 1 1 -1];
    
  else
    
    eid = sprintf('Images:%s:invalidEdgeDetectionMethod', mfilename);
    msg = sprintf('%s %s',method, 'is not a valid method.' );
    error(eid,'%s',msg);
  end
  
  % compute the gradient in x and y direction
  bx = abs(filter2(x_mask,a));
  by = abs(filter2(y_mask,a));  
  
  % compute the magnitude
  b = kx*bx.*bx + ky*by.*by;
  
  % determine the threshold; see page 514 of "Digital Imaging Processing" by
  % William K. Pratt
  if isempty(thresh), % Determine cutoff based on RMS estimate of noise
                      % Mean of the magnitude squared image is a 
                      % value that's roughly proportional to SNR
    cutoff = scale*mean2(b(rr,cc));
    thresh = sqrt(cutoff);
  else                % Use relative tolerance specified by the user
    cutoff = (thresh).^2;
  end
  
  % compute the output image
  rows = 1:blk(1);
  for i=0:mblocks,
    if i==mblocks, 
      rows = (1:nrem(1)); 
    end
    for j=0:nblocks,
      if j==0, 
        cols = 1:blk(2);
      elseif j==nblocks,
        cols=(1:nrem(2)); 
      end
      if ~isempty(rows) & ~isempty(cols)
        r = rr(i*mb+rows); c = cc(j*nb+cols);
        e(r,c) = (b(r,c)>cutoff) & ...
                 (((bx(r,c) >= (kx*by(r,c)-eps*100)) & ...
                   (b(r+offset(1),c-1) <= b(r,c)) & ...
                   (b(r,c) > b(r+offset(2),c+1))) | ...
                  ((by(r,c) >= (ky*bx(r,c)-eps*100)) & ...
                   (b(r-1,c+offset(3)) <= b(r,c)) & ...
                   (b(r,c) > b(r+1,c+offset(4)))));
      end
    end
  end
  
end

if nargout==0,
  imshow(e);
else
  eout = e;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : cannyFindLocalMaxima
%
function idxLocalMax = cannyFindLocalMaxima(direction,ix,iy,mag);
%
% This sub-function helps with the non-maximum supression in the Canny
% edge detector.  The input parameters are:
% 
%   direction - the index of which direction the gradient is pointing, 
%               read from the diagram below. direction is 1, 2, 3, or 4.
%   ix        - input image filtered by derivative of gaussian along x 
%   iy        - input image filtered by derivative of gaussian along y
%   mag       - the gradient magnitude image
%
%    there are 4 cases:
%
%                         The X marks the pixel in question, and each
%         3     2         of the quadrants for the gradient vector
%       O----0----0       fall into two cases, divided by the 45 
%     4 |         | 1     degree line.  In one case the gradient
%       |         |       vector is more horizontal, and in the other
%       O    X    O       it is more vertical.  There are eight 
%       |         |       divisions, but for the non-maximum supression  
%    (1)|         |(4)    we are only worried about 4 of them since we 
%       O----O----O       use symmetric points about the center pixel.
%        (2)   (3)        


[m,n,o] = size(mag);

% Find the indices of all points whose gradient (specified by the 
% vector (ix,iy)) is going in the direction we're looking at.  

switch direction
 case 1
  idx = find((iy<=0 & ix>-iy)  | (iy>=0 & ix<-iy));
 case 2
  idx = find((ix>0 & -iy>=ix)  | (ix<0 & -iy<=ix));
 case 3
  idx = find((ix<=0 & ix>iy) | (ix>=0 & ix<iy));
 case 4
  idx = find((iy<0 & ix<=iy) | (iy>0 & ix>=iy));
end

% Exclude the exterior pixels
if ~isempty(idx)
  v = mod(idx,m);
  extIdx = find(v==1 | v==0 | idx<=m | (idx>(n-1)*m));
  idx(extIdx) = [];
end

ixv = ix(idx);  
iyv = iy(idx);   
gradmag = mag(idx);

% Do the linear interpolations for the interior pixels
switch direction
 case 1
  d = abs(iyv./ixv);
  gradmag1 = mag(idx+m).*(1-d) + mag(idx+m-1).*d; 
  gradmag2 = mag(idx-m).*(1-d) + mag(idx-m+1).*d; 
 case 2
  d = abs(ixv./iyv);
  gradmag1 = mag(idx-1).*(1-d) + mag(idx+m-1).*d; 
  gradmag2 = mag(idx+1).*(1-d) + mag(idx-m+1).*d; 
 case 3
  d = abs(ixv./iyv);
  gradmag1 = mag(idx-1).*(1-d) + mag(idx-m-1).*d; 
  gradmag2 = mag(idx+1).*(1-d) + mag(idx+m+1).*d; 
 case 4
  d = abs(iyv./ixv);
  gradmag1 = mag(idx-m).*(1-d) + mag(idx-m-1).*d; 
  gradmag2 = mag(idx+m).*(1-d) + mag(idx+m+1).*d; 
end
idxLocalMax = idx(gradmag>=gradmag1 & gradmag>=gradmag2); 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Local Function : parse_inputs
%
function [I,Method,Thresh,Sigma,H,kx,ky] = parse_inputs(varargin)
% OUTPUTS:
%   I      Image Data
%   Method Edge detection method
%   Thresh Threshold value
%   Sigma  standard deviation of Gaussian
%   H      Filter for Zero-crossing detection
%   kx,ky  From Directionality vector

error(nargchk(1,5,nargin,'struct'));

I = varargin{1};

checkinput(I,{'double','logical','uint8','uint16'},...
           {'nonsparse','2d'},mfilename,'I',1);

% Defaults
Method='sobel';
Thresh=[];
Direction='both';
Sigma=2;
H=[];
K=[1 1];

methods = {'canny','prewitt','sobel','marr-hildreth','log','roberts','zerocross'};
directions = {'both','horizontal','vertical'};

% Now parse the nargin-1 remaining input arguments

% First get the strings - we do this because the intepretation of the 
% rest of the arguments will depend on the method.
nonstr = [];   % ordered indices of non-string arguments
for i = 2:nargin
  if ischar(varargin{i})
    str = lower(varargin{i});
    j = strmatch(str,methods);
    k = strmatch(str,directions);
    if ~isempty(j)
      Method = methods{j(1)};
      if strcmp(Method,'marr-hildreth')  
        wid = sprintf('Images:%s:obsoleteMarrHildrethSyntax', mfilename);
        msg = '''Marr-Hildreth'' is an obsolete syntax, use ''LoG'' instead.';
        warning(wid,'%s',msg);
      end
    elseif ~isempty(k)
      Direction = directions{k(1)};
    else
      eid = sprintf('Images:%s:invalidInputString', mfilename);
      msg = sprintf('%s%s%s', 'Invalid input string: ''', varargin{i},'''.');
      error(eid,'%s',msg);
    end
  else
    nonstr = [nonstr i];
  end
end

% Now get the rest of the arguments 

eid_invalidArgs = sprintf('Images:%s:invalidInputArguments', mfilename);
msg_invalidArgs = 'Invalid input arguments';

switch Method
  
 case {'prewitt','sobel','roberts'}
  threshSpecified = 0;  % Threshold is not yet specified
  for i = nonstr
    if prod(size(varargin{i}))<=1 & ~threshSpecified % Scalar or empty
      Thresh = varargin{i};
      threshSpecified = 1;
    elseif prod(size(varargin{i}))==2  % The dreaded K vector
      wid = sprintf('Images:%s:obsoleteKDirectionSyntax', mfilename);
      msg = sprintf('%s%s%s', 'BW = EDGE(... , K) is an obsolete syntax. ',...
                    'Use BW = EDGE(... , DIRECTION),',...
                    ' where DIRECTION is a string.');
      warning(wid,'%s',msg);
      K=varargin{i};     
    else
      error(eid_invalidArgs,msg_invalidArgs);
    end
  end
  
 case 'canny'
  Sigma = 1.0;          % Default Std dev of gaussian for canny
  threshSpecified = 0;  % Threshold is not yet specified
  for i = nonstr
    if prod(size(varargin{i}))==2 & ~threshSpecified
      Thresh = varargin{i};
      threshSpecified = 1;
    elseif prod(size(varargin{i}))==1 
      if ~threshSpecified
        Thresh = varargin{i};
        threshSpecified = 1;
      else
        Sigma = varargin{i};
      end
    elseif isempty(varargin{i}) & ~threshSpecified
      % Thresh = [];
      threshSpecified = 1;
    else
      error(eid_invalidArgs,msg_invalidArgs);
    end
  end
  
 case 'log'
  threshSpecified = 0;  % Threshold is not yet specified
  for i = nonstr
    if prod(size(varargin{i}))<=1  % Scalar or empty
      if ~threshSpecified
        Thresh = varargin{i};
        threshSpecified = 1;
      else
        Sigma = varargin{i};
      end
    else
      error(eid_invalidArgs,msg_invalidArgs);
    end
  end
  
 case 'zerocross'
  threshSpecified = 0;  % Threshold is not yet specified
  for i = nonstr
    if prod(size(varargin{i}))<=1 & ~threshSpecified % Scalar or empty
      Thresh = varargin{i};
      threshSpecified = 1;
    elseif prod(size(varargin{i})) > 1 % The filter for zerocross
      H = varargin{i};
    else
      error(eid_invalidArgs,msg_invalidArgs);
    end
  end

 case 'marr-hildreth'
  for i = nonstr
    if prod(size(varargin{i}))<=1  % Scalar or empty
      Thresh = varargin{i};
    elseif prod(size(varargin{i}))==2  % The dreaded K vector 
      wid = sprintf('Images:%s:dirFactorHasNoEffectOnMarrHildreth', mfilename);
      msg = 'The [kx ky] direction factor has no effect for ''Marr-Hildreth''.';        
      warning(wid,'%s',msg);
    elseif prod(size(varargin{i})) > 2 % The filter for zerocross
      H = varargin{i};
    else
      error(eid_invalidArgs,msg_invalidArgs);
    end
  end
  
 otherwise
  error(eid_invalidArgs,msg_invalidArgs);
  
end   

if Sigma<=0
  eid = sprintf('Images:%s:sigmaMustBePositive', mfilename);
  msg = 'Sigma must be positive'; 
  error(eid,'%s',msg);
end

switch Direction
 case 'both',
  kx = K(1); ky = K(2); 
 case 'horizontal',
  kx = 0; ky = 1; % Directionality factor
 case 'vertical',
  kx = 1; ky = 0; % Directionality factor
 otherwise
  eid = sprintf('Images:%s:badDirectionString', mfilename);
  msg = 'Unrecognized direction string'; 
  error(eid,'%s',msg);
end
