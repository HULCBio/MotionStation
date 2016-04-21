function varargout = rgb2ntsc(varargin)
%RGB2NTSC Convert RGB values to NTSC colorspace.
%   YIQMAP = RGB2NTSC(RGBMAP) converts the M-by-3 RGB values in
%   RGBMAP to NTSC colorspace. YIQMAP is an M-by-3 matrix that
%   contains the NTSC luminance (Y) and chrominance (I and Q)
%   color components as columns that are equivalent to the colors
%   in the RGB colormap.
%
%   YIQ = RGB2NTSC(RGB) converts the truecolor image RGB to the
%   equivalent NTSC image YIQ.
%
%   Class Support
%   -------------
%   RGB can be uint8,uint16 or double; RGBMAP can be double.  The output is
%   double.
%
%   Examples
%   --------
%      I = imread('board.tif');
%      J = rgb2ntsc(I);
%
%      map = jet(256);
%      newmap = rgb2ntsc(map);

%   See also NTSC2RGB, RGB2IND, IND2RGB, IND2GRAY.

%   Copyright 1993-2003 The MathWorks, Inc.  
%   $Revision: 5.17.4.2 $  $Date: 2003/01/26 06:01:23 $

A = parse_inputs(varargin{:});

T = [1.0 0.956 0.621; 1.0 -0.272 -0.647; 1.0 -1.106 1.703].';
[so(1) so(2) thirdD] = size(A);
if thirdD == 1,% A is RGBMAP, M-by-3 colormap
  A = A/T;
else % A is truecolor image RBG
  A = reshape(reshape(A,so(1)*so(2),thirdD)/T,so(1),so(2),thirdD);
end;

% Output
if nargout < 2,%              YIQMAP = RGB2NTSC(RGBMAP)
  varargout{1} = A;
elseif  nargout == 3,%       [Y,I,Q] = RGB2NTSC(RGB) OBSOLETE
  if thirdD == 1,
    eid = sprintf('Images:%s:wrongNumberOfOutputArguments', mfilename);
    msg = 'YIQMAP = RGB2NTSC(RGBMAP) must have one output argument.';
    error(eid,'%s',msg);
  else
    wid = sprintf('Images:%s:obsoleteOutputSyntax', mfilename);
    msg = ['[Y,I,Q] = RGB2NTSC(RGB) is an obsolete output syntax. ',...
           'Use a three-dimensional array to represent YIQ image.'];
    warning(wid,'%s',msg);
  end;
  for k = 1:3,
    varargout{k} = A(:,:,k);
  end;
else 
  eid = sprintf('Images:%s:wrongNumberOfOutputArguments', mfilename);
  msg = sprintf('RGB2NTSC cannot return %d output arguments.', nargout);
  error(eid,'%s',msg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  Function: parse_inputs
%

function A = parse_inputs(varargin)

checknargin(1,3,nargin,mfilename);

switch nargin
 case 1
  % rgb2ntsc(RGB) or rgb2ntsc(RGBMAP)
  A = varargin{1};
 case 2
  eid = sprintf('Images:%s:wrongNumberOfInputs',mfilename);
  msg = 'Two input arguments are not allowed';
  error(eid,'%s',msg);
 case 3
  % rgb2ntsc(R,G,B) OBSOLETE
  wid = sprintf('Images:%s:obsoleteInputSyntax',mfilename);
  msg = ['RGB2NTSC(R,G,B) is an obsolete syntax. ',...
         'Use a three-dimensional array to represent RGB image.'];
  warning(wid,'%s',msg);
  %check class
  if ( strcmp(class(varargin{1}),class(varargin{2})) == 0 || ...
        strcmp(class(varargin{1}),class(varargin{3})) == 0 )
    eid = sprintf('Images:%s:inputsHaveDifferentClass',mfilename);
    msg = 'R, G, and B arrays must have the same class.';
    error(eid,'%s',msg);
  end
 
  if isequal(size(varargin{1}),size(varargin{2}),size(varargin{3})),
    A = cat(3,varargin{1},varargin{2},varargin{3});
  else
    eid = sprintf('Images:%s:unequalSizes',mfilename);
    msg = 'R, G, and B arrays must have the same size.';
    error(eid,'%s',msg);
  end
end


%no logical
if islogical(A)
  eid = sprintf('Images:%s:invalidType',mfilename);
  msg = 'A truecolor image cannot be logical.';
  error(eid,'%s',msg);
end

% Check validity of the input parameters 
if ndims(A)==2 
  % Check colormap 
  id = sprintf('Images:%s:invalidColormap',mfilename);
  if ( size(A,2)~=3 || size(A,1) < 1 ) 
    msg = 'RGBMAP must be an M-by-3 array.';
    error(id,'%s',msg);
  end
  if ~isa(A,'double')
    msg = ['MAP should be a double m x 3 array with values in the range [0,1].'...
           'Convert your map to double using IM2DOUBLE.'];
    warning(id,'%s',msg);
    A = im2double(A);
  end
elseif ndims(A)==3
  % Check RGB
  if size(A,3)~=3
    eid = sprintf('Images:%s:invalidTruecolorImage',mfilename);
    msg = 'RGB image must be an M-by-N-by-3 array.';
    error(eid,'%s',msg);
  end
  A = im2double(A);
else
  eid = sprintf('Images:%s:invalidSize',mfilename);
  msg = 'RGB2NTSC only accepts a 2-D input for RGBMAP and a 3-D input for RGB.';
  error(eid,'%s',msg);
end

% A has to be double because YIQ colorspace can contain negative values.
if ~isa(A, 'double')
  A = im2double(A); 
end
