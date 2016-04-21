function fileinfo = aviinfo(filename,outputType)
%AVIINFO Information about AVI file
%   FILEINFO = AVIINFO(FILENAME) returns a structure whose fields contain
%   information about the AVI file. FILENAME is a string that specifies the
%   name of the AVI file.  If FILENAME does not include an extension, then
%   '.avi' will be used.  The file must be in the current working directory
%   or in a directory on the MATLAB path. 
%
%   The set of fields for FILEINFO are:
%   
%   Filename           - A string containing the name of the file
%   		      
%   FileSize           - An integer indicating the size of the file
%                     	in bytes
%   		      
%   FileModDate        - A string containing the modification date of the file
%   		      
%   NumFrames          - An integer indicating the total number of frames in the
%                     	 movie 
%   		      
%   FramesPerSecond    - An integer indicating the desired frames per second
%                     	 during playback
%   		      
%   Width              - An integer indicating the width of AVI movie in
%                     	 pixels
%   		      
%   Height             - An integer indicating the height of AVI movie in
%                     	 pixels
%   		      
%   ImageType          - A string indicating the type of image; either
%                     	 'truecolor' for a truecolor (RGB) image, or
%                     	 'indexed', for an indexed image
%   		      
%   VideoCompression   - A string containing the compressor used to compress 
%                     	 the AVI file.   If the compressor is not Microsoft
%                     	 Video 1, Run-Length Encoding, Cinepak, or Intel
%                     	 Indeo, the four character code is returned.   
%		      
%   Quality            - A number between 0 and 100 indicating the video
%                     	 quality in the AVI file.  Higher quality numbers
%                     	 indicate higher video quality, where lower
%                     	 quality numbers indicate lower video quality.  This
%                     	 value is not always set in AVI files and therefore
%                     	 may be inaccurate.
%
%   NumColormapEntries - The number of colors in the colormap. For a
%                        truecolor image this value is zero.
%   
%   If the AVI file contains an audio stream, the following fields will be
%   set in FILEINFO:
%   
%   AudioFormat      - A string containing the name of the format used to
%                      store the audio data
%   
%   AudioRate        - An integer indicating the sample rate in Hertz of
%                      the audio stream
%   
%   NumAudioChannels - An integer indicating the number of audio channels in
%                      the audio stream
%   
%   See also AVIFILE, AVIREAD.

%   Copyright 1984-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/03/05 18:10:35 $

msg = '';
error(nargchk(1,2,nargin));

if (~ischar(filename))
  error('Input must be a string.');
end

[path,name,ext] = fileparts(filename);
if isempty(ext)
  filename = strcat(filename,'.avi');
end

if nargin == 1
  outputType = [];
end

fid = fopen(filename,'r','l');
if fid == -1
  error(['Unable to open ' filename ' for reading.']);
else
  filename = fopen(fid);
end

% Find RIFF chunk
[chunk, msg] = findchunk(fid,'RIFF');
errorWithFileClose(msg,fid);

% Read AVI chunk
[rifftype,msg] = readfourcc(fid);
errorWithFileClose(msg,fid);
if ( strcmpi(rifftype,'AVI ') == 0 )
  error('Invalid AVI file.');
end

% Find hdrl LIST chunk
[hdrlsize, msg] =  findlist(fid,'hdrl');
errorWithFileClose(msg,fid);

% Find avih chunk
[chunk,msg] = findchunk(fid,'avih');
errorWithFileClose(msg,fid);

fileinfo.Filename = filename;
d = dir(filename);
fileinfo.FileModDate = d.date;
fileinfo.FileSize = d.bytes;

% Read main avi header
fileinfo.MainHeader = readAVIHeader(fid);

% Find the video and audio streams
found = 0; audiofound = 0;
for i = 1:fileinfo.MainHeader.NumStreams
  % Find strl LIST chunk
  [strlsize,msg] = findlist(fid,'strl');
  errorWithFileClose(msg,fid);
  % Read strh chunk
  [strhchunk, msg] = findchunk(fid,'strh');
  errorWithFileClose(msg,fid);
  % Determine stream type
  streamtype = readfourcc(fid);
  % If it is a video or audio stream, read it
  if(strcmpi(streamtype,'vids') && (found==0))
    found = 1;
    if ( strhchunk.cksize == 64 )
      strh = read64ByteHeader(fid);
      fileinfo.VideoStreamHeader = strh;
    elseif ( strhchunk.cksize == 56 )
       strh = read56ByteHeader(fid);
       fileinfo.VideoStreamHeader = strh;
    elseif ( strhchunk.cksize == 48 )
      strh = read48ByteHeader(fid);
      fileinfo.VideoStreamHeader = strh;
    else 
      error('Unknown stream header size. Unable to read AVI file.');
    end
    
    % Read strf chunk
    [strfvchunk, msg] = findchunk(fid,'strf');
    errorWithFileClose(msg,fid);
    
    % Read the data header
    strfv = readBitmapHeader(fid);
    
    %Skip the colormap
    if fseek(fid,strfv.NumColorsUsed*4,0) == -1
      error('Incorrect colormap information. Invalid AVI file.');
    end
    %AVIINFO returns info only about the first video stream because
    %AVIREAD will only read the first video stream.
  elseif ( strcmpi(streamtype,'auds') && (audiofound == 0))
    audiofound = 1;
    if ( strhchunk.cksize == 64 )
      strh = read64ByteHeader(fid);
    elseif ( strhchunk.cksize == 56 )
      strh = read56ByteHeader(fid);
    else 
      msg = 'Unknown audio stream header. Audio stream information will be ignored.';
    end
        
    if isempty(msg)
      % Read strf chunk
      [strfachunk, msg] = findchunk(fid,'strf');
      errorWithFileClose(msg,fid);
      
      % Read the data header
      strfa = readAudioFormat(fid);
      fileinfo.AudioStreamHeader = strfa;
    else
      warning(msg)
      if fseek(fid,strhchunk.cksize-4,0) == -1
	errorWithFileClose('Invalid AVI file. Incorrect chunk size information.',fid);
      end
    end
  else
    % Seek to end of strl list minus the amount we read
    if ( fseek(fid,strlsize - 16,0) == -1 )  
	error('Invalid AVI file. Incorrect chunk size information.');
    end                              
  end
end
  
if (found == 0)
  errorWithFileClose('No video stream found.',fid);
end

strfv.NumColormapEntries = (strfvchunk.cksize - strfv.BitmapHeaderSize)/4;

% 8-bit grayscale
% 16-bit grayscale
% 24-bit truecolor
% 8-bit indexed
if strfv.NumColorsUsed > 0
  strfv.ImageType = 'indexed';
else
  if strfv.BitDepth==24
    strfv.ImageType = 'truecolor';
  elseif strfv.BitDepth==16
    if strcmp(strfv.CompressionType,'bitfields')
      strfv.ImageType = 'truecolor';
    else
      strfv.ImageType = 'grayscale';
    end
  else
    strfv.ImageType = 'grayscale';
  end
end

fileinfo.VideoFrameHeader = strfv;

fileinfo = formulateOutput(fileinfo,outputType);
fclose(fid);
return;

% ------------------------------------------------------------------------
function outinfo = formulateOutput(info,outputType)
if isempty(outputType)
  outputType = 'Normal';
end

if strcmpi(outputType,'Normal');
  outinfo.Filename = info.Filename;
  outinfo.FileSize = info.FileSize;
  outinfo.FileModDate = info.FileModDate;
  outinfo.NumFrames = info.MainHeader.TotalFrames;
  outinfo.FramesPerSecond = info.VideoStreamHeader.Rate/info.VideoStreamHeader.Scale;
  outinfo.Width = info.VideoFrameHeader.Width;
  outinfo.Height = abs(info.VideoFrameHeader.Height);
  outinfo.ImageType = info.VideoFrameHeader.ImageType;
  outinfo.VideoCompression = info.VideoFrameHeader.CompressionType;
  outinfo.Quality = info.VideoStreamHeader.Quality/100;
  outinfo.NumColormapEntries = info.VideoFrameHeader.NumColormapEntries;
  if isfield(info,'AudioStreamHeader')
    outinfo.AudioFormat = info.AudioStreamHeader.Format;
    outinfo.AudioRate = info.AudioStreamHeader.SampleRate;
    outinfo.NumAudioChannels = info.AudioStreamHeader.NumChannels;
  end
elseif strcmpi(outputType,'robust')
  outinfo = info;  
end
return;

% ------------------------------------------------------------------------
function avih = readAVIHeader(fid)
	
msg = 'Unable to read AVI header.';

% Read the micro-seconds per frame field and convert to fps
[MicroSecPerFrame, count] = freadWithCheck(fid,1,'uint32',msg);
avih.FramesPerSecond = 1/(MicroSecPerFrame*10^-6);

% Read MaxBytePerSec
avih.MaxBytePerSec =  freadWithCheck(fid,1,'uint32',msg);

% Read Reserved
reserved =  freadWithCheck(fid,1,'uint32',msg);

% Read Flags
flags =  freadWithCheck(fid,1,'uint32',msg);
flagbits = find(bitget(flags,1:32));
for i = 1:length(flagbits)
  switch flagbits(i)
   case 5
    avih.HasIndex = 'True';
   case 6
    avih.MustUseIndex = 'True';
   case 9
    avih.IsInterleaved = 'True';
   case 12
    avi.TrustCKType = 'True';
   case 17
    avih.WasCaptureFile = 'True';
   case 18
    avih.Copywrited = 'True';
  end
end

%Read TotalFrames
avih.TotalFrames = freadWithCheck(fid,1,'uint32',msg);

% Read InitialFrames
InitialFrames =  freadWithCheck(fid,1,'uint32',msg);

% Read NumStreams
avih.NumStreams = freadWithCheck(fid,1,'uint32',msg);

% Read SuggestedBufferSize
SuggestedBufferSize =  freadWithCheck(fid,1,'uint32',msg);

% Read Width
avih.Width = freadWithCheck(fid,1,'uint32',msg);

% Read Height
avih.Height = freadWithCheck(fid,1,'uint32',msg);

% Read Scale
avih.Scale = freadWithCheck(fid,1,'uint32',msg);

% Read Rate
avih.Rate = freadWithCheck(fid,1,'uint32',msg);

% Read Start
start =  freadWithCheck(fid,1,'uint32',msg);

% Read Length, (value is typically not set properly)
len =  freadWithCheck(fid,1,'uint32',msg);
return;

% ------------------------------------------------------------------------
function strh = read64ByteHeader(fid)
% Purpose: To read a stream header
% Inputs: A file identifier at the position 
%         of the stream header.
%
% Outputs:  A structure with fields corresponding 
%           pertinent information in the header.

msg = 'Unable to read stream header.';

% Read Compression handler
[handler, count] = freadWithCheck(fid,4,'uchar',msg);
strh.Compression = char(handler)';

% Read Flags
flags =  freadWithCheck(fid,1,'uint32',msg);
flagbits = find(bitget(flags,1:32));
for i = 1:length(flagbits)
  switch flagbits(i)
   case 17
    strh.PaletteChanges = 'True';
   case 1
    strh.DataRendering = 'Manual';
  end
end

% Read Reserved
Reserved =  freadWithCheck(fid,1,'uint32',msg);

% Read InitialFrames
strh.InitialFrames =  freadWithCheck(fid,1,'uint32',msg);

% Read Scale
strh.Scale = freadWithCheck(fid,1,'uint32',msg);

% Read Rate
strh.Rate  = freadWithCheck(fid,1,'uint32',msg);

% Read Start
strh.StartTime = freadWithCheck(fid,1,'uint32',msg);

% Read Length (stream length units are in frames or seconds)
strh.Length = freadWithCheck(fid,1,'uint32',msg);

% Read SuggestedBufferSize
strh.SuggestedBufferSize = freadWithCheck(fid,1,'uint32',msg);

% Read Quality
strh.Quality = freadWithCheck(fid,1,'uint32',msg);

% Read SampleSize
strh.SampleSize =  freadWithCheck(fid,1,'uint32',msg);

% Read Rect
rect = freadWithCheck(fid,4,'uint32',msg);
return;

% ------------------------------------------------------------------------
function strh = read56ByteHeader(fid)

msg = 'Unable to read stream header.';
compression = freadWithCheck(fid,4,'char',msg);
strh.CompressionHandler = char(compression)';

flags = freadWithCheck(fid,1,'uint32',msg);
flagbits = find(bitget(flags,1:32));
for i = 1:length(flagbits)
  switch flagbits(i)
   case 17
    strh.PaletteChanges = 'True';
   case 1
    strh.DataRendering = 'Manual';
  end
end

strh.Reserved = freadWithCheck(fid,1,'uint32',msg);  
strh.InitialFrames = freadWithCheck(fid,1,'uint32',msg);
strh.Scale = freadWithCheck(fid,1,'uint32',msg);    
strh.Rate = freadWithCheck(fid,1,'uint32',msg);     
strh.Start = freadWithCheck(fid,1,'uint32',msg);     
strh.Length = freadWithCheck(fid,1,'uint32',msg);   
strh.SuggestedBufferSize = freadWithCheck(fid,1,'uint32',msg);
strh.Quality = freadWithCheck(fid,1,'uint32',msg);   
strh.SampleSize = freadWithCheck(fid,1,'uint32',msg);

% Read Rect
Rect = freadWithCheck(fid,4,'uint16',msg);
return;

% ------------------------------------------------------------------------
function strh = read48ByteHeader(fid)
msg = 'Unable to read stream header.';
% Read fccHandler
compression = freadWithCheck(fid,4,'char',msg);
strh.CompressionHandler = char(compression)';

flags = freadWithCheck(fid,1,'uint32',msg);
flagbits = find(bitget(flags,1:32));
for i = 1:length(flagbits)
  switch flagbits(i)
   case 17
    strh.PaletteChanges = 'True';
   case 1
    strh.DataRendering = 'Manual';
  end
end

strh.Reserved = freadWithCheck(fid,1,'uint32',msg);  
strh.InitialFrames = freadWithCheck(fid,1,'uint32',msg);
strh.Scale = freadWithCheck(fid,1,'uint32',msg);    
strh.Rate = freadWithCheck(fid,1,'uint32',msg);     
strh.Start = freadWithCheck(fid,1,'uint32',msg);     
strh.Length = freadWithCheck(fid,1,'uint32',msg);   
strh.SuggestedBufferSize = freadWithCheck(fid,1,'uint32',msg);
strh.Quality = freadWithCheck(fid,1,'uint32',msg);   
strh.SampleSize = freadWithCheck(fid,1,'uint32',msg);
return;

% ------------------------------------------------------------------------
function strf = readBitmapHeader(fid)
% Purpose: To read the BITMAPINFO header information 

Compression = '';
msg = 'Unable to read BITMAPINFOHEADER.';

% Read header size
strf.BitmapHeaderSize = freadWithCheck(fid,1,'uint32',msg);

% Read Width
strf.Width = freadWithCheck(fid,1,'int32',msg);

% Read Height
strf.Height = freadWithCheck(fid,1,'int32',msg);

%Read Planes
strf.Planes = freadWithCheck(fid,1,'uint16',msg);

% Read BitCount
strf.BitDepth = freadWithCheck(fid,1,'uint16',msg);

% Read Compression
compress = freadWithCheck(fid,1,'uint32',msg);
switch compress
 case 0
  Compression = 'none';
 case 1
  Compression = '8-bit RLE';
 case 2
  Compression = '4-bit RLE';
 case 3
  Compression = 'bitfields';
end

if isempty(Compression)
  code = getfourcc(compress);
  switch lower(code)
   case 'none'
    Compression = 'None';
   case 'rgb '
    Compression = 'None';
   case 'raw '
    Compression = 'None';  
   case '    '
    Compression = 'None';
   case 'rle '
    Compression = 'RLE';
   case 'cvid'
    Compression = 'Cinepak';
   case 'iv32'
    Compression = 'Indeo3';
   case 'iv50'
    Compression = 'Indeo5';
   case 'msvc'
    Compression = 'MSVC';
   case 'cram'
    Compression = 'MSVC';
   otherwise
    Compression = code;
  end
end

strf.CompressionType = Compression;

strf.Bitmapsize = freadWithCheck(fid,1,'uint32',msg);

strf.HorzResoltion = freadWithCheck(fid,1,'uint32',msg);

strf.VertResolution = freadWithCheck(fid,1,'uint32',msg);

strf.NumColorsUsed = freadWithCheck(fid,1,'uint32',msg);

strf.NumImportantColors = freadWithCheck(fid,1,'uint32',msg);
return;

% ------------------------------------------------------------------------
function strf = readAudioFormat(fid)
%Read WAV format chunk information

msg = 'Unable to read audio stream header.';
%Read Format category
fmtcat = freadWithCheck(fid,1,'uint16',msg);

switch fmtcat
 case  1
  strf.Format = 'PCM';
 case 2
  strf.Format = 'Microsoft ADPCM';
 case 6
  strf.Format = 'CCITT a-law';
 case 7
  strf.Format = 'CCITT mu-law';
 case 17
  strf.Format = 'IMA ADPCM';   
 case 34
  strf.Format = 'DSP Group TrueSpeech TM';
 case 49
  strf.Format = 'GSM 6.10';
 case 50
  strf.Format = 'MSN Audio';
 case 257
  strf.Format = 'IBM Mu-law';
 case 258
  strf.Format = 'IBM A-law';
 case 259
  strf.Format = 'IBM AVC Adaptive Differential';
 otherwise
  strf.Format = ['Format #' num2str(fmtcat)];
end

% Read numChannels
strf.NumChannels = freadWithCheck(fid,1,'uint16',msg);

% Read Sample Rate
strf.SampleRate = freadWithCheck(fid,1,'uint32',msg);

% Read Buffer estimation
buffest = freadWithCheck(fid,1,'uint32',msg);

% Read block size
blksize = freadWithCheck(fid,1,'uint16',msg);
return

% ------------------------------------------------------------------------
function errorWithFileClose(msg,fid)
%Close open file the error
if ~isempty(msg)
  fclose(fid);
  error(msg);
end
return;

% ------------------------------------------------------------------------
function [value,count] = freadWithCheck(fid,size,precision,msg)
% A wrapper around FREAD to make sure the correct amount of data was read
[value, count] = fread(fid,size,precision);
if count ~= size
  errorWithFileClose(msg,fid);
end
return;
