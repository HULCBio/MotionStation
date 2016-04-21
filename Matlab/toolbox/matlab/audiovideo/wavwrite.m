function wavwrite(y,Fs,nbits,wavefile)
%WAVWRITE Write Microsoft WAVE (".wav") sound file.
%   WAVWRITE(Y,FS,NBITS,WAVEFILE) writes data Y to a Windows WAVE
%   file specified by the file name WAVEFILE, with a sample rate
%   of FS Hz and with NBITS number of bits.  NBITS must be 8, 16,
%   24, or 32.  Stereo data should be specified as a matrix with two 
%   columns. For NBITS < 32, amplitude values outside the range 
%   [-1,+1] are clipped.
%
%   WAVWRITE(Y,FS,WAVEFILE) assumes NBITS=16 bits.
%   WAVWRITE(Y,WAVEFILE) assumes NBITS=16 bits and FS=8000 Hz.
%
%   8-, 16-, and 24-bit files are type 1 integer PCM.  32-bit files 
%   are written as type 3 normalized floating point.
%
%   See also WAVREAD, AUWRITE.

%   Copyright 1984-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/03/30 13:07:07 $

%   D. Orofino, 11/95

% Parse inputs:
error(nargchk(2,4,nargin));
if nargin < 3,
  wavefile = Fs;
  Fs       = 8000;
  nbits    = 16;
elseif nargin < 4,
  wavefile = nbits;
  nbits    = 16;
end

% If input is a vector, force it to be a column:
if ndims(y) > 2,
  error('Data array cannot be an N-D array.');
end
if size(y,1)==1,
   y = y(:);
end
[samples, channels] = size(y);


% Determine number of bytes in chunks
% (not including pad bytes, if needed):
% ----------------------------------
%  'RIFF'           4 bytes
%  size             4 bytes
%  'WAVE'           4 bytes
%  'fmt '           4 bytes
%  size             4 bytes
% <wave-format>     14 bytes
% <format_specific> 2 bytes (PCM)
%  'data'           4 bytes
%  size             4 bytes
% <wave-data>       N bytes
% ----------------------------------
bytes_per_sample = ceil(nbits/8);
total_samples    = samples * channels;
total_bytes      = total_samples * bytes_per_sample;

riff_cksize = 36+total_bytes;   % Don't include 'RIFF' or its size field
fmt_cksize  = 16;               % Don't include 'fmt ' or its size field
data_cksize = total_bytes;      % Don't include 'data' or its size field

% Determine pad bytes:
data_pad    = rem(data_cksize,2);
riff_cksize = riff_cksize + data_pad; % + fmt_pad, always 0

% Open file for output:
[fid,err] = OpenWaveWrite(wavefile);
error(err);

% Prepare basic chunk structure fields:
ck=[]; ck.fid=fid; ck.filename = wavefile;

% Write RIFF chunk:
ck.ID   = 'RIFF';
ck.Size = riff_cksize;
error(write_ckinfo(ck));

% Write WAVE subchunk:
ck.ID   = 'WAVE';
ck.Size = [];  % Indicate a subchunk (no chunk size)
error(write_ckinfo(ck));

% Write <fmt-ck>:
ck.ID   = 'fmt ';
ck.Size = fmt_cksize;
error(write_ckinfo(ck));

% Write <wave-format>:
fmt.filename        = wavefile;
if nbits == 32,
    fmt.wFormatTag  = 3;            % Data encoding format (1=PCM, 3=Type 3 32-bit)
else
    fmt.wFormatTag  = 1;            
end
fmt.nChannels       = channels;     % Number of channels
fmt.nSamplesPerSec  = Fs;           % Samples per second
fmt.nAvgBytesPerSec = channels*bytes_per_sample*Fs; % Avg transfer rate
fmt.nBlockAlign     = channels*bytes_per_sample;    % Block alignment
fmt.nBitsPerSample  = nbits;        % standard <PCM-format-specific> info
error(write_wavefmt(fid,fmt));

% Write <data-ck>:
ck.ID   = 'data';
ck.Size = data_cksize;
error(write_ckinfo(ck));

% Write <wave-data>, and its pad byte if needed:
error(write_wavedat(fid,fmt,y));

% Close file:
fclose(fid);

% end of wavwrite()


% ------------------------------------------------------------------------
% Private functions:
% ------------------------------------------------------------------------


% ------------------------------------------------------------------------
function [fid,err] = OpenWaveWrite(wavefile)
% OpenWaveWrite
%   Open WAV file for writing.
%   If filename does not contain an extension, add ".wav"

fid = [];
err = '';
if ~isstr(wavefile),
   err='Wave file name must be a string.'; return;
end
if isempty(findstr(wavefile,'.')),
  wavefile=[wavefile '.wav'];
end
% Open file, little-endian:
[fid,err] = fopen(wavefile,'wb','l');

return


% ------------------------------------------------------------------------
function err = write_ckinfo(ck)
% WRITE_CKINFO: Writes next RIFF chunk, but not the chunk data.
%   Assumes the following fields in ck:
%         .fid   File ID to an open file
%         .ID    4-character string chunk identifier
%         .Size  Size of chunk (empty if subchunk)
%
%
%   Expects an open FID pointing to first byte of chunk header,
%   and a chunk structure.
%   ck.fid, ck.ID, ck.Size, ck.Data

errmsg = ['Failed to write ' ck.ID ' chunk to WAVE file: ' ck.filename];
err    = '';

if (fwrite(ck.fid, ck.ID, 'char') ~= 4),
   err=errmsg; return;
end

if ~isempty(ck.Size),
  % Write chunk size:
  if (fwrite(ck.fid, ck.Size, 'uint32') ~= 1),
     err=errmsg; return;
  end
end

return

% ------------------------------------------------------------------------
function err = write_wavefmt(fid, fmt)
% WRITE_WAVEFMT: Write WAVE format chunk.
%   Assumes fid points to the wave-format subchunk.
%   Requires chunk structure to be passed, indicating
%   the length of the chunk.

errmsg = ['Failed to write WAVE format chunk to file' fmt.filename];
err    = '';

% Create <wave-format> data:
if (fwrite(fid, fmt.wFormatTag,      'uint16') ~= 1) | ...
   (fwrite(fid, fmt.nChannels,       'uint16') ~= 1) | ...
   (fwrite(fid, fmt.nSamplesPerSec,  'uint32' ) ~= 1) | ...
   (fwrite(fid, fmt.nAvgBytesPerSec, 'uint32' ) ~= 1) | ...
   (fwrite(fid, fmt.nBlockAlign,     'uint16') ~= 1),
   err=errmsg; return;
end

% Write format-specific info:
if fmt.wFormatTag==1 | fmt.wFormatTag==3,
  % Write standard <PCM-format-specific> info:
  if (fwrite(fid, fmt.nBitsPerSample, 'uint16') ~= 1),
     err=errmsg; return;
  end
  
else
  err='Unknown data format.';
end

return


% -----------------------------------------------------------------------
function y = PCM_Quantize(x, fmt)
% PCM_Quantize:
%   Scale and quantize input data, from [-1, +1] range to
%   either an 8-, 16-, or 24-bit data range.

% Clip data to normalized range [-1,+1]:
ClipMsg  = ['Data clipped during write to file:' fmt.filename];
ClipWarn = 0;

% Determine slope (m) and bias (b) for data scaling:
nbits = fmt.nBitsPerSample;
m = 2.^(nbits-1);

switch nbits
case 8,
   b=128;
case {16,24},
   b=0;
otherwise,
   error('Invalid number of bits specified.');
end

y = round(m .* x + b);

% Determine quantized data limits, based on the
% presumed input data limits of [-1, +1]:
ylim = [-1 +1];
qlim = m * ylim + b;
qlim(2) = qlim(2)-1;

% Clip data to quantizer limits:
i = find(y < qlim(1));
if ~isempty(i),
   warning(ClipMsg); ClipWarn=1;
   y(i) = qlim(1);
end

i = find(y > qlim(2));
if ~isempty(i),
   if ~ClipWarn, warning(ClipMsg); end
   y(i) = qlim(2);
end

return


% -----------------------------------------------------------------------
function err = write_wavedat(fid,fmt,data)
% WRITE_WAVEDAT: Write WAVE data chunk
%   Assumes fid points to the wave-data chunk
%   Requires <wave-format> structure to be passed.

err = '';

if fmt.wFormatTag==1 | fmt.wFormatTag==3,
   % PCM Format
   
   % 32-bit Type 3 is normalized, so no scaling needed.
   if fmt.nBitsPerSample ~= 32,
       data = PCM_Quantize(data, fmt);
   end
   
   switch fmt.nBitsPerSample
   case 8,
      dtype='uchar'; % unsigned 8-bit
   case 16,
      dtype='int16'; % signed 16-bit
   case 24,
	  dtype='bit24'; % signed 24-bit
   case 32,
      dtype='float'; % normalized 32-bit floating point
   otherwise,
      err = 'Invalid number of bits specified.'; return;
   end
   
   % Write data, one row at a time (one sample from each channel):
   [samples,channels] = size(data);
   total_samples = samples*channels;
   
   if (fwrite(fid, reshape(data',total_samples,1), dtype) ~= total_samples),
      err = 'Failed to write PCM data samples.'; return;
   end
   
   % Determine # bytes/sample - format requires rounding
   %  to next integer number of bytes:
   BytesPerSample = ceil(fmt.nBitsPerSample/8);
   
   % Determine if a pad-byte must be appended to data chunk:
   if rem(total_samples*BytesPerSample, 2) ~= 0,
      fwrite(fid,0,'uchar');
   end
   
else
  % Unknown wave-format for data.
  err = 'Unsupported data format.';
end

return

% end of wavwrite.m
