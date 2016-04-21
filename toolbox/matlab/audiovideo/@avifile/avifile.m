function aviobj = avifile(filename,varargin)
%AVIFILE Create a new AVI file
%   AVIOBJ = AVIFILE(FILENAME) creates an AVIFILE object AVIOBJ with the
%   default parameter values.  If FILENAME does not include an extension,
%   then '.avi' will be used.  Use AVIFILE/CLOSE to close the file opened by
%   AVIFILE.  Use "clear mex" to close all open AVI files.
%
%   AVIOBJ = AVIFILE(FILENAME,'PropertyName',VALUE,'PropertyName',VALUE,...)
%   returns an AVIFILE object with the specified property values.
%
%   AVIFILE parameters
%
%   FPS         - The frames per second for the AVI movie. This parameter
%   must be set before using ADDFRAME. The default is 15 fps.
%
%   COMPRESSION - A string indicating the compressor to use.  On UNIX, this
%   value must be 'None'.  Valid values for this parameter on Windows are
%   'Indeo3', 'Indeo5', 'Cinepak', 'MSVC', 'RLE' or 'None'.
%
%   To use a custom compressor, the value can be the four character code as
%   specified by the codec documentation. An error will result during the
%   call to ADDFRAME if it can not find the specified custom compressor. 
%   This parameter must be set before using ADDFRAME. 
%   The default is 'Indeo5' on Windows and 'None' on UNIX.
%
%   QUALITY      - A number between 0 and 100. This parameter has no effect
%   on uncompressed movies. This parameter must be set before using
%   ADDFRAME. Higher quality numbers result in higher video quality and
%   larger file sizes, where lower quality numbers result in lower video
%   quality and smaller file sizes.  The default is 75. 
%
%   KEYFRAME     - For compressors that support temporal compression, this
%   is the number of key frames per second.  This parameter must be set
%   before using ADDFRAME.  The default is 2 key frames per second.
%
%   COLORMAP     - An M-by-3 matrix defining the colormap to be used for indexed
%   AVI movies.  M must be no greater than 256 (236 if using Indeo
%   compression). This parameter must be set before calling ADDFRAME, unless
%   you are using ADDFRAME with the MATLAB movie syntax.  There is no
%   default colormap.
%
%   VIDEONAME    - A descriptive name for the video stream.  This parameter
%   must be no greater than 64 characters long and must be set before using
%   ADDFRAME. The default is the filename. 
%
%
%   AVIFILE properties may also be set using MATLAB structure syntax.  For
%   example, to set the Quality property to 100 use the following syntax: 
%
%      aviobj = avifile(filename);
%      aviobj.Quality = 100;
%
% 
%   Example:
%
%      fig=figure;
%      set(fig,'DoubleBuffer','on');
%      set(gca,'xlim',[-80 80],'ylim',[-80 80],...
%      	   'NextPlot','replace','Visible','off')
%      mov = avifile('example.avi')
%      x = -pi:.1:pi;
%      radius = [0:length(x)];
%      for i=1:length(x)
%      	h = patch(sin(x)*radius(i),cos(x)*radius(i),[abs(cos(x(i))) 0 0]);
%      	set(h,'EraseMode','xor');
%      	F = getframe(gca);
%      	mov = addframe(mov,F);
%      end
%      mov = close(mov);
%
%   See also AVIFILE/ADDFRAME, AVIFILE/CLOSE, and MOVIE2AVI.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/03/30 13:06:31 $
       
if nargin == 0
  error('You must provide a filename as the input.');
elseif ~isa(filename,'char')
  error('The first input argument must be a filename.');
end

FramesPerSec = 15;
Quality = 7500;

%Global defaults
aviobj.Filename = '';
if isunix
  aviobj.Compression = 0;
else
  aviobj.Compression = 1;
end
aviobj.FileHandle = [];
aviobj.TempDataFile = [tempname '.tmp'];
aviobj.PrevFrame = [];
aviobj.StreamName = filename;
% 2 Key frames per second is the default
aviobj.KeyFrameEveryNth = floor(FramesPerSec/2); 
aviobj.CurrentState = 'Open';

% Other defaults 
aviobj.MainHeader.Fps= 1/FramesPerSec*10^6; % Microseconds per frame, 15 fps
aviobj.MainHeader.MaxBytesPerSec=1000000;
aviobj.MainHeader.Reserved=0;
aviobj.MainHeader.Flags= 16; % AVIF_HASINDEX from vfw.h
aviobj.MainHeader.TotalFrames=0;
aviobj.MainHeader.InitialFrames= 0;
aviobj.MainHeader.Streams= 1;
aviobj.MainHeader.SuggestedBufferSize=0;
aviobj.MainHeader.Width=0;
aviobj.MainHeader.Height=0;
aviobj.MainHeader.Scale=100; % Rate/Scale = Samples per second
aviobj.MainHeader.Rate=FramesPerSec*100;
aviobj.MainHeader.Start=0;
aviobj.MainHeader.Length=0;

% Default stream header, from VFW Programmer's Guide
aviobj.StreamHeader.fccType = 'vids';
if isunix
  aviobj.StreamHeader.fccHandler =  'DIB ';
else
  aviobj.StreamHeader.fccHandler =  'iv50';
end
aviobj.StreamHeader.Flags = 0;
aviobj.StreamHeader.Reserved = 0;
aviobj.StreamHeader.InitialFrames = 0;
aviobj.StreamHeader.Scale = 100;
aviobj.StreamHeader.Rate = FramesPerSec*100;;
aviobj.StreamHeader.Start = 0;
aviobj.StreamHeader.Length = 0;
aviobj.StreamHeader.SuggestedBufferSize = 0;
aviobj.StreamHeader.Quality = Quality;
aviobj.StreamHeader.SampleSize =  0;

% Default data header
aviobj.Bitmapheader.biSize = 40;
aviobj.Bitmapheader.biWidth =0;
aviobj.Bitmapheader.biHeight =0;
aviobj.Bitmapheader.biPlanes =1;
aviobj.Bitmapheader.biBitCount =0;
if isunix
  aviobj.Bitmapheader.biCompression ='DIB ';
else
  aviobj.Bitmapheader.biCompression ='iv50';
end
aviobj.Bitmapheader.biSizeImage = 0;
aviobj.Bitmapheader.biXPelsPerMeter =0;
aviobj.Bitmapheader.biYPelsPerMeter =0;
aviobj.Bitmapheader.biClrUsed =0;
aviobj.Bitmapheader.biClrImportant =0;
aviobj.Bitmapheader.Colormap = [];

[path,name,ext] = fileparts(filename);
if isempty(ext)
  filename = strcat(filename,'.avi');
end

aviobj.Filename = filename;

if ispc
  aviobj = class(aviobj,'avifile');
  % Take care of any parameters set at the command line
  aviobj = set(aviobj,varargin{:});
  aviobj.FileHandle = avi('open',filename);
end

if isunix
  aviobj.Sizes = getchunksizes(aviobj);
  
  aviobj = class(aviobj,'avifile');
  % Take care of any parameters set at the command line
  aviobj = set(aviobj,varargin{:});

  fid = fopen(aviobj.TempDataFile,'a','l');
  if fid == -1
    error(['Error creating temporary file' aviobj.TempDataFile '.  Check directory permissions. ']);
  end
  fclose(fid);
  
  fid = fopen(aviobj.Filename,'a','l');
  if fid == -1
    error('Error creating AVI file. Check directory permissions.');
  end
  fclose(fid);
end

return;

function sizes = getchunksizes(aviobj)

% The sizes structure sizes holds the current chunk size
% information in the AVIOBJ.  This structure is updated as frames are added
% to the AVI file.  
% The numbers stored in this structure include the ckid and cksize so 8
% bytes must be subtracted when writing the chunk or list size to the file
% (in CLOSE).  The header sizes can be calculated from vfw.h.

% This is the size of the MainAVIHeaderr taken from vfw.h
sizes.avihsize = 64;

% strn is the stream name chunk
sizes.strnsize = 8+length(aviobj.StreamName) +1;

% Determine number of bytes in strl LIST
% -------------------------------------
%  'LIST'              4 bytes
%  size                4 bytes
%  'strl'              4 bytes
%  'strh'              4 bytes
%  size                4 bytes
%  <stream header>     48 bytes
%  'strf'              4 bytes
%  size                4 bytes
%  <stream format>     40 bytes + Colormap
% 'strn'               4 bytes  !!!NOT YET COUNTED 
% size                 4 bytes  !!!NOT YET COUNTED 
% <stream name>        N bytes  !!!NOT YET COUNTED 
%
%  Total               116 + Colormap
sizes.strllist = 116;

% Determine number of bytes in strh chunk
% -------------------------------------
%  'strh'              4 bytes
%  size                4 bytes
%  <stream header>     48 bytes
%
%  Total               56 bytes
sizes.strhsize = 56;

% Determine number of bytes in strf chunk
% -------------------------------------
%  'strf'              4 bytes
%  size                4 bytes
%  <stream format>     40 bytes + Colormap
%
%  Total               48 + Colormap
sizes.strfsize = 48;


% Determine number of bytes in hdrl LIST
% -------------------------------------
%  avihsize
%  strllist
%  'LIST'               4 bytes
%  size                 4 bytes
%  'hdrl'               4 bytes
%
sizes.hdrllist = sizes.avihsize + ...
    sizes.strllist +12;  

% Determine number of bytes in movi LIST
% -------------------------------------
%  'LIST'               4 bytes
%  size                 4 bytes
%  'movi'               4 bytes
%  <movie data>         N
sizes.movilist = 12; 

% Determine number of bytes in idx1 chunk
% -------------------------------------
%  'strf'              4 bytes
%  size                4 bytes
sizes.idx1size = 8; 

% Determine number of bytes in RIFF chunk
% -------------------------------------
%  hdrllist
%  movilist
%  idx1size
%  'AVI'               4 bytes
sizes.riffsize = sizes.hdrllist+ ...
    sizes.movilist+ sizes.idx1size + 4; 
return;
