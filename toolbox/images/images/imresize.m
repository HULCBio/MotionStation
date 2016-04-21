function varargout = imresize(varargin)
%IMRESIZE Resize image.
%   IMRESIZE resizes an image of any type using the specified
%   interpolation method. Supported interpolation methods
%   include:
%
%        'nearest'  (default) nearest neighbor interpolation
%
%        'bilinear' bilinear interpolation
%
%        'bicubic'  bicubic interpolation
%
%   B = IMRESIZE(A,M,METHOD) returns an image that is M times the
%   size of A. If M is between 0 and 1.0, B is smaller than A. If
%   M is greater than 1.0, B is larger than A. If METHOD is
%   omitted, IMRESIZE uses nearest neighbor interpolation.
%
%   B = IMRESIZE(A,[MROWS MCOLS],METHOD) returns an image of size
%   MROWS-by-MCOLS. If the specified size does not produce the
%   same aspect ratio as the input image has, the output image is
%   distorted.
%
%   When the specified output size is smaller than the size of
%   the input image, and METHOD is 'bilinear' or 'bicubic',
%   IMRESIZE applies a lowpass filter before interpolation to
%   reduce aliasing. The default filter size is 11-by-11.
%
%   You can specify a different order for the default filter
%   using:
%
%        [...] = IMRESIZE(...,METHOD,N)
%
%   N is an integer scalar specifying the size of the filter,
%   which is N-by-N. If N is 0, IMRESIZE omits the filtering
%   step.
%
%   You can also specify your own filter H using:
%
%        [...] = IMRESIZE(...,METHOD,H)
%
%   H is any two-dimensional FIR filter (such as those returned
%   by FTRANS2, FWIND1, FWIND2, or FSAMP2).
%
%   Class Support
%   -------------
%   The input image A can be numeric or logical and it must be 
%   nonsparse. The output image is of the same class as the 
%   input image.
%
%   See also IMROTATE, IMTRANSFORM, TFORMARRAY

%   Obsolete Syntaxes:
%
%   [R1,G1,B1] = IMRESIZE(R,G,B,M,'method') or 
%   [R1,G1,B1] = IMRESIZE(R,G,B,[MROWS NCOLS],'method') resizes
%   the RGB image in the matrices R,G,B.  'bilinear' is the
%   default interpolation method.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.30.4.3 $  $Date: 2003/08/23 05:52:41 $

[A,m,method,h] = parse_inputs(varargin{:});

% Preserve classes
inputClass = class(A);
classChanged = 0;
logicalIn = islogical(A);


% Define old and new image sizes, and actual scaling
[so(1),so(2),thirdD] = size(A);% old image size
if length(m)==1,% m is a multiplier
  sn = max(floor(m*so(1:2)),1);% new image size=(integer>0)
else            % m is new image size
  sn = m;
end

if any(sn<4) && any(sn<so) && method(1)~='n',
  fprintf('Input is too small for bilinear or bicubic method;\n');
  fprintf('using nearest-neighbor method instead.\n');
  method = 'nearest';
end

% Filtering is under the following conditions
bi_interp = (method(1)=='b'); % non-default interpolation only
defflt_reducedim=(length(h)<2)&any(sn<so);%default filter & reduced image
if length(h)==1,
  nonzero_odr = (h~=0);     % non-zero filter order
else 
  nonzero_odr = 1;
end;
custm_flt = (length(h)>1);%custom supplied filter H

if bi_interp && nonzero_odr && any([defflt_reducedim,custm_flt]),
  if (~isa(A,'double')),%change format to double to perform imfilter
    A = im2double(A);
    classChanged = 1;
  end
  
  if defflt_reducedim,%Design anti-aliasing filter for reduced image
    drec = find(sn<so);% find direction of filtering
    for k = drec,% create filter for drec-direction
      if isempty(h),% make filter order corresponding to scale
	h = 11;
      end;
      hh(k,:) = DesignFilter(h,sn(k)/so(k));
    end;
    if length(drec)==1,%filters in one direction only
      % first direction is column, second is row
      h = reshape(hh(k,:),(h-1)*(k==1)+1,(h-1)*(k==2)+1);
    else % filters in both directions
      for k=1:thirdD,%loop if A matrix is 3D
	      A(:,:,k) = imfilter(imfilter(A(:,:,k), hh(2,:),'replicate'),...
                                  hh(1,:).','replicate');
      end
    end;
  end;
  if custm_flt || (defflt_reducedim && (length(drec)==1)), % filters in one direction
    for k=1:thirdD,%loop if A matrix is 3D
        A(:,:,k) = imfilter(A(:,:,k),h,'replicate');
    end
  end;
end;

% Interpolation
if method(1)=='n', % nearest neighbor (default)
  sc = so./sn + eps;% actual scaling between images, eps is needed
  A = A(floor(sc(1)/2:sc(1):end)+1,floor(sc(2)/2:sc(2):end)+1,:);
else               % bilinear or bicubic
  sc = (so-1)./(sn-1);% scaling for tformarray
  boxA  = maketform('box',so,[0 0],so-1);
  boxB  = maketform('box',sn,[0 0],sn-1);
  scale = maketform('affine',diag(1./[sc 1]));

  T = maketform('composite',[fliptform(boxB),scale,boxA]);
  
  if strcmp(method,'bicubic')
    R = makeresampler('cubic','replicate');
  else
    R = makeresampler('linear','replicate');    
  end
  
  A = tformarray(A, T, R, [1 2], [1 2], sn, [], []);
end;

% Change format from double back to the original
if logicalIn,  % output should be logical (i.e. binary image)
  if ~islogical(A) % A became double because of imfilter, turn it back to logical
     A = A>.5;
  end
elseif classChanged,
  A = changeclass(inputClass, A);
end

% Output
if (nargout == 0)
  imshow(A);
elseif ((ndims(A)==3) && (nargout == 3))
  wid = 'Images:imresize:obsoleteSyntax';
  warning(wid, '%s', ['[R1,G1,B1] = IMRESIZE(R,G,B,...) is an obsolete syntax. ',...
  'Use a three-dimensional array to represent input and output RGB images.']);
  varargout{1} = A(:,:,1);
  varargout{2} = A(:,:,2);
  varargout{3} = A(:,:,3);
else
  varargout{1} = A;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [A,m,method,h] = parse_inputs(varargin)
% Outputs:  A       the input image
%           m       the resize scaling factor or the new size
%           method  interpolation method (nearest,bilinear,bicubic)
%           h       if 0, skip filtering; if non-zero scalar, use filter 
%                   of size h; if empty, use filter of size 11; 
%                   otherwise h is the anti-aliasing filter provided by user
% Defaults:
method = 'nearest';
h = [];

error(nargchk(2,6,nargin,'struct'));
switch nargin
case 2,                   % imresize(A,m)
   A = varargin{1};
   m = varargin{2};
case 3,                   % imresize(A,m,method)
   A = varargin{1};
   m = varargin{2};
   method = varargin{3};
case 4,
   if ischar(varargin{3}), % imresize(A,m,method,h)
      A = varargin{1};
      m = varargin{2};
      method = varargin{3};
      h = varargin{4};
   else                   % imresize(r,g,b,m) OBSOLETE
      wid = 'Images:imresize:obsoleteSyntax';
      warning(wid, '%s', ['IMRESIZE(R,G,B,M) is an obsolete syntax.',...
      'Use a three-dimensional array to represent RGB image.']);
      A = cat(3,varargin{1},varargin{2},varargin{3});
      m = varargin{4};
   end
case 5,                   % imresize(r,g,b,m,'method')  OBSOLETE
   wid = 'Images:imresize:obsoleteSyntax';
   warning(wid, '%s', ['IMRESIZE(R,G,B,M,''method'') is an obsolete syntax. ',...
   'Use a three-dimensional array to represent RGB image.']);
   A = cat(3,varargin{1},varargin{2},varargin{3});
   m = varargin{4};
   method = varargin{5};
case 6,                   % imresize(r,g,b,m,'method',h)  OBSOLETE
   wid = 'Images:imresize:obsoleteSyntax';
   warning(wid, '%s', ['IMRESIZE(R,G,B,M,''method'',H) is an obsolete syntax.',...
   'Use a three-dimensional array to represent RGB image.']);
   A = cat(3,varargin{1},varargin{2},varargin{3});
   m = varargin{4};
   method = varargin{5};
   h = varargin{6};
otherwise,
   eid = 'Images:imresize:invalidInputs';
   error(eid, '%s', 'Invalid input arguments.');
end

checkinput(A,{'numeric', 'logical'},{'nonsparse'},mfilename,'A',1);

% Check validity of the input parameters 
if isempty(m) || (ndims(m)>2) || any(m<=0) || length(m(:))>2,
  eid = 'Images:imresize:invalidScaleFactor';
  error(eid, '%s', 'M must be either a scalar multiplier or a 1-by-2 size vector.');
elseif length(m)==2,% make sure that m is a row of non-negative integers
  m = ceil(m(:).');
end;

if ischar(method),
  strings = {'nearest','bilinear','bicubic'};
  idx = strmatch(lower(method),strings);
  if isempty(idx),
    eid = 'Images:imresize:unrecognizedInterpolationMethod';
    error(eid, 'Unknown interpolation method: %s', method);
  elseif length(idx)>1,
    eid = 'Images:imresize:ambiguousInterpolationMethod';
    error(eid, '%s', 'Ambiguous interpolation method: %s',method);
  else
    method = strings{idx};
  end  
else
  eid = 'Images:imresize:expectedString';
  error(eid, '%s', 'Interpolation method has to be a string.');
end;
  
if length(h)==1,% represents filter order
  if (h<0) || (h~=round(h)),
    eid = 'Images:imresize:invalidFilterOrder';
    error(eid, 'Filter order has to be a non-negative integer, not %g',h);
  end;
elseif (length(h)>1) && (ndims(h)>2),% custom supplied filter
  eid = 'Images:imresize:expected2DFilter';
  error(eid, '%s', 'Filter has to be a 2-D array.');
end

function b = DesignFilter(N,Wn)
% Modified from SPT v3 fir1.m and hanning.m
% first creates only first half of the filter 
% and later mirrows it to the other half

odd = rem(N,2);
vec = 1:floor(N/2);
vec2 = pi*(vec-(1-odd)/2);

wind = .54-.46*cos(2*pi*(vec-1)/(N-1));
b = [fliplr(sin(Wn*vec2)./vec2).*wind Wn];% first half is ready
b = b([vec floor(N/2)+(1:odd) fliplr(vec)]);% entire filter
b = b/abs(polyval(b,1));% norm

