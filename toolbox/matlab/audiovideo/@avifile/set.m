function obj = set(obj,varargin)
%SET Set properties of AVIFILE objects.
%
% OBJ = SET(OBJ,'PropertyName',VALUE) sets the property 'PropertyName' of
% the AVIFILE object OBJ to the value VALUE.  
%
% OBJ = SET(OBJ,'PropertyName',VALUE,'PropertyName',VALUE,..) sets multiple
% property values of the AVIFILE object OBJ with a single statement.
%
%   Note: This function is a helper function for SUBSASGN and not intended
%   for users.  Structure notation should be used to set property values of
%   AVIFILE objects.  For example:
%
%       obj.Fps = value;
%

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/30 13:06:50 $

if nargout ~=1
  error('You must use the syntax obj=set(obj,....).');
end

if rem(length(varargin),2)
  error('The property/value inputs must always occur as pairs.');
end

numPairs = length(varargin)/2;
  
paramNames =  {'fps','compression','quality','colormap','videoname',...
               'keyframepersec'};
paramSetFcns = {'setFps','setCompression','setQuality', ...
                'setColormap','setName','setKeyFrame'};

[params,idx] = sort(varargin(1:2:end));
values = varargin(2:2:end);
values = values(idx);

for i = 1:numPairs
  match = strmatch(lower(params{i}),paramNames);
  switch length(match)
   case 1
    obj = feval(paramSetFcns{match},obj,values{i});
   case 0
    error(sprintf('Unrecognized parameter name ''%s''.', params{i}));
   otherwise % more than one match
    msg = sprintf('Ambiguous parameter name ''%s''.', params{i});
    error(msg);
  end % switch
end
return;

% ------------------------------------------------------------------------
function obj = setKeyFrame(obj,value)

if obj.MainHeader.TotalFrames ~= 0
  error('The key frame rate must be set before calling ADDFRAME.');
end

if value <= 0
  error('The number of key frames per second must be greater than zero.');
end

% Convert number of key frames per second to key frames per N frames
obj.KeyFrameEveryNth = floor(1/(obj.MainHeader.Fps/10^6)/value);
return;

% ------------------------------------------------------------------------
function obj = setName(obj,value)
% Set a descriptive name to the video stream.

if obj.MainHeader.TotalFrames ~= 0
  error('The name must be set before calling ADDFRAME.');
end

if ~isa(value,'char')
  error('The stream name must be a string.');
end

if length(value) > 64
  error('The video stream name must be no more than 64 characters long');
end

% Calculate size difference from current frame
dif = length(obj.StreamName) - length(value) + 1;

obj.StreamName = value;
if isunix
  obj.Sizes.strnsize = length(value)+1+8;
end
return;

% ------------------------------------------------------------------------
function obj = setFps(obj, value)

if obj.MainHeader.TotalFrames ~= 0
  error('Fps must be set before calling ADDFRAME.');
end

if value <= 0
  error('The number of frames per second must be greater than zero.');
end

if value<1 & strcmp(obj.StreamHeader.fccHandler,'iv32')
  error('FPS must be 1 or greater for compression with Indeo3.');
end

% The number of key frames per second needs to be updated
CurrentKeyFramePerSec = 10^6/obj.MainHeader.Fps/obj.KeyFrameEveryNth;
obj.KeyFrameEveryNth = value/CurrentKeyFramePerSec;

% Fps is stored in micro seconds per frame
obj.MainHeader.Fps = 10^6/value;
obj.MainHeader.Rate = value*100;
obj.StreamHeader.Rate = value*100;

return;

% ------------------------------------------------------------------------
function obj = setCompression(obj,value)

if isunix & ~strcmp(lower(value),'none')
  error('Only uncompressed AVI files can be written on UNIX.');
end

msg = 'Compressor must be ''Cinepak'', ''Indeo3'', ''Indeo5'', ''MSVC'','', ''RLE'', ''None'', or a four charater compression code (fourcc).';

if ~isa(value,'char')
  error(msg);
end

% The compression must be set before the first frame is added to the file.
if obj.MainHeader.TotalFrames ~= 0
  error('Compression must be set before any frames are added.');
end

switch lower(value)
 case 'none'
  obj.Compression = 0;
  obj.StreamHeader.fccHandler = 'DIB ';
  obj.Bitmapheader.biCompression = 'DIB ';
 case 'rle'
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = 'MRLE';
  obj.Bitmapheader.biCompression = 'mrle';
 case 'cinepak'
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = 'cvid';
  fourcc = 'cvid';
  obj.Bitmapheader.biCompression = fourcc;
 case 'indeo3'
  if 10^6/obj.MainHeader.Fps<1
    error('FPS must be 1 or greater with Indeo3.');
  end
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = 'iv32';
  fourcc = 'iv32';
  obj.Bitmapheader.biCompression = fourcc;
 case 'indeo5'
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = 'iv50';
  fourcc = 'iv50';
  obj.Bitmapheader.biCompression = fourcc;
 case 'msvc'
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = 'msvc';
  fourcc = 'msvc';
  obj.Bitmapheader.biCompression = fourcc;
 otherwise
  if( size(value,2) ~= 4 )
    error(msg);
  end
  obj.Compression = 1;
  obj.StreamHeader.fccHandler = value;
  obj.Bitmapheader.biCompression = value;
  warning('Not a supported compression method.  An attempt will be made to use this compressor.');
end
return;

% ------------------------------------------------------------------------
function obj = setQuality(obj,value)

if ~isa(value,'numeric')
  error('Quality must be a number.');
end

if obj.MainHeader.TotalFrames ~= 0
  error('Quality must be set before any frames are added.');
end

if (value >= 0) & (value <= 100)
  value = value*100;
  obj.StreamHeader.Quality = value;
else
  error('Quality must be in the range of 1 to 100');
end
return;

% ------------------------------------------------------------------------
function obj = setColormap(obj,map)

if obj.MainHeader.TotalFrames ~= 0
  error('The Colormap must be set before any frames are added.');
end

if obj.Bitmapheader.biBitCount  == 24
  error('Unable to set colormap for a TrueColor image.');
end

if size(map,1) > 256
  error('Colormap must no more than 256 entries.');
end

if size(map,2) ~= 3
  error('Colormap must have three columns.');
end

obj.Bitmapheader.biBitCount = 8;
obj.Bitmapheader.biClrUsed = size(map,1);

map = round(map*255);
obj.Bitmapheader.Colormap = uint8([fliplr(map), ...
       zeros(size(map,1),1)]');
return;
