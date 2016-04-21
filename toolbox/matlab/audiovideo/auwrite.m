function auwrite(y,Fs,nbits,method,aufile)
%AUWRITE Write NeXT/SUN (".au") sound file.
%   AUWRITE(Y,AUFILE) writes a sound file specified by the
%   string AUFILE.  The data should be arranged with one channel
%   per column.  Amplitude values outside the range [-1,+1] are
%   clipped prior to writing. 
%
%   Supports multi-channel data for 8-bit mu-law, and 8- and
%   16-bit linear formats:
%
%   AUWRITE(Y,Fs,AUFILE) specifies the sample rate of the data
%   in Hertz.
%
%   AUWRITE(Y,Fs,BITS,AUFILE) selects the number of bits in
%   the encoder.  Allowable settings are BITS=8 and BITS=16.
%
%   AUWRITE(Y,Fs,BITS,METHOD,AUFILE) allows selection of the
%   encoding method, which can be either 'mu' or 'linear'.
%   Note that mu-law files must be 8-bit. By default, method='mu'.
%
%   See also AUREAD, WAVWRITE.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/03/05 18:10:34 $

%   D. Orofino, 10/95

% Get user default preferences:
Fs_pref = 8000; nbits_pref = 8; method_pref='mu';

% Parse inputs:
if nargin==1,
  % Compatibility with old auwrite:
  warning(['This syntax for auwrite is obsolete and should ' ...
           'be replaced by sound(y).']);
  sound(y);
  return;
elseif nargin>5,
  error('Incorrect number of input arguments.');
elseif nargin==4,
  aufile=method;
  method=method_pref;
elseif nargin==3,
  aufile=nbits;
  method=method_pref;
  nbits=nbits_pref;
elseif nargin==2,
  aufile=Fs;
  method=method_pref;
  nbits=nbits_pref;
  Fs=Fs_pref;
end

% Open file for output:
if ~ischar(aufile),
  error('Filename must be a string.');
end
if isempty(findstr(aufile,'.')),
  aufile=[aufile '.au'];
end
fid=fopen(aufile,'wb','b'); % Big-endian
if (fid==-1),
  error('Cannot open sound file for output. File may be in use.');
end

% If input is a vector, force it to be a column:
if ndims(y)>2,
  error('Data array must have 1- or 2-dimensions, only.');
end
if size(y,1)==1, y=y(:); end

% Clip data to normalized range [-1,+1]:
i=find(abs(y)>1);
if ~isempty(i),
  y(i)=sign(y(i));
  warning('Data clipped during write to file.');
end

% Write sound header:
snd = write_sndhdr(fid,Fs,nbits,method,size(y));
if ~isstruct(snd), error(snd); end

% Write data:
if write_sndata(fid,snd,y),
  error('Error while writing sound file.');
end

fclose(fid);    % Close file
return;

% end of auwrite()

% ------------------------------------------------------------------------
% Private functions:
% ------------------------------------------------------------------------

% WRITE_SNDHDR: Write sound file header structure
%   Assumes fid points to the start of an open file.
%
function snd = write_sndhdr(fid,Fs,nbits,method,sz)

% Interpret format:
if strncmp(method,'mu',length(method)),
  if nbits~=8,
    snd=['Mu-law can only be used with 8 bit data.' ...
         ' Use method=''linear'' instead.']; return;
  end
  snd.format=1;  % 8-bit mu-law
  snd.bits = 8;
elseif strncmp(method,'linear',length(method)),
  if nbits==8,
    snd.format=2; % 8-bit linear
    snd.bits = 8;
  elseif nbits==16,
    snd.format=3; % 16-bit linear
    snd.bits = 16;
  else
    snd='Unrecognized data format selected.'; return;
  end
else
  snd='Unrecognized data format selected.'; return;
end

% Define sound header structure:
snd.samples = sz(1);
snd.chans = sz(2);
total_samples = snd.samples*snd.chans;
bytes_per_sample = ceil(snd.bits/8);
snd.rate = Fs;
snd.databytes = bytes_per_sample * total_samples;
snd.offset = 28;
snd.info = [fix('TMW') 0];  % 4-character null terminated string

fwrite(fid,'.snd','char');          % magic number
fwrite(fid,snd.offset,'uint32');    % data location
fwrite(fid,snd.databytes,'uint32'); % size in bytes
fwrite(fid,snd.format,'uint32');    % data format
fwrite(fid,snd.rate,'uint32');      % sample rate
fwrite(fid,snd.chans,'uint32');     % channels
fwrite(fid,snd.info,'char');        % info

return;


% WRITE_SNDATA: Write sound data
function status = write_sndata(fid,snd,data)
status = 0;

% Interpret format:
if snd.format==1,
  dtype='uchar'; % 8-bit mu-law
  data = lin2mu(data);
elseif snd.format==2,
  dtype='int8';
  data = round(data * (2^7-1));
elseif snd.format==3,
  dtype = 'int16';
  data  = round(data * (2^15-1));
else
  status=-1; return;
end

% Write data, one row at a time (one sample from each channel):
total_samples = snd.samples*snd.chans;
cnt = fwrite(fid, reshape(data',total_samples,1), dtype);
if cnt~=total_samples, status=-1; end

return;

% end of auwrite.m
