function varargout = imrotate(varargin)
%IMROTATE Rotate image.
%   B = IMROTATE(A,ANGLE,METHOD) rotates the image A by ANGLE
%   degrees in a counter-clockwise direction, using the specified
%   interpolation method. METHOD is a string that can have one of
%   these values:
%
%        'nearest'  (default) nearest neighbor interpolation
%
%        'bilinear' bilinear interpolation
%
%        'bicubic'  bicubic interpolation
%
%   If you omit the METHOD argument, IMROTATE uses the default
%   method of 'nearest'. To rotate the image clockwise, specify a
%   negative angle.
%
%   B = IMROTATE(A,ANGLE,METHOD,BBOX) rotates the image A through ANGLE
%   degrees. The bounding box of the image is set by the BBOX argument, a
%   string that can be 'loose' (default) or 'crop'. When BBOX is 'loose', B
%   includes the whole rotated image, which generally is larger than A. When
%   BBOX is 'crop' B is cropped to include only the central portion of the
%   rotated image and is the same size as A. If you omit the BBOX argument,
%   IMROTATE uses the default 'loose' bounding box.
%
%   IMROTATE sets invalid values on the periphery of B to 0. 
%
%   Class Support
%   -------------
%   The input image can be numeric or logical.  The output image is of the
%   same class as the input image.
%
%   Example
%   -------
%        I = fitsread('solarspectra.fts');
%        I = mat2gray(I);
%        J = imrotate(I,-1,'bilinear','crop');
%        imview(I), imview(J)
%
%   See also IMCROP, IMRESIZE, IMTRANSFORM, TFORMARRAY.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.25.4.5 $  $Date: 2003/08/23 05:52:42 $

% Grandfathered:
%   Without output arguments, IMROTATE(...) displays the rotated
%   image in the current axis.  

[A,ang,method,bbox] = parse_inputs(varargin{:});

[so(1) so(2) thirdD] = size(A);

if rem(ang,90)==0,% Catch and speed up 90 degree rotations
  phi = round(ang - 360*floor(ang/360));% remove 2pi rotations
  drec = find(phi/90==(0:3));
  v = {':',':',':'};
  if any(drec==[2 4]),% +- 90 deg rotation
    if (bbox(1)=='c') && (so(1)~=so(2)),%crop non-square image
      B = zeros(so(1), so(2), thirdD, class(A));  
      imbegin = (max(so)==so)*abs(diff(floor(so/2)));
      vec = 1:min(so);
      v(1) = {imbegin(1)+vec};
      v(2) = {imbegin(2)+vec};
    end;% for square or nocrop non-square image v stays the same
    for k = 1:thirdD,
      B(v{1},v{2},k) = rot90(A(v{1},v{2},k),drec-1);
    end
  else % zero rotation or simple flipud
    if drec==3,% simple flipud+fliplr
      v(1) = {so(1):-1:1};
      v(2) = {so(2):-1:1};
    end
    B = A(v{:});
  end
else % use tformarray
  phi = ang*pi/180; % Convert to radians
  
  rotate = maketform('affine',[ cos(phi)  sin(phi)  0; ...
                               -sin(phi)  cos(phi)  0; ...
                                    0       0       1 ]);

  % Coordinates from center of A
  hiA = (so-1)/2;
  loA = -hiA;
  if bbox(1)=='l'  % Determine limits for rotated image
    hiB = ceil(max(abs(tformfwd([loA(1) hiA(2); hiA(1) hiA(2)],rotate)))/2)*2;
    loB = -hiB;
    sn = hiB - loB + 1;
  else % Cropped image
    hiB = hiA;
    loB = loA;
    sn = so;
  end
  
  boxA = maketform('box',so,loA,hiA);
  boxB = maketform('box',sn,loB,hiB);
  T = maketform('composite',[fliptform(boxB),rotate,boxA]);
  
  if strcmp(method,'bicubic')
    R = makeresampler('cubic','fill');
  elseif strcmp(method,'bilinear')
    R = makeresampler('linear','fill');
  else
    R = makeresampler('nearest','fill');
  end

  B = tformarray(A, T, R, [1 2], [1 2], sn, [], 0);
  
end

   
% Output
switch nargout,
case 0,
  wid = 'Images:imrotate:obsoleteSyntax';    
  warning(wid, '%s', ['Obsolete syntax. In future versions IMROTATE ',... 
  'will return the result in ans instead of displaying it in figure.']);
  imshow(B);
case 1,
  varargout{1} = B;
case 3,
  wid = 'Images:imrotate:obsoleteSyntax';    
  warning(wid, '%s', ['[R,G,B] = IMROTATE(RGB) is an obsolete output syntax. ',...
  'Use one output argument the receive the 3-D output RGB image.']);
  for k=1:3,
    varargout{k} = B(:,:,k);
  end;
otherwise,
  eid = 'Images:imrotate:tooManyOutputs';    
  error(eid, '%s', 'Invalid number of output arguments.');
end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function [A,ang,method,bbox] = parse_inputs(varargin)
% Outputs:  A       the input image
%           ang     the angle by which to rotate the input image
%           method  interpolation method (nearest,bilinear,bicubic)
%           bbox    bounding box option 'loose' or 'crop'

% Defaults:
method = 'n';
bbox = 'l';

error(nargchk(2,4,nargin,'struct'));
switch nargin
case 2,             % imrotate(A,ang)        
  A = varargin{1};
  ang=varargin{2};
case 3,             % imrotate(A,ang,method) or
  A = varargin{1};  % imrotate(A,ang,box)
  ang=varargin{2};
  method=varargin{3};
case 4,             % imrotate(A,ang,method,box) 
  A = varargin{1};
  ang=varargin{2};
  method=varargin{3};
  bbox=varargin{4};
otherwise,
  eid = 'Images:imrotate:invalidInputs';    
  error(eid, '%s', 'Invalid input arguments.');
end

% Check validity of the input parameters 
if ischar(method) && ischar(bbox),
  strings = {'nearest','bilinear','bicubic','crop','loose'};
  idx = strmatch(lower(method),strings);
  if isempty(idx),
    eid = 'Images:imrotate:unrecognizedInterpolationMethod';
    error(eid, 'Unknown interpolation method: %s', method);
  elseif length(idx)>1,
    eid = 'Images:imrotate:ambiguousInterpolationMethod';
    error(eid, 'Ambiguous interpolation method: %s', method);
  else
    if idx==4,bbox=strings{4};method=strings{1};
    elseif idx==5,bbox = strings{5};method=strings{1};
    else method = strings{idx};
    end
  end  
  idx = strmatch(lower(bbox),strings(4:5));
  if isempty(idx),
    eid = 'Images:imrotate:unrecognizedBBox';
    error(eid, 'Unknown BBOX parameter: %s', bbox);
  elseif length(idx)>1,
    eid = 'Images:imrotate:ambiguousBBox';
    error(eid, 'Ambiguous BBOX string: %s', bbox);
  else
    bbox = strings{3+idx};
  end 
else
  eid = 'Images:imrotate:expectedString';
  error(eid, '%s', 'Interpolation method and BBOX have to be a string.');  
end
