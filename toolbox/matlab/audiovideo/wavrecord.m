function y = wavrecord(varargin)
%WAVRECORD Record sound using Windows audio input device.
%   WAVRECORD(N,FS,CH) records N audio samples at FS Hertz from
%   CH number of input channels from the Windows WAVE audio device.
%   Standard audio rates are 8000, 11025, 22050, and 44100 Hz.  CH 
%   can be 1 or 2 (mono or stereo).  Samples are returned in a matrix 
%   of size N x CH.  If not specified, FS=11025 Hz, and CH=1.
%
%   WAVRECORD(..., DTYPE) records and returns data using the data type
%   specified by DTYPE.  Supported data types and the corresponding
%   number of bits per sample recorded in each format are as follows:
%        DTYPE     bits/sample
%       'double'      16
%       'single'      16
%       'int16'       16
%       'uint8'        8
%
%   This function is only for use with 32-bit Windows machines.
%
%   Example: Record and play back 5 seconds of 16-bit audio
%            sampled at 11.025 kHz.
%       Fs = 11025;
%       y  = wavrecord(5*Fs, Fs, 'int16');
%       wavplay(y, Fs);
%
%   See also WAVPLAY, WAVREAD, WAVWRITE.

%   Author: D. Orofino
%   Copyright 1988-2004 The MathWorks, Inc. 
%   $Revision: 1.1.6.2 $  $Date: 2004/03/05 18:11:24 $

if ~strcmp(computer,'PCWIN'),
   error('WAVRECORD is only for use with Windows 95/98/NT machines.');
end

[s,msg] = parse_args(varargin{:});
error(msg);

% Be sure to transpose data once it has been received:
y = recsnd(s.n, s.fs, s.bits, s.ch, s.dtype_id).';

return

% ------------------------------------------------
function [s,msg] = parse_args(varargin)
% PARSE_ARGS

s = [];
msg = nargchk(1,4,nargin);
if ~isempty(msg), return; end

% dtype_id: 0=double, 1=int, 2-single
if ischar(varargin{end}),
   % trailing string arg is the data type: index 1='double' or 2='int'
   switch lower(varargin{end})
   case 'double'
      dtype_id = 0;
      bits     = 16;
   case 'single'
      dtype_id = 2;
      bits     = 16;
   case 'int16'
      dtype_id = 1;
      bits     = 16;
   case 'uint8'
      dtype_id = 1;
      bits     = 8;
   otherwise
      msg = 'DTYPE must be ''double'', ''single'', ''int16'', or ''uint8''.';
      return
   end
   varargin(end) = [];  % remove dtype arg from list
else
   % Default: double precision, 16-bit samples
   dtype_id = 0;  % 'double'
   bits     = 16;
end

nargs = length(varargin);
if nargs < 3, ch = 1;
else          ch = varargin{3};
end
if nargs < 2, fs = 11025;
else          fs = varargin{2};
end
n = varargin{1};

s.n        = n;        % # samples
s.fs       = fs;       % sample rate, Hz
s.ch       = ch;       % # channels
s.dtype_id = dtype_id; % 0=double, 1=int
s.bits     = bits;     % # bits/sample

% [EOF] wavrecord.m
